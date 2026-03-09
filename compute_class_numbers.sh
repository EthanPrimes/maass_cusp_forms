#!/bin/bash
#***** NOTE: run this using: sg grp_maass_cusp_forms "sbatch compute_class_numbers.sh"
#*****
#***** To run a specific batch of jobs (e.g. jobs 200-399), use:
#*****   sg grp_maass_cusp_forms "sbatch --array=200-399 compute_class_numbers.sh"
#*****
#***** Each job processes CHUNK discriminants. With CHUNK=50000:
#*****   job 0   -> rows 0       to 49999
#*****   job 1   -> rows 50000   to 99999
#*****   job k   -> rows k*50000 to (k+1)*50000 - 1
#*****
#***** For ~30M discriminants total, there are ~600 jobs (0-599).
#***** Submit in batches across days, e.g.:
#*****   Day 1: --array=0-199
#*****   Day 2: --array=200-399
#*****   Day 3: --array=400-599

#SBATCH --time=36:00:00        # walltime — adjust based on observed runtime per chunk
#SBATCH --ntasks=1             # one task per array job (parallelism comes from the array)
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=10240M    # increased: Arrow column + Sage/PARI overhead for large chunks
#SBATCH -J "class_numbers"
#SBATCH --array=44-100            # *** CHANGE THIS per submission day ***
#SBATCH --output=/dev/null     # stdout suppressed — progress is visible in output feather shards
#SBATCH --error=/dev/null      # stderr suppressed here; failures are saved manually below

#SBATCH --mail-user=erpalens@byu.edu
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

# --- Group guard ---
if [ "$(id -gn)" != "grp_maass_cusp_forms" ]; then
    echo '*!*!*' This job is not running as the intended group. \
         If you want to run it as grp_maass_cusp_forms, run sbatch as follows: \
         sg grp_maass_cusp_forms '"'sbatch compute_class_numbers.sh'"'
    exit 1
fi

# --- Config ---
CHUNK=10000                          # number of discriminants per job — tune as needed
INPUT="discriminants.feather"        # path to input feather file
OUTDIR="output"                      # directory for result shards

# --- Derived indices ---
JOB_ID=${SLURM_ARRAY_TASK_ID}
START=$(( JOB_ID * CHUNK ))
END=$(( (JOB_ID + 1) * CHUNK ))

# --- Environment ---
export OMP_NUM_THREADS=$SLURM_CPUS_ON_NODE
mkdir -p logs
mkdir -p "${OUTDIR}"

# --- Modules ---
module load miniconda3
source /apps/spack/root/opt/spack/linux-rhel9-haswell/gcc-13.2.0/miniconda3-24.3.0-poykqmtnr6sypgvxuiil5mz5rjd3lwrd/etc/profile.d/conda.sh
conda activate sage

# --- Run ---
# Stderr is captured to a temp file and only saved to logs/ if the job fails,
# so no clutter accumulates on success.
TMPLOG=$(mktemp)

sage compute_class_numbers.sage \
    --job-id "${JOB_ID}" \
    --start  "${START}"  \
    --end    "${END}"    \
    --input  "${INPUT}"  \
    --outdir "${OUTDIR}" \
    2>"${TMPLOG}"

EXIT_CODE=$?
if [ ${EXIT_CODE} -ne 0 ]; then
    cp "${TMPLOG}" "logs/err_${SLURM_ARRAY_JOB_ID}_${JOB_ID}.txt"
fi
rm -f "${TMPLOG}"
exit ${EXIT_CODE}

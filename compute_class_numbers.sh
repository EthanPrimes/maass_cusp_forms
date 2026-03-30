#!/bin/bash
#***** NOTE: run this using: sg grp_maass_cusp_forms "sbatch compute_class_numbers.sh"
#*****
#***** Each job processes CHUNK discriminants. With CHUNK=10000:
#*****   job 0   -> rows 0       to 9999
#*****   job 1   -> rows 10000   to 19999
#*****   job k   -> rows k*10000 to (k+1)*10000 - 1

#SBATCH --time=1:00:00        # walltime — adjust based on observed runtime per chunk
#SBATCH --ntasks=1             # one task per array job (parallelism comes from the array)
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=20480M    # increased: Arrow column + Sage/PARI overhead for large chunks
#SBATCH -J "class_numbers"
#SBATCH --array=1-1000           # *** CHANGE THIS per submission day ***
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
CHUNK=10000
BASE=5000                        # *** offset so task IDs stay within cluster limits ***
INPUT="/home/erpalens/groups/grp_maass_cusp_forms/discriminants.feather"
OUTDIR="/home/erpalens/groups/grp_maass_cusp_forms/output"
SUBMITDIR="$(pwd)"

# --- Derived indices ---
JOB_ID=$(( SLURM_ARRAY_TASK_ID + BASE ))
START=$(( JOB_ID * CHUNK ))
END=$(( (JOB_ID + 1) * CHUNK ))

# --- Environment ---
export OMP_NUM_THREADS=$SLURM_CPUS_ON_NODE
mkdir -p "${SUBMITDIR}/logs"
mkdir -p "${OUTDIR}"

# --- Modules ---
module load miniconda3
source /apps/spack/root/opt/spack/linux-rhel9-haswell/gcc-13.2.0/miniconda3-24.3.0-poykqmtnr6sypgvxuiil5mz5rjd3lwrd/etc/profile.d/conda.sh
conda activate sage

# --- Copy script and input to node-local scratch ---
# This avoids stale NFS file handle errors during sage-preparse, which occur
# when the network filesystem becomes temporarily unavailable mid-job.
SCRATCH=$(mktemp -d)
cp compute_class_numbers.sage "${SCRATCH}/"
cp "${INPUT}" "${SCRATCH}/"
cd "${SCRATCH}"

# --- Run ---
# Stderr is captured to a temp file and only saved to logs/ if the job fails,
# so no clutter accumulates on success.
TMPLOG=$(mktemp)

sage compute_class_numbers.sage \
    --job-id "${JOB_ID}" \
    --start  "${START}"  \
    --end    "${END}"    \
    --input  "$(basename "${INPUT}")" \
    --outdir "${OUTDIR}" \
    2>"${TMPLOG}"

EXIT_CODE=$?
if [ ${EXIT_CODE} -ne 0 ]; then
    cp "${TMPLOG}" "${SUBMITDIR}/logs/err_${SLURM_ARRAY_JOB_ID}_${JOB_ID}.txt"
fi
rm -f "${TMPLOG}"
rm -rf "${SCRATCH}"
exit ${EXIT_CODE}

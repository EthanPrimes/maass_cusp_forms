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
#***** Submit in batches across days, e.g.:
#*****   Day 1: --array=0-199
#*****   Day 2: --array=200-399
#*****   Day 3: --array=400-599

#SBATCH --time=01:00:00        # walltime — adjust based on observed runtime per chunk
#SBATCH --ntasks=1             # one task per array job (parallelism comes from the array)
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=10240M
#SBATCH -J "class_numbers"
#SBATCH --array=0-99            # *** CHANGE THIS per submission day ***
#SBATCH --output=logs/out_%A_%a.txt
#SBATCH --error=logs/err_%A_%a.txt

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
sage compute_class_numbers.sage \
    --job-id "${JOB_ID}" \
    --start  "${START}"  \
    --end    "${END}"    \
    --input  "${INPUT}"  \
    --outdir "${OUTDIR}"

#!/bin/bash
#***** NOTE: run this using: sg grp_maass_cusp_forms "sbatch thefilename"

#SBATCH --time=00:15:00   # walltime
#SBATCH --ntasks=10   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem-per-cpu=1024M   # memory per CPU core
#SBATCH -J "class_numbers"   # job name
#SBATCH --array=0-9
#SBATCH --output=logs/out_%A_%a.txt
#SBATCH --error=logs/err_%A_%a.txt

#SBATCH --mail-user=erpalens@byu.edu   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

if [ "$(id -gn)" != "grp_maass_cusp_forms" ]; then
    echo '*!*!*' This job is not running as the intended group. If you want to run it as grp_maass_cusp_forms, run sbatch as follows:  sg grp_maass_cusp_forms '"'sbatch thefilename'"'
    exit 1
fi


# Set the max number of threads to use for programs using OpenMP. Should be <= ppn. Does nothing if the program doesn't use OpenMP.
export OMP_NUM_THREADS=$SLURM_CPUS_ON_NODE

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE
module load python
conda activate sage
sage

JOB_ID=${SLURM_ARRAY_TASK_ID}

python computing_class_numbers.sage \
    --job-id ${JOB_ID} \
    --start 0\
    --end 10000\
    --outdir output

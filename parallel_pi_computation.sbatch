#!/bin/bash
#***** NOTE: run this using: sg grp_maass_cusp_forms "sbatch thefilename"

#SBATCH --time=00:03:00   # walltime
#SBATCH --ntasks=100   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem-per-cpu=1024M   # memory per CPU core
#SBATCH -J "parallel_pi"   # job name
#SBATCH --array=0-99
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

JOB_ID=${SLURM_ARRAY_TASK_ID}

python parallel_pi_computation.py \
    --job-id ${JOB_ID} \
    --n-samples 10000000 \
    --outdir output

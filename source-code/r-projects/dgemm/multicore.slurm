#!/usr/bin/env -S bash -l
#SBATCH --account=lpt2_sysadmin
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --time=00:05:00
#SBATCH --partition=batch_sapphirerapids
#SBATCH --cluster=wice

# load modules
module load R/4.4.0-gfbf-2023a
module load GCCcore/12.3.0

# run the script
set -x
time OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK ./dgemm.R --size 2000 --power 50 --nr_cores 1

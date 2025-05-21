#!/usr/bin/env -S bash -l
#SBATCH --account=lpt2_sysadmin
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:02:00
#SBATCH --cluster=wice

# first clean up your environment, then load R
module purge &> /dev/null
module load R/4.4.0-gfbf-2023a

Rscript ./hello_world.R

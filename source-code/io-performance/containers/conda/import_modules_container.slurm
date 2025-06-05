#!/usr/bin/env -S bash -l
#SBATCH --account=lpt2_sysadmin
#SBATCH --cluster=wice
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time 00:30:00
#SBATCH --mail-type=END,FAIL

time apptainer exec conda.sif python import_modules.py

#!/usr/bin/env -S bash -l
#SBATCH --account=lpt2_sysadmin
#SBATCH --cluster=wice
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=30G
#SBATCH --time 02:00:00
#SBATCH --mail-type=END,FAIL

# ensure temporary and cache directories are on the scratch filesystem
export APPTAINER_TMPDIR=$VSC_SCRATCH/apptainer_tmp
mkdir -p $APPTAINER_TMPDIR
export APPTAINER_CACHEDIR=$VSC_SCRATCH/apptainer_cache
mkdir -p $APPTAINER_CACHEDIR

# build the image using fake-root
apptainer build --fakeroot conda.sif conda.recipe

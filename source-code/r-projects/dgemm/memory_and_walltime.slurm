#!/usr/bin/env -S bash -l
#SBATCH --account=lpt2_sysadmin
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --time=01:00:00
#SBATCH --mem=10G
#SBATCH --partition=batch_sapphirerapids
#SBATCH --cluster=wice

# check whethr SIZE and POWER are set, if not abort
if [ -z "$SIZE" ] || [ -z "$POWER" ]; then
    (>&2 echo "SIZE and POWER must be set, use, e.g., --export=ALL,SIZE=1000,POWER=3")
    exit 1
fi

# print the values of SIZE and POWER
echo "SIZE=$SIZE, POWER=$POWER"

# load modules
module load R/4.4.0-gfbf-2023a
module load GCCcore/12.3.0

# run the script
set -x
time OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK ./dgemm.R --size $SIZE --power $POWER --nr_cores 1

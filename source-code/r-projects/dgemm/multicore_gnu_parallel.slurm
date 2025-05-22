#!/usr/bin/env -S bash -l
#SBATCH --account=lpt2_sysadmin
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=96
#SBATCH --time=01:00:00
#SBATCH --partition=batch_sapphirerapids
#SBATCH --cluster=wice

# load modules
module load R/4.4.0-gfbf-2023a
module load GCCcore/12.3.0

# number of cores per work item
export OMP_NUM_THREADS=2

# create a wrapper function to avoid issues with the parallel command
function run_dgemm {
    ./dgemm.R --size 2000 --power 50 --nr_cores 1
}
export -f run_dgemm

# run with an increasing number of parallel work items
for i in $(seq $(( $SLURM_CPUS_PER_TASK / $OMP_NUM_THREADS ))); do
    echo "Running with $i parallel work items"
    time parallel -j $i run_dgemm ::: $(seq $i) > /dev/null
    echo "-----------------------------------"
done

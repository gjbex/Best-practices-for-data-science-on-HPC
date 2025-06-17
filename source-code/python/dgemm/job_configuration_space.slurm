#!/usr/bin/env -S bash -l
#SBATCH --account=lpt2_sysadmin
#SBATCH --cluster=wice
#SBATCH --partition=batch_sapphirerapids
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=96
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=geertjan.bex@uhasselt.be

# fail immediately
set -e

# load modules
module purge &> /dev/null
module load SciPy-bundle/2023.12-iimkl-2023b

# define the connfiguration space
max_cpus=96
nr_tasks=$max_cpus
ntasks_values=(1 2 4 6 8 12 18 24 32 48 60 72 96)
cpus_per_task_values=(1 2 4 8 12 24 48 96)
nr_iterations=5

# define task parameters
size=2000
power=50

# create a function to run the computation to simplify running GNU parallel
function run_dgemm {
    ./dgemm.py --size 2000 --power 20
}
export -f run_dgemm

for ntasks in ${ntasks_values[@]}; do
    for cpus_per_task in ${cpus_per_task_values[@]}; do
        if [[ $ntasks*$cpus_per_task -le max_cpus ]]; then
            for iteration in $(seq $nr_iterations); do
                export OMP_NUM_THREADS=$cpus_per_task
                start_time=$(date +%s.%N)
                parallel -j $ntasks run_dgemm ::: $(seq $ntasks) > /dev/null
                end_time=$(date +%s.%N)
                elapsed_time=$(bc -q <<< "$end_time - $start_time")
                echo "$ntasks,$cpus_per_task,$elapsed_time"
            done
        fi
    done
done

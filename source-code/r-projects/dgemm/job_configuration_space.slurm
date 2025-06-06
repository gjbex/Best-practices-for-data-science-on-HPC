#!/usr/bin/env -S bash -l
#SBATCH --account=lpt2_sysadmin
#SBATCH --cluster=wice
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=96

# fail immediately
set -e

# load modules
module load R/4.4.0-gfbf-2023a
module load GCCcore/12.3.0

# define the connfiguration space
max_cpus=96
nr_tasks=$max_cpus
ntasks_values=(1 2 4 6 8 12 18 24 32 48 60 72 96)
cpus_per_task_values=(1 2 4 8 12 24 48 96)

# define task parameters
size=2000
power=50

# create a function to run the computation to simplify running GNU parallel
function run_dgemm {
    ./dgemm.R --size $size --power $power --nr_cores 1
}
export -f run_dgemm

for ntasks in ${ntasks_values[@]}
do
    for cpus_per_task in ${cpus_per_task_values[@]}
    do
    if [[ $ntasks*$cpus_per_task -le max_cpus ]]
    then
        export OMP_NUM_THREADS=$cpus_per_task
        start_time=$(date +%s.%N)
        parallel -j $ntasks run_dgemm ::: $(seq $ntasks) > /dev/null
        end_time=$(date +%s.%N)
        elapsed_time=$(bc -q <<< "$end_time - $start_time")
        nr_items_per_task=$(( $nr_tasks/$ntasks ))
        total_time=$(bc <<< "$nr_items_per_task*$elapsed_time")
        echo "$ntasks,$cpus_per_task,$total_time"
    fi
    done
done

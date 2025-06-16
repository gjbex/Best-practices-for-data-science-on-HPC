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
module load R-bundle-CRAN/2023.12-foss-2023a

# define package installation directory and create if necessary
export R_LIBS_USER="${VSC_DATA}/R/${VSC_OS_LOCAL}/${VSC_ARCH_LOCAL}/${EBVERSIONR}"
mkdir -p "$R_LIBS_USER"

# set log file for installation
LOG_FILE="install_${VSC_OS_LOCAL}_${VSC_ARCH_LOCAL}_${EBVERSIONR}.log"

# start R and install packages
R_LIBS_USER=$R_LIBS_USER R --no-save &> "${LOG_FILE}" <<EOI
options(repos = c(CRAN = "https://cloud.r-project.org"))

install.packages("foreach")

EOI

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
    R_LIBS_USER=$R_LIBS_USER R --no-save ./dgemm.R --size $size --power $power --nr_cores 1
}
export -f run_dgemm

# switch sandbox off
# export RENV_CONFIG_SANDBOX_ENABLED=FALSE

# warm up phase
run_dgemm

# benchmark
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

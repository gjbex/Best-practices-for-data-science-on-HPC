#!/usr/bin/env -S bash -l
#SBATCH --account=lpt2_sysadmin
#SBATCH --cluster=wice
#SBATCH --partition=batch_sapphirerapids
#SBATCH --time=00:30:00
#SBATCH --cpus-per-task=4

# clean module environment and load relevant R version
module purge &> /dev/null
module load R-bundle-CRAN/2023.12-foss-2023a

# define package installation directory and create if necessary
export R_LIBS_USER="${VSC_DATA}/R/${VSC_OS_LOCAL}/${VSC_ARCH_LOCAL}/${EBVERSIONR}"
mkdir -p "$R_LIBS_USER"

# set log file for installation
LOG_FILE="install_${VSC_OS_LOCAL}_${VSC_ARCH_LOCAL}_${EBVERSIONR}.log"

# start R and install packages
R_LIBS_USER=$R_LIBS_USER R --no-save &> "${LOG_FILE}" <<EOI
options(repos = c(CRAN = "https://cloud.r-project.org"))

install.packages("dplyr")

EOI

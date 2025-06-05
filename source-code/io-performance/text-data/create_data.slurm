#!/usr/bin/env -S bash -l
#SBATCH --account=lpt2_sysadmin
#SBATCH --cluster=wice
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=10G
#SBATCH --time=12:00:00
#SBATCH --mail-user=geertjan.bex@uhasselt.be
#SBATCH --mail-type=END,FAIL

source $VSC_HOME/.conda_init.sh
mamba activate io_performance

./create_data.sh tmp_seq 10000 1024

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

# test whehter the conda initialization file exists, if so, source it
[ -e $VSC_HOME/.conda_init.sh ] && source $VSC_HOME/.conda_init.sh

# activate the conda environment
mamba activate io_performance

# set data set
if [ ! -n "$data" ]
then
    data=data/tmp_large_img
fi

(>&2 printf "\nnaive method\n")
time ./benchmark_naive.py "${data}_files.txt" --contig-read

(>&2 printf "\nHDF5 row-major method\n")
time ./benchmark_h5.py "${data}_row_major.h5" --contig-read --mode row_major

(>&2 printf "\nHDF5 column-major method\n")
time ./benchmark_h5.py "${data}_col_major.h5" --contig-read --mode col_major

(>&2 printf "\nHDF5 stacked method\n")
time ./benchmark_h5.py "${data}_stacked.h5" --contig-read --mode stacked

(>&2 printf "\ndatasets method\n")
time ./benchmark_dataset.py "${data}_tars_dataset" --contig-read

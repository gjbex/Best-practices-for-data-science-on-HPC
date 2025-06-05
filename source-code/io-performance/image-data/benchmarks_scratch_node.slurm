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

# test whether the conda initialization file exists, if so, source it
[ -e $VSC_HOME/.conda_init.sh ] && source $VSC_HOME/.conda_init.sh

# activate the conda environment
mamba activate io_performance

# set data set
if [ ! -n "$data" ]
then
    data=data/tmp_large_img
fi

# set number of reads
if [ ! -n "$nr_reads" ]
then
    nr_reads=10000
fi

# set directories
work_dir=$VSC_SCRATCH_NODE/work/
data_dir=$VSC_SCRATCH_NODE/work/data

# stage directory to local scratch and execute benchmarks from there
mkdir -p $data_dir
cp *.py $work_dir

(>&2 printf "\nnaive method\n")
# stage data
mkdir $data_dir/tmp_large_img/
time cp -r data/tmp_large_img/*.tiff $data_dir/tmp_large_img/
cp data/tmp_large_img_files.txt $data_dir
pushd $VSC_SCRATCH_NODE/work &> /dev/null
time ./benchmark_naive.py "${data}_files.txt" --nr-reads $nr_reads
popd &> /dev/null

(>&2 printf "\nHDF5 row-major method\n")
time cp data/tmp_large_img_row_major.h5 $data_dir
pushd $VSC_SCRATCH_NODE/work &> /dev/null
time ./benchmark_h5.py "${data}_row_major.h5" --nr-reads $nr_reads --mode row_major
popd &> /dev/null

(>&2 printf "\nHDF5 column-major method\n")
time cp data/tmp_large_img_col_major.h5 $data_dir
pushd $VSC_SCRATCH_NODE/work &> /dev/null
time ./benchmark_h5.py "${data}_col_major.h5" --nr-reads $nr_reads --mode col_major
popd &> /dev/null

(>&2 printf "\nHDF5 stacked method\n")
time cp data/tmp_large_img_stacked.h5 $data_dir
pushd $VSC_SCRATCH_NODE/work &> /dev/null
time ./benchmark_h5.py "${data}_stacked.h5" --nr-reads $nr_reads --mode stacked
popd &> /dev/null

(>&2 printf "\ndatasets method\n")
time cp -r data/tmp_large_img_tars_dataset/ $data_dir
pushd $VSC_SCRATCH_NODE/work &> /dev/null
time ./benchmark_dataset.py "${data}_tars_dataset" --nr-reads $nr_reads
popd &> /dev/null

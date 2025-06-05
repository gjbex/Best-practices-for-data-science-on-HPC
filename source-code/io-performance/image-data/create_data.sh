#!/usr/bin/env bash
#
# This script creates
#  - a directory for the data
#  - the individual image data files in that directory
#  - the individual numpy arrayfiles in that directory
#  - the HDF5 file that contains all the data
#
# To create the text files, the script uses the `../data-generation/create_text_data.py`
# script.  To create the text and index file for TextIndex, the script uses the
# `index_text_files.py` script.
#
# The scripts takes the following command line arguments:
#  - the name of the directory to write the files in,
#  - the number of text files to create.
#
# If the script is called with -h, it will display the usage and exit.

if [ "$1" == "-h" ]; then
    echo "Usage: $0 <directory> <number of image files>"
    exit 0
fi

# Check the number of arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <directory> <number of image files>"
    exit 1
fi

# Check that the directory does not exist
if [ -d "$1" ]; then
    echo "Directory $1 already exists"
    exit 1
fi

# Make script fail on first error
set -e

# Create the directory
mkdir -p "$1"

# Create the text files
(>&2 printf "Creating TIFFs")
workdir=$(pwd)
pushd ../data-generation
for i in $(seq -w 000001 $2)
do
    bash create_image_data.sh \
        $i \
        "$workdir/$1"/img_$i.tiff
done
popd

# Convert the TIFF image fils to numpy array files
(>&2 printf "Creating numpy arrays")
for file in $(ls $1/*.tiff); do
    python ../data-generation/convert_tiff_to_numpy.py $file
done

# Create the HDF5 files
for mode in row_major col_major stacked; do
    (>&2 printf "Creating HDF5 $mode file")
    python ../data-generation/concat_numpy_to_hdf5.py "$1/*.npy" "$1_$mode.h5" --mode $mode
done

# Create the TAR directory
mkdir ${1}_tars

# Create the TAR file
(>&2 printf "Creating TAR")
tar cf "${1}_tars/tmp_imgs.tar" ${1}/*.tiff

# Create dataset with pytorch tensors
(>&2 printf "Creating Pytorch tensor dataset")
../data-generation/convert_tiff_tars_to_pytorch_tensor_dataset.py "${1}_tars"

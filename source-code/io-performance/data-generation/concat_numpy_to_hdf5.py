#!/usr/bin/env python
#
# Script that reads numpy array files and adds them to an HDF5 file.
# The HDF5 file has a single dataset that contains all the images.
# All numpy arrays have the exact same shape and dtype.
#
# The script takes the following command line arguments:
#   - the file name pattern for globbing the numpy files
#  - the name of the HDF5 file
#  - the name of the dataset in the HDF5 file (optional, defaults to 'data')
#
# The script reads the first numpy file to determine the shape and dtype of the
# arrays. It then creates the HDF5 file and dataset and writes the first array.
# It then reads the remaining numpy files and appends them to the dataset.

import argparse
import h5py
import numpy as np
import pathlib

def main():
    parser = argparse.ArgumentParser(description='Concatenate numpy arrays to HDF5')
    parser.add_argument('file_pattern', type=str, help='File name pattern for numpy files')
    parser.add_argument('hdf5_file', type=str, help='Name of the HDF5 file')
    parser.add_argument('--dataset', type=str, default='data',
                        help='Name of the dataset in the HDF5 file')
    parser.add_argument('--mode', choices=['row_major', 'col_major', 'stacked'],
                        default='staced', help='How to concatenate the arrays')
    args = parser.parse_args()

    # Get the list of numpy files
    file_names = list(pathlib.Path().glob(args.file_pattern))

    # Read the first numpy file to determine shape and dtype
    with open(file_names[0], 'rb') as file:
        first_array = np.load(file)
        shape = first_array.shape
        dtype = first_array.dtype

    if args.mode == 'row_major':
        shape = (len(file_names),) + shape
        idx = lambda i: (i, slice(None), slice(None), slice(None))
    elif args.mode == 'col_major':
        shape = shape + (len(file_names),)
        idx = lambda i: (slice(None), slice(None), slice(None), i)
    else:
        shape = shape[:2] + (4*len(file_names),)
        idx = lambda i: (slice(None), slice(None), slice(4*i, 4*(i+1)))

    # Create the HDF5 file and dataset
    with h5py.File(args.hdf5_file, 'w') as h5_file:
        dataset = h5_file.create_dataset(args.dataset, shape=shape, dtype=dtype)

        # Append the arrays
        for file_nr, file_name in enumerate(file_names):
            with open(file_name, 'rb') as np_file:
                dataset[idx(file_nr)] = np.load(np_file)


if __name__ == '__main__':
    main()

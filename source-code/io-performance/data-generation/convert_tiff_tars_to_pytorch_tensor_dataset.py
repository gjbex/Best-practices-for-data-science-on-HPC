#!/usr/bin/env python
#
# Script to convert a TIFF file to a numpy array.
# The numpy array is saved as a .npy file.
# The script takes the name of the TIFF file as an argument and
# saves the numpy array as a .npy file with the same name.

import argparse
from datasets import load_dataset, load_from_disk
import pathlib
import torch

def main():
    parser = argparse.ArgumentParser(description='Convert a TAR files with TIFF images to a PyTorch tensor dataset')
    parser.add_argument('tar_file_dir', help='Name of directory that holds the TAR files')
    args = parser.parse_args()

    dataset = load_dataset('webdataset', data_dir=args.tar_file_dir)
    tar_dir_path = pathlib.Path(args.tar_file_dir)
    dataset = dataset.with_format('torch')
    dataset_path = tar_dir_path.parent / (tar_dir_path.name + '_dataset')
    dataset.save_to_disk(dataset_path)

if __name__ == '__main__':
    main()

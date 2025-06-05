#!/usr/bin/env python
#
# Script to run a benchmark of reading image files from an HDF5 file.
# The script takes the following command line arguments:
#   - the name of the HDF5 file to read from,
#   - the number of files to read

import argparse
from benchmark_utils import brightness
import h5py
import pathlib
import random

def access_modes(mode):
    if mode == 'row_major':
        idx = lambda i: (i, slice(None), slice(None), slice(None))
    elif mode == 'col_major':
        idx = lambda i: (slice(None), slice(None), slice(None), i)
    else:
        idx = lambda i: (slice(None), slice(None), slice(4*i, 4*(i+1)))
    return idx

def compute_nr_images(h5_file, mode):
    if mode == 'row_major':
        return h5_file['data'].shape[0]
    elif mode == 'col_major':
        return h5_file['data'].shape[-1]
    else:
        return h5_file['data'].shape[-1]//4

def run(h5_file_name, nr_reads, mode):
    avg_brightness = 0.0
    with h5py.File(h5_file_name, 'r') as h5_file:
        nr_images = compute_nr_images(h5_file, mode)
        idx = access_modes(mode)
        for _ in range(nr_reads):
            i = random.randrange(0, nr_images)
            img = h5_file['data'][idx(i)]
            avg_brightness += brightness(img)
    return avg_brightness/nr_reads

def run_single(h5_file_name, mode):
    avg_brightness = 0.0
    with h5py.File(h5_file_name, 'r') as h5_file:
        nr_images = compute_nr_images(h5_file, mode)
        idx = access_modes(mode)
        for i in range(nr_images):
            img = h5_file['data'][idx(i)]
            avg_brightness += brightness(img)
    return avg_brightness/nr_images

def run_contig(h5_file_name, mode):
    with h5py.File(h5_file_name, 'r') as h5_file:
        nr_images = compute_nr_images(h5_file, mode)
        data = h5_file['data'][...]
    avg_brightness = 0.0
    idx = access_modes(mode)
    for i in range(nr_images):
        avg_brightness += brightness(data[idx(i)])
    return avg_brightness/nr_images

def main():
    parser = argparse.ArgumentParser(description='Benchmark HDF5 method')
    parser.add_argument('h5_file', help='HRDF5 file to read')
    parser.add_argument('--dataset', default='data', help='Dataset to read')
    parser.add_argument('--mode', choices=['row_major', 'col_major', 'stacked'],
                        default='row_major', help='Dataset layout')
    read_mode = parser.add_mutually_exclusive_group(required=True)
    read_mode.add_argument('--nr-reads', type=int, help='Number of files to read')
    read_mode.add_argument('--single-read', action='store_true', help='Single read of all data')
    read_mode.add_argument('--contig-read', action='store_true', help='Read all data contiguously')
    args = parser.parse_args()

    if args.single_read:
        avg_brightness = run_single(args.h5_file, args.mode)
    elif args.contig_read:
        avg_brightness = run_contig(args.h5_file, args.mode)
    else:
        avg_brightness = run(args.h5_file, args.nr_reads, args.mode)
    print(f'Average brightness: {avg_brightness:.2f}')


if __name__ == '__main__':
    main()

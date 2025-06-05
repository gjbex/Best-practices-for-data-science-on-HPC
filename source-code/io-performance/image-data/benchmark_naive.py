#!/usr/bin/env python
#
# Script to run a benchmark of the naive image reading method.
# The script takes the following command line arguments:
#   - the path glob pattern to the image files to read from,
#   - the number of files to read using the `--nr-reads` option,
#   - a single read of the all the data, indicated by the `--single-read` option.
#
# The `--nr-reads` and the `--single-read` options are mutually exclusive.

import argparse
from benchmark_utils import brightness
import pathlib
import random
import skimage.io as io

def run(file_list_file_name, nr_reads):
    with open(file_list_file_name, 'r') as list_file:
        files = list_file.readlines()
    avg_brightness = 0.0
    for _ in range(nr_reads):
        idx = random.randrange(0, len(files))
        img = io.imread(files[idx].strip())
        avg_brightness += brightness(img)
    return avg_brightness/nr_reads

def run_single(file_list_file_name):
    with open(file_list_file_name, 'r') as list_file:
        files = list_file.readlines()
    avg_brightness = 0.0
    for file in files:
        img = io.imread(file.strip())
        avg_brightness += brightness(img)
    return avg_brightness/len(files)

def run_contig(file_list_file_name):
    with open(file_list_file_name, 'r') as list_file:
        files = list_file.readlines()
    data = [io.imread(file.strip()) for file in files]
    avg_brightness = 0.0
    for img in data:
        avg_brightness += brightness(img)
    return avg_brightness/len(data)

def main():
    parser = argparse.ArgumentParser(description='Benchmark naive method')
    parser.add_argument('file_list', help='List of data files to read')
    read_mode = parser.add_mutually_exclusive_group(required=True)
    read_mode.add_argument('--nr-reads', type=int, help='Number of files to read')
    read_mode.add_argument('--single-read', action='store_true', help='Single read of all data')
    read_mode.add_argument('--contig-read', action='store_true', help='Read the entire dataset once and store in memory')
    args = parser.parse_args()

    if args.single_read:
        avg_brightness = run_single(args.file_list)
    elif args.contig_read:
        avg_brightness = run_contig(args.file_list)
    else:
        avg_brightness = run(args.file_list, args.nr_reads)
    print(f'Average brightness: {avg_brightness:.2f}')


if __name__ == '__main__':
    main()

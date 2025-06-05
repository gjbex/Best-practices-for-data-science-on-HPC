#!/usr/bin/env python
#
# Script to run a benchmark of the text index method.
# The script takes the following command line arguments:
#   - the path to the dataset directory
#   - the number of files to read using `--nr-reads`
#   - single read option, the data is entirely read once, option `--single-read`
#   - contiguously read option, the data is read in entirely, and stored in memory,
#     option `--contig-read`
#
# `--nr-reads` and `--single-read` are mutually exclusive.

import argparse
from benchmark_utils import brightness
from datasets import load_from_disk
import random


def run(dataset_dir, nr_reads):
    dataset = load_from_disk(dataset_dir, keep_in_memory=True)

    avg_brightness = 0.0
    for _ in range(nr_reads):
        idx = random.randrange(0, len(dataset))
        img = dataset['train'][idx]['tiff']
        avg_brightness += brightness(img)
    return avg_brightness/nr_reads

def run_single(dataset_dir, keep_in_memory=False):
    dataset = load_from_disk(dataset_dir)

    avg_brightness = 0.0
    nr_images = len(dataset['train'])
    for i in range(nr_images):
        img = dataset['train'][i]['tiff']
        avg_brightness += brightness(img)
    return avg_brightness/nr_images

def run_contig(dataset_dir):
    return run_single(dataset_dir, keep_in_memory=True)

def main():
    parser = argparse.ArgumentParser(description='Benchmark Hugging Face dataset method')
    parser.add_argument('dataset_dir', help='Path to the text file to read from')
    read_mode = parser.add_mutually_exclusive_group(required=True)
    read_mode.add_argument('--nr-reads', type=int, help='Number of files to read')
    read_mode.add_argument('--single-read', action='store_true', help='Read the entire dataset once')
    read_mode.add_argument('--contig-read', action='store_true', help='Read the entire dataset once and store in memory')
    args = parser.parse_args()

    if args.single_read:
        avg_brightness = run_single(args.dataset_dir)
    elif args.contig_read:
        avg_brightness = run_contig(args.dataset_dir)
    else:
        avg_brightness = run(args.dataset_dir, args.nr_reads)
    print(f'Average brightness: {avg_brightness:.2f}')


if __name__ == '__main__':
    main()

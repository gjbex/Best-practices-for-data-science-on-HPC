#!/usr/bin/env python
#
# Script to run a benchmark of the text index method.
# The script takes the following command line arguments:
#   - the path to the dataset directory
#   - the number of files to read using `--nr-reads`
#   - single read option, the data is entirely read once, option `--single-read`
#
# `--nr-reads` and `--single-read` are mutually exclusive.

import argparse
from datasets import Dataset
import random


def run(dataset_dir, nr_reads):
    dataset = Dataset.load_from_disk(dataset_dir, keep_in_memory=True)

    total_chars = 0
    for _ in range(nr_reads):
        idx = random.randrange(0, len(dataset))
        text = dataset[idx]['text']
        total_chars += len(text)
    return total_chars

def run_single_read(dataset_dir):
    dataset = Dataset.load_from_disk(dataset_dir, keep_in_memory=True)

    total_chars = 0
    for i in range(len(dataset)):
        text = dataset[i]['text']
        total_chars += len(text)
    return total_chars

def main():
    parser = argparse.ArgumentParser(description='Benchmark Hugging Face dataset method')
    parser.add_argument('dataset_dir', help='Path to the text file to read from')
    read_mode = parser.add_mutually_exclusive_group(required=True)
    read_mode.add_argument('--nr-reads', type=int, help='Number of files to read')
    read_mode.add_argument('--single-read', action='store_true', help='Read the entire dataset once')
    args = parser.parse_args()

    if args.single_read:
        total_chars = run_single_read(args.dataset_dir)
    else:
        total_chars = run(args.dataset_dir, args.nr_reads)
    print(f'Total characters read: {total_chars}')


if __name__ == '__main__':
    main()

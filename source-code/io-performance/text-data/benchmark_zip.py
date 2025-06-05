#!/usr/bin/env python
#
# Script to run a benchmark of the text index method.
# The script takes the following command line arguments:
#   - the path to the zip files that holds all the text files to read from,
#   - the number of files to read

import argparse
import random
import zipfile


def run(zip_file, nr_reads):
    with zipfile.ZipFile(zip_file, 'r') as zip_file:
        names = zip_file.namelist()
        total_chars = 0
        for _ in range(nr_reads):
            name = random.choice(names)
            with zip_file.open(name, 'r') as file:
                text = file.read()
                total_chars += len(text)
    return total_chars

def run_single_read(zip_file):
    with zipfile.ZipFile(zip_file, 'r') as zip_file:
        names = zip_file.namelist()
        total_chars = 0
        for name in names:
            with zip_file.open(name, 'r') as file:
                text = file.read()
                total_chars += len(text)
    return total_chars

def main():
    parser = argparse.ArgumentParser(description='Benchmark ZIP method')
    parser.add_argument('zip_file', help='Path to the zip file to read from')
    read_mode = parser.add_mutually_exclusive_group(required=True)
    read_mode.add_argument('--nr-reads', type=int, help='Number of files to read')
    read_mode.add_argument('--single-read', action='store_true', help='Read the entire dataset once')
    args = parser.parse_args()

    if args.single_read:
        total_chars = run_single_read(args.zip_file)
    else:
        total_chars = run(args.zip_file, args.nr_reads)
    print(f'Total characters read: {total_chars}')


if __name__ == '__main__':
    main()

#!/usr/bin/env python
#
# Script to run a benchmark of the text index method.
# The script takes the following command line arguments:
#   - the path to the zip files that holds all the text files to read from,
#   - the number of files to read

import argparse
import random
import tarfile

def run(tar_file, nr_reads):
    with tarfile.TarFile(tar_file, 'r') as tar_file:
        names = tar_file.getnames()
        total_chars = 0
        for _ in range(nr_reads):
            name = random.choice(names)
            with tar_file.extractfile(name) as file:
                text = file.read()
                total_chars += len(text)
    return total_chars

def run_single_read(tar_file):
    with tarfile.TarFile(tar_file, 'r') as tar_file:
        names = tar_file.getnames()
        total_chars = 0
        for name in names:
            with tar_file.extractfile(name) as file:
                text = file.read()
                total_chars += len(text)
    return total_chars

def main():
    parser = argparse.ArgumentParser(description='Benchmark TAR method')
    parser.add_argument('tar_file', help='Path to the tar file to read from')
    read_mode = parser.add_mutually_exclusive_group(required=True)
    read_mode.add_argument('--nr-reads', type=int, help='Number of files to read')
    read_mode.add_argument('--single-read', action='store_true', help='Read the entire dataset once')
    args = parser.parse_args()

    if args.single_read:
        total_chars = run_single_read(args.tar_file)
    else:
        total_chars = run(args.tar_file, args.nr_reads)
    print(f'Total characters read: {total_chars}')


if __name__ == '__main__':
    main()

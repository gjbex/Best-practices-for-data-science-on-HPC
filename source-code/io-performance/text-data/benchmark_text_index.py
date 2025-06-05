#!/usr/bin/env python
#
# Script to run a benchmark of the text index method.
# The script takes the following command line arguments:
#   - the path to the concatenated text file to read from,
#   - the path to the index file (optinial, if not given, the
#     index file name is that of the text file with a .idx extension),
#   - the number of files to read

import argparse
import random
from text_index import TextIndex

def run(text_file, nr_reads, index_file=None, cache_size=128):
    if index_file is None:
        index_file = text_file + '.idx'

    text_index = TextIndex(text_file, index_file, max_cache_size=cache_size)

    total_chars = 0
    for _ in range(nr_reads):
        idx = random.randrange(0, len(text_index))
        text = text_index.read_text(idx)
        total_chars += len(text)
    text_index = TextIndex(text_file, index_file)
    return total_chars

def run_single_read(text_file, index_file=None, cache_size=0):
    if index_file is None:
        index_file = text_file + '.idx'

    text_index = TextIndex(text_file, index_file, max_cache_size=cache_size)

    total_chars = 0
    for i in range(len(text_index)):
        text = text_index.read_text(i)
        total_chars += len(text)
    return total_chars

def main():
    parser = argparse.ArgumentParser(description='Benchmark text index method')
    parser.add_argument('text_file', help='Path to the text file to read from')
    read_mode = parser.add_mutually_exclusive_group(required=True)
    read_mode.add_argument('--index-file', nargs='?', help='Path to the index file')
    read_mode.add_argument('--single-read', action='store_true', help='Read the entire dataset once')
    parser.add_argument('--nr-reads', type=int, default=10_000, help='Number of files to read')
    parser.add_argument('--cache-size', type=int, default=128, help='Size of the cache')
    args = parser.parse_args()

    total_chars = run(args.text_file, args.nr_reads, args.index_file, args.cache_size)
    print(f'Total characters read: {total_chars}')


if __name__ == '__main__':
    main()

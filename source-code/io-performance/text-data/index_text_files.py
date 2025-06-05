#!/usr/bin/env python
#
# Scrept that processes a directory of text files and concatentates them into a single file.
# Additionally, it creates an index file that lists the name of each file, as well as 
# the number of bytes in each file.
#
# Usage: python index_text_files.py <input_pattern> <output_file>
#
# <input_pattern> is a glob pattern that specifies the input files in a format that
# can be used by the pathlib.Path.glob() method.
#
# <output_file> is the name of the file to which the concatenated text will be written.
# The index file will be written to <output_file>.idx.
#
# Command line arguments are handled using argparse.

import argparse
import pathlib

def main():
    parser = argparse.ArgumentParser(description='Concatenate text files and create an index file')
    parser.add_argument('input_pattern', help='Input file glob pattern')
    parser.add_argument('output_file', help='Output file')
    args = parser.parse_args()

    input_files = pathlib.Path().glob(args.input_pattern)
    with open(args.output_file, 'wb') as output_file:
        with open(args.output_file + '.idx', 'w') as index_file:
            for file in input_files:
                with open(file, 'r') as input_file:
                    data = input_file.read().encode('utf-8')
                    output_file.write(data)
                    index_file.write(f'{file.name}\t{len(data)}\n')


if __name__ == '__main__':
    main()

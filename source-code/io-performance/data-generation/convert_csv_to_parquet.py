#!/usr/bin/env python

# Script that converts a CSV file to a Parquet file using Polars (lazy) API.
# The script takes a CSV file name as a positional argument.
# It optionally takes a Parquet file name as option --output.
# The default output file name is the input file name with the extension changed to .parquet.
# The script uses the pathlib library to handle file paths.

import argparse
import pathlib
import polars as pl

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('input', help='Input CSV file')
    parser.add_argument('--output', help='Output Parquet file')
    args = parser.parse_args()

    output = args.output
    if output is None:
        # Change the extension of the input file from .csv to .parquet
        output = pathlib.Path(args.input).with_suffix('.parquet')

    df = pl.scan_csv(args.input)
    df.sink_parquet(output)
    df.collect()

if __name__ == '__main__':
    main()

#!/usr/bin/env python

# Script that concatenates a CSV file to a Parquet file using Polars (lazy) API.
# The script takes a CSV file name and a parquet file name as positional arguments.
# The original parquet file is modified.
# The script uses the pathlib library to handle file paths.

import argparse
import pathlib
import polars as pl

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('csv_file', help='CSV file')
    parser.add_argument('parquet_file', help='Parquet file to concatenate to')
    args = parser.parse_args()

    parquet_file = pathlib.Path(args.parquet_file)
    tmp_parquet_file = parquet_file.with_suffix('.tmp.parquet')
    if parquet_file.exists():
        csv_df = pl.scan_csv(args.csv_file)
        parquet_df = pl.scan_parquet(args.parquet_file)
        df = pl.concat([parquet_df, csv_df])
        df.sink_parquet(tmp_parquet_file)
        df.collect()
        parquet_file.unlink()
        tmp_parquet_file.rename(parquet_file)
    else:
        csv_df = pl.scan_csv(args.csv_file)
        csv_df.sink_parquet(parquet_file)
        csv_df.collect()


if __name__ == '__main__':
    main()

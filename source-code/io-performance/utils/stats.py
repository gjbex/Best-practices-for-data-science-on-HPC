#!/usr/bin/env python
#
# Python script that illustrates when file stats change under certain
# operations.  Specifically, the script opens a file for read, and
# does a periodic read followed by a stat of the file.  Similarly, the
# script opens a file for write, and does a periodic write followed by
# a stat of the file.  The stats are writting to standard output.  The
# times are dsiplayed as YYYY-MM-DD HH:MM:SS.
#
# The script takes the following arguments:
#   - <file-name>: the name of the file to open
#   - --mode <mode>: the mode to open the file in (r or w)
#   - --nr-iops <number of operations>: the number of operations to perform
#   - --period <period>: the period between reads or writes in seconds
#   - --flush: flush the file after each write

import argparse
import pathlib
import time


def format_times(stat):
    atime = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(stat.st_atime))
    mtime = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(stat.st_mtime))
    ctime = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(stat.st_ctime))
    return atime, mtime, ctime

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('file_name', type=pathlib.Path, help='file name')
    parser.add_argument('--mode', choices=['r', 'w'], help='mode')
    parser.add_argument('--flush', action='store_true', help='flush after each write')
    parser.add_argument('--nr-iops', type=int, default=10, help='number of operations')
    parser.add_argument('--period', type=float, default=1.0, help='period in seconds')
    args = parser.parse_args()

    if args.mode == 'r':
        with open(args.file_name, 'r') as f:
            for _ in range(args.nr_iops):
                f.read(1)
                atime, mtime, ctime = format_times(args.file_name.stat())
                print(f'access time: {atime}, modification time: {mtime}, change time: {ctime}')
                time.sleep(args.period)
    elif args.mode == 'w':
        with open(args.file_name, 'w') as f:
            for _ in range(args.nr_iops):
                f.write('a')
                if args.flush:
                    f.flush()
                atime, mtime, ctime = format_times(args.file_name.stat())
                print(f'access time: {atime}, modification time: {mtime}, change time: {ctime}')
                time.sleep(args.period)
    atime, mtime, ctime = format_times(args.file_name.stat())
    print(f'access time: {atime}, modification time: {mtime}, change time: {ctime}')


if __name__ == '__main__':
    main()

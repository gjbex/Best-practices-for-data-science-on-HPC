#!/usr/bin/env python

import argparse
import random


def create_random_keys(nr_keys: int, max_key_len: int) -> list:
    keys = []
    for _ in range(nr_keys):
        key_len = random.randint(1, max_key_len)
        key = ''.join(random.choices('abcdefghijklmnopqrstuvwxyz', k=key_len))
        keys.append(key)
    return keys

def create_rows(file, nr_rows: int, keys: list, sep : str=';', min_value : float=0.0, max_value : float=1.0) -> None:
    for _ in range(nr_rows):
        key = random.choice(keys)
        value = random.uniform(min_value, max_value)
        print(f'{key}{sep}{value}', file=file)



if __name__ == '__main__':
    arg_parser = argparse.ArgumentParser(description='Generate a file with a billion rows')
    arg_parser.add_argument('--output', type=str, required=True, help='Output file')
    arg_parser.add_argument('--nr-keys', type=int, default=20, help='Number of keys')
    arg_parser.add_argument('--max-key-len', type=int, default=15, help='Maximum key length')
    arg_parser.add_argument('--nr-rows', type=int, default=1_000, help='Number of rows')
    arg_parser.add_argument('--sep', type=str, default=';', help='Separator')
    arg_parser.add_argument('--min-value', type=float, default=0.0, help='Minimum value')
    arg_parser.add_argument('--max-value', type=float, default=1.0, help='Maximum value')
    arg_parser.add_argument('--seed', type=int, default=42, help='Random seed')
    args = arg_parser.parse_args()
    
    random.seed(args.seed)
    keys = create_random_keys(args.nr_keys, args.max_key_len)
    with open(args.output, 'w') as f:
        create_rows(f, args.nr_rows, keys, args.sep, args.min_value, args.max_value)

#!/usr/bin/env python
#
# Simple Python script that computes the values of the cosine function
# in the range [0, 2*pi]. It takes the following command line arguments:
#  -n, --num-points <int>   Number of points to compute (default: 100)
#  -A, --amplitude <float>  Amplitude of the cosine function (default: 1.0)
#  -f, --frequency <float>  Frequency of the cosine function (default: 1.0)
#  -o, --output <file>      Output file to write results to (default: stdout)
#  -p, --plot-file <file>   Image file to save the plot (default: none)
#
# `argparse is used to parse the command line arguments. The script uses numpy
# to compute the cosine values and matplotlib to plot.

import argparse
import matplotlib.pyplot as plt
import numpy as np
import sys

def parse_args():
    parser = argparse.ArgumentParser(description='Compute cosine values.')
    parser.add_argument('-n', '--num-points', type=int, default=100, help='Number of points to compute')
    parser.add_argument('-A', '--amplitude', type=float, default=1.0, help='Amplitude of the cosine function')
    parser.add_argument('-f', '--frequency', type=float, default=1.0, help='Frequency of the cosine function')
    parser.add_argument('-o', '--output', type=argparse.FileType('w'), default=sys.stdout, help='Output file to write results to [default: stdout]')
    parser.add_argument('-p', '--plot-file', type=str, help='Image file to save plot to')
    return parser.parse_args()

def compute_cosine(n, A, f):
    x = np.linspace(0.0, 2.0*np.pi, n)
    y = A*np.cos(f*x)
    return x, y

def save_results(x, y, out_file):
    for xi, yi in zip(x, y):
        print(f'{xi:.6f} {yi:.6f}', file=out_file)

def plot_cosine(x, y, image_file):
    plt.plot(x, y)
    plt.title('Cosine Function')
    plt.xlabel(r'$\theta$')
    plt.ylabel(r'$\cos(\theta)$')
    plt.savefig(image_file)

def main():
    args = parse_args()

    # Compute cosine values
    x, y = compute_cosine(args.num_points, args.amplitude, args.frequency)

    # Save results (to file or stdout)
    save_results(x, y, args.output)

    # Plot the cosine function and save to file if specified
    if args.plot_file:
        plot_cosine(x, y, args.plot_file)

if __name__ == '__main__':
    main()

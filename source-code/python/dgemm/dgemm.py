#!/usr/bin/env python

import argparse
import numpy as np


def init_matrix(n: int) -> np.ndarray:
    ''' Initialize a square matrix of size n x n with random values.

    Parameters
    ----------
    n : int
        The size of the matrix.
    Returns
    -------
    np.ndarray
        A square matrix of size n x n with random values.
    '''
    return np.random.normal(size=(n, n))


def matrix_power(A: np.ndarray, p: int) -> np.ndarray:
    ''' Compute the matrix A raised to the power of p using repeated squaring.

    Parameters
    ----------
    A : np.ndarray
        The input square matrix.
    p : int
        The exponent to which the matrix is raised.
    Returns
    -------
    np.ndarray
        The matrix A raised to the power p.
    '''
    if p < 0:
        raise ValueError('Negative powers are not supported.')
    elif p == 0:
        return np.eye(A.shape[0])  # Identity matrix
    elif p == 1:
        return A

    result = np.eye(A.shape[0])
    while p > 0:
        if p % 2 == 1:
            result = np.dot(result, A)
        A = np.dot(A, A)
        p //= 2
    return result


def matrix_power_naive(A: np.ndarray, p: int) -> np.ndarray:
    ''' Compute the matrix A raised to the power of p using naive multiplication.

    Parameters
    ----------
    A : np.ndarray
        The input square matrix.
    p : int
        The exponent to which the matrix is raised.
    Returns
    -------
    np.ndarray
        The matrix A raised to the power p.
    '''
    if p < 0:
        raise ValueError('Negative powers are not supported.')
    elif p == 0:
        return np.eye(A.shape[0])  # Identity matrix
    elif p == 1:
        return A

    result = A.copy()
    for _ in range(1, p):
        result = np.dot(result, A)
    return result


def max_diagonal(A: np.ndarray) -> float:
    ''' Compute the maximum value on the diagonal of the matrix.

    Parameters
    ----------
    A : np.ndarray
        The input square matrix.
    Returns
    -------
    float
        The maximum value on the diagonal of the matrix.
    '''
    return np.max(np.diag(A))


def parse_args():
    ''' Parse command line arguments.

    Returns
    -------
    argparse.Namespace
        Parsed command line arguments.
    '''
    parser = argparse.ArgumentParser(
            description='Matrix exponentiation using repeated squaring.'
            )
    parser.add_argument('--size', type=int, required=True,
                        help='Size of the square matrix (n x n).')
    parser.add_argument('--power', type=int, required=True,
                        help='Exponent to which the matrix is raised.')
    parser.add_argument('--mode', default='naive', choices=['naive', 'smart', 'numpy'],
                        help='Method to compute the matrix power: '
                             '"naive" for naive multiplication, '
                             '"smart" for repeated squaring, or '
                             '"numpy" for NumPy built-in function.')
    parser.add_argument('--seed', type=int, default=1234,
                        help='Random seed for reproducibility.')
    return parser.parse_args()


def main():
    args = parse_args()

    # Set the random seed for reproducibility
    np.random.seed(args.seed)

    # Initialize the matrix
    A = init_matrix(args.size)

    # Compute the matrix power
    if args.mode == 'numpy':
        result = np.linalg.matrix_power(A, args.power)
    elif args.mode == 'smart':
        result = matrix_power(A, args.power)
    else:
        result = matrix_power_naive(A, args.power)

    # Compute the maximum diagonal value
    max_diag_value = max_diagonal(result)

    # Print the result
    print(max_diag_value)


if __name__ == '__main__':
    main()

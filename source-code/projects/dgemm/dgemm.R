#!/usr/bin/env -S Rscript --no-save --no-restore

# This script generates random matrices and computes the
# matrix power by repeated matrix multiplication.  The
# minimum and maximum diagonal elements of the resulting
# matrix are printed written as a table to stdout.
#
# - nr_matrices: number of matrices to generate
# - matrix_size: size of the square matrices (number of rows)
# - power: number of matrix multiplications to perform
# - seed: random seed
# - nr_cores: number of cores to use

library(foreach)
library(optparse)

# Parse command line arguments
option_list <- list(
                    make_option(c("-n", "--nr_matrices"), type="integer", default=10,
                                help="number of matrices to generate"),
                    make_option(c("-s", "--matrix_size"), type="integer", default=1000,
                                help="size of the square matrices (number of rows)"),
                    make_option(c("-p", "--power"), type="integer", default=10,
                                help="number of matrix multiplications to perform"),
                    make_option(c("-r", "--seed"), type="integer", default=1234,
                                help="random seed"),
                    make_option(c("-c", "--nr_cores"), type="integer", default=1,
                                help="number of cores to use")
)
opt <- parse_args(OptionParser(option_list=option_list))

# Set random seed
set.seed(opt$seed)

# if number of cores is greater than 1, use parallel processing
if (opt$nr_cores > 1) {
    library(doParallel)
    # cl <- makeCluster(opt$nr_cores)
    # registerDoParallel(cl)
    registerDoParallel(opt$nr_cores)
}

# Function to generate a random matrix
generate_matrix <- function(size) {
    matrix(rnorm(size^2), nrow=size)
}

# Function to compute the matrix power
matrix_power <- function(A, power) {
    result <- A
    for (i in 1:(power-1)) {
        result <- result %*% A
    }
    result
}

# Function to compute the minimum and maximum diagonal elements of a matrix
min_max_diagonal <- function(A) {
    diag_A <- diag(A)
    c(min(diag_A), max(diag_A))
}

# Function to peroform the entire computation for a single matrix
compute_matrix <- function(size, power) {
    A <- generate_matrix(size)
    result <- matrix_power(A, power)
    min_max_diagonal(result)
}

# Perform the computation for multiple matrices, in parallel if specified,
# and store the results in a list
results <- if (opt$nr_cores > 1) {
    foreach(i=1:opt$nr_matrices, .combine='rbind') %dopar% {
#        cat("Computing matrix ", i, " at ", Sys.time(), "\n")
        compute_matrix(opt$matrix_size, opt$power)
    }
} else {
    foreach(i=1:opt$nr_matrices, .combine='rbind') %do% {
        compute_matrix(opt$matrix_size, opt$power)
    }
}

# Print the results as a table
if(opt$nr_matrices == 1) {
    print(results)
} else {
    results_df <- as.data.frame(results)
    colnames(results_df) <- c("Min Diagonal Element", "Max Diagonal Element")
    print(results_df)
}

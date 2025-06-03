#' Julia set computation, serial implementation
#'
#' @docType package
#'

library(foreach)

#' Function to compute the complex number grid
#'
#' @param width Width of the image
#' @param height Height of the image
#' @return complex number matrix
#' @export
compute_Z <- function(width, height) {
    Z <- matrix(, nrow=height, ncol=width)
    delta_row <- 4.0/(height - 1)
    delta_col <- 4.0/(width - 1)
    foreach (j=1:width) %do% {
        for (i in 1:height) {
            Z[i, j] <- complex(real=-2.0 + (i - 1)*delta_row,
                               imaginary=-2.0 + (j - 1)*delta_col)
        }
    }
    return(Z)
}

#' Function to compute the Julia set
#'
#' @param Z Complex number grid
#' @param iterations Number of iterations
#' @param threshold Threshold for escape condition
#' @param c Complex number constant
#' @return Julia set image as an integer matrix
#' @export
compute_julia_set <- function(Z, iterations, threshold, c) {
    image <- matrix(0, nrow=nrow(Z), ncol=ncol(Z))
    foreach (j=1:ncol(Z)) %do% {
        for (i in 1:nrow(Z)) {
            for (iteration in 1:iterations) {
                if (abs(Z[i, j]) > threshold) {
                    break
                }
                image[i, j] <- iteration
                Z[i, j] <- Z[i, j]^2 + c
            }
        }
    }
    return(image)
}

#' Function to compute the Julia set image
#'
#' This is a wrapper function that calls the `compute_Z` and
#' `compute_julia_set` functions so that the computation can be timed using
#' microbenchmark.
#'
#' @param width Width of the image
#' @param height Height of the image
#' @param iterations Number of iterations
#' @param threshold Threshold for escape condition
#' @param c Complex number constant
#' @return Julia set image as an integer matrix
#' @export
compute_image <- function(width, height, iterations, threshold, c) {
    Z <- compute_Z(width, height)
    image <- compute_julia_set(Z, iterations, threshold, c)
    return(image)
}

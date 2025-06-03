#' Julia set computation, serial implementation
#'
#' @docType package
#'

#' Function to compute the complex number grid
#'
#' @param width Width of the image
#' @param height Height of the image
#' @return complex number matrix
#' @export
compute_Z <- function(width, height) {
    x <- seq(-2.0, 2.0, length.out=width)
    y <- seq(-2.0, 2.0, length.out=height)
    return(outer(x, 1i*y, "+"))
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
    for (iteration in 1:iterations) {
        image <- image + (abs(Z) <= threshold)
        Z <- Z^2 + c
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

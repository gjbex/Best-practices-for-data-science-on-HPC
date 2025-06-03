#' Julia set utility functions
#'
#' @docType package
#'

# Load the necessary libraries
library(doParallel)
library(optparse)

#' Function to parse command line arguments
#'
#' @return list of command line arguments
#' @export
argument_parser <- function() {
    option_list <- list(
        make_option(c("--real"), type="double", default=-0.8,
                    help="Real part of the complex number"),
        make_option(c("--imag"), type="double", default=0.156,
                    help="Imaginary part of the complex number"),
        make_option(c("--width"), type="integer", default=200,
                    help="Width of the image"),
        make_option(c("--height"), type="integer", default=200,
                    help="Height of the image"),
        make_option(c("--iterations"), type="integer", default=255,
                    help="Number of iterations"),
        make_option(c("--threshold"), type="double", default=2.0,
                    help="Threshold for escape condition"),
        make_option(c("--benchmark"), action="store_true", default=FALSE,
                    help="Benchmark the computation"),
        make_option(c("--times"), type="integer", default=1,
                    help="Number of times for microbenchmark"),
        make_option(c("--profile"), action="store_true", default=FALSE,
                    help="Profile the computation"),
        make_option(c("--interval"), type="double", default=0.02,
                    help="Duration of the profiling interval (s)"),
        make_option(c("--implementation"), type="character", default="julia_serial.R",
                    help="Julia set implementation file to source"),
        make_option(c("--parallel"), action="store_true", default=FALSE,
                    help="Run the computation in parallel"),
        make_option(c("--nr_cores"), type="integer", default=2,
                    help="Number of cores to use")
    )
    opt_parser <- OptionParser(option_list=option_list)
    opt <- parse_args(opt_parser)
    return(opt)
}

#' Function to set up parallel backend
#'
#' @param num_cores Number of cores to use
#' @export
setup_parallel_backend <- function(num_cores) {
    registerDoParallel(cores=num_cores)
}


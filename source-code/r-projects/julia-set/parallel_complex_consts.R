#!/usr/bin/env -S Rscript --no-save --no-restore
#
# R script to perform the computation of the Julia set for randomly
# genrated complex constants in parallel.  Each image is saved to a
# file with a unique name.  The size of the images is identical.
#
# Command line arguments:
#   --nr_constants_<int>  Number of complex constants to generate
#   --width <int>  Width of the image
#   --height <int>  Height of the image
#   --iterations <int>  Maximum number of iterations
#   --threshold <float>  Threshold for the escape condition
#   --implementation <string>  Implementation to use
#   --output_dir <string>  Directory to save the images
#   --n_cores <int>  Number of cores to use

# Load libraries
suppressPackageStartupMessages(library(doParallel))
library(optparse)

# Parse command line arguments
option_list <- list(
  make_option("--nr_constants", type="integer", default=10,
              help="Number of complex constants to generate"),
  make_option("--width", type="integer", default=200,
              help="Width of the image"),
  make_option("--height", type="integer", default=200,
              help="Height of the image"),
  make_option("--iterations", type="integer", default=1000,
              help="Maximum number of iterations"),
  make_option("--threshold", type="double", default=2.0,
              help="Threshold for the escape condition"),
    make_option("--implementation", type="character", default="julia_serial.R",
                help="Implementation to use"),
  make_option("--output_dir", type="character", default="output",
              help="Directory to save the images"),
  make_option("--nr_cores", type="integer", default=2,
              help="Number of cores to use")
)
opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

# Set the number of cores
registerDoParallel(cores=opt$nr_cores)

# Source the implementation
source(opt$implementation)

# Generate random complex constants
constants <- complex(rnorm(opt$nr_constants), rnorm(opt$nr_constants))

# if output directory does not exist, create it
if (!dir.exists(opt$output_dir)) {
    dir.create(opt$output_dir)
}

# Generate the images
foreach(i=1:opt$nr_constants) %dopar% {
    filename <- sprintf("%s/julia_%03d.txt", opt$output_dir, i)
    image <- compute_image(opt$width, opt$height, opt$iterations, opt$threshold, constants[i])
    write.table(image, file=filename, row.names=FALSE, col.names=FALSE)
} |> invisible()

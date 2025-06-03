#!/usr/bin/env -S Rscript --no-save --no-restore
#
# R script to perform the computation of the Julia set for randomly
# genrated complex constants in parallel.  Each image is saved to a
# file with a unique name.  The size of the images is identical.
#
# Command line arguments:
#   --nr_sizes_<int>  Number of image sizes to generate
#   --size_increment <int>  Increment of the image size
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
                    make_option("--nr_sizes", type="integer", default=5,
                                help="Number of image sizes to generate"),
                    make_option("--size_increment", type="integer", default=50,
                                help="Increment of the image size"),
                    make_option("--width", type="integer", default=50,
                                help="Width of the image"),
                    make_option("--height", type="integer", default=50,
                                help="Height of the image"),
                    make_option("--iterations", type="integer", default=255,
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
widths <- seq(opt$width, length.out=opt$nr_sizes, by=opt$size_increment)
heights <- seq(opt$height, length.out=opt$nr_sizes, by=opt$size_increment)

# If output directory does not exist, create it
if (!dir.exists(opt$output_dir)) {
    dir.create(opt$output_dir)
}

# Define the complex constant
c <- complex(real=rnorm(1), imaginary=rnorm(1))

# Generate the images
foreach(width=widths, height=heights, i=1:length(widths)) %dopar% {
    filename <- sprintf("%s/julia_%03d.txt", opt$output_dir, i)
    image <- compute_image(width, height, opt$iterations, opt$threshold, c)
    write.table(image, file=filename, row.names=FALSE, col.names=FALSE)
} |> invisible()

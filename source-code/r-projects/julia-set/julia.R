#!/usr/bin/env -S Rscript --no-save --no-restore

# This is a script that will compute the Julia set for a
# given:
#   - c complex number (real and imaginary parts), default
#     value is -0.8+0.156i
#   - width and height of the image, default is 200
#   - number of iterations, default is 255
#   - threshold for the escape condition, default is 2.0
#   - benchmark whether to run the script for benchmarking, default is FALSE
#     the Julia set will not be printed if benchmark is TRUE
#   - times number of times for microbenchmark, default is 1
#   - profile whether to run the script for profiling, default is FALSE
#     the Julia set will be printed if profile is TRUE, profiling
#     is only done in non-benchmark mode, output is written to
#     "Rprof.out" file, summary is printed to standard output
#   - interval duration of the profiling interval, default is 0.02
#   - implementation file to source, default is "julia_serial.R"
#   - parallel whether to run the script in parallel, default is FALSE
#   - nr_cores number of cores to use, default is 2
#
# These values are passed as command line arguments, e.g.,
#  Rscript julia.R --real -0.8 --imag 0.156 --width 800 --height 800 \
#                  --iterations 1000 --threshold 100
# If an argument is not provided, the default value is used.
#
# For each pixel in the image, the script computes the Julia set
# value and the number of iterations needed to escape the threshold.
# The result is written to standard error in text format, each line
# representing a row of the values.
#
# The iterarative formula is z = z^2 + c, where z is the complex
# number for the pixel and c is the constant value.

# load the required libraries
library(microbenchmark)

# source the utility functions
source("julia_utils.R")

# handle command line arguments
opt <- argument_parser()

# set up parallel backend if required
if (opt$parallel) {
    setup_parallel_backend(opt$nr_cores)
}

# source the implementation file
source(opt$implementation)

# do the computation
if (opt$benchmark) {
    # Run the computation multiple times for benchmarking
    results <- microbenchmark(compute_image(opt$width, opt$height,
                                            opt$iterations, opt$threshold,
                                            complex(opt$real, opt$imag)),
                              times=opt$times)
    print(results)
} else {
    # when profiling, activate the profiler
    if (opt$profile) {
        Rprof()
    }
    # compute the Julia set
    julia_set <- compute_image(opt$width, opt$height, opt$iterations,
                               opt$threshold, complex(opt$real, opt$imag))
    # write the result to standard error
    write.table(julia_set, row.names=FALSE, col.names=FALSE, file=stderr())
    # when profiling, deactivate the profiler and print the summary
    if (opt$profile) {
        Rprof(NULL)
        summaryRprof()
    }
}

# Examples

Example code used in this training.


## What is it?

1. `hello-world`: submitting trivial R scripts as batch jobs on an HPC system.
1. `weather-analysis`: analyzing weather data using R, illustrates I/O.
1. `dgemm`: matrix-matrix multiplication using a BLAS library.
1. `julia-set`: Julia set computation parallelized using serveral
   parallelization packages.    


## Requirements

* R 4.x
* optargs R package to handle command line arguments
* microbenchmark R package to benchmark code
* foreach R package to parallelize code
* doParallel R package to parallelize code

For some benchmark jobs

* [hyperfine](https://github.com/sharkdp/hyperfine)

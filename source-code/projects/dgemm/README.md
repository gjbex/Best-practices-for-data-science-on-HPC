# DGEMM

This is a script to highlight the dangers of multi-level parallelism in
embarrassingly parallel applications. R's matrix multiplication is parallelized
using BLAS, which is parallelized using OpenMP. This script uses a parallel
`foreach` to do the computation for multiple matrices in parallel.


## What is it?

1. Environment
    - `.Rprofile`: R profile file that activates `renv`.
    - `renv.lock`: lock file for the R environment.
    - `renv`: directory with the R environment.
      - `activate.R`: script to activate the R environment.
      - `settings.json`: settings file for the R environment.
1. `dgemm.R`: script that performs multiple matrix multiplications using R's
   `foreach` package.
1. walltime and memory
   - `memory_and_walltime.slurm`: script to run `dgemm.R` with varying matrix
     sizes and powers to raise to as command line arguments to `sbatch` to
     measure memory usage and walltime.
   - `submit_memory_and_walltime_jobs.sh`: script to submit jobs to measure
     memory usage and walltime for different matrix sizes and powers to raise
     to.  It will create a text file with job IDs and the respective matrix
     sizes and powers to raise to.
   - `get_info_memory_and_walltime.sh`: script to get the memory usage and
     walltime for the jobs submitted by `submit_memory_and_walltime_jobs.sh`.
     It will create a text file with the job IDs, matrix sizes, powers to raise
     to, memory usage and walltime based on the file created by
     `submit_memory_and_walltime_jobs.sh`.  *Note*: this script should be run
     on the cluster's (login) node as it uses `sacct` to collect the data.
   - `memory_and_walltime_info.txt`: text file with the job IDs, matrix sizes,
     powers to raise to, memory usage and walltime based on the file created by
     `get_info_memory_and_walltime.sh`.
   - `slurm-62199209_out_of_walltime.out`: output of a job that ran out of
     walltime.
   - `slurm-62199210_out_of_memory.out`: output of a job that ran out of
     memory.
1. `benchmarking efficiency`
   1. multithreading
      - `single_core.slurm`: runs `dgemm.R` with `cpus_per_task=1` and
        `--nr_cores 1`.  Output is written to `slurm-single_core.out`.
      - `multicore.slurm`: runs `dgemm.R` with `cpus_per_task=4`,
        `OMP_NUM_THREADS=4` and `--nr_cores 1`.
      - `multicore_benchmark.slurm`: runs `dgemm.R` using `hyperfine` with
        `cpus_per_task=96`, `OMP_NUM_THREADS` ranging from 1 to 96 and
        `nr_cores 1`.  Output is in `slurm-multicore_benchmark.out`.
   1. embarrassingly parallel workloads
      - `parallel_benchmark.slurm`: runs `dgemm.R` using `hyperfine` with
        `cpus_per_task=96`, `OMP_NUM_THREADS` unspecified and `--nr_cores`
        varying from 1 to 96.  Output is in `slurm-parallel_benchmark.out`.
      - `parallel_omp_num_threads_benchmark.slurm`: runs `dgemm.R` using
        `hyperfine` with `cpus_per_task=96`, `OMP_NUM_THREADS` set such that
        when `--nr_cores` varies from 1 to 96, all the cores are used. Output
        is in `slurm-parallel_omp_num_threads_benchmark.out`.
   1. parallelization (`foreach ... %dopar%`)
      - `parallel_single_core.slurm`: runs `dgemm.R` with `cpus_per_task=4`,
        `OMP_NUM_THREADS=1` and `--nr_cores 4`.  output is in
        `slurm-parallel_single_core.out`.
      - `parallel_multicore.slurm`: runs 'dgemm.R` with `cpus_per_task=4`,
        `OMP_NUM_THREADS=2` and `--nr_cores 2`.  Output is in
        `slurm-parallel_multicore.out`.
      - `multicore_gnu_parallel.slurm`: runs `dgemm.R` using GNU `parallel`
        with `cpus_per_task=96`, number of parallel work items increasing from
        1 to 96, `OMP_NUM_THREADS` set to 2. Output is in
        `slurm-multicore_gnu_parallel.out`.

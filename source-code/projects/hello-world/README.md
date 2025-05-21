# Hello world

These are some examples of running trivial R scripts as batch jobs on an HPC
cluster that uses the Slurm scheduler.


## What is it?

1. Environment
    - `.Rprofile`: R profile file that activates `renv`.
    - `renv.lock`: lock file for the R environment.
    - `renv`: directory with the R environment.
      - `activate.R`: script to activate the R environment.
      - `settings.json`: settings file for the R environment.
1. Trivial R script
    - `hello_world.R`: a trivial R script that prints "Hello, world <hostname>
      !" to the standard output. `<hostname>` is the name of the compute node
      the script is running on.
    - `hello_world.slurm`: a job script that loads the R module, and runs the
      `hello_world.R` script.
    - `slurm-hello_world.out`: sample output file of the job.
1. Command line arguments with `optparse`
    - `hello_world_cla.R`: a trivial R script that prints a greeting message to
      the standard output, using command line arguments.
    - `hello_world_cla.slurm`: a job script that loads the R module, and runs
      the `hello_world_cla.R` script with command line arguments.
    - `slurm-hello_world_cla.out`: sample output file of the job.

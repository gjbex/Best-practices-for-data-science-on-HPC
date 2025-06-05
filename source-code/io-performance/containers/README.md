# Containers

Running Python or R script that have many dependencies leads to excessive loads
on HPC file systems. To avoid this, we can use containers to package the
dependencies and run the script in a container. This way, load on the file
system is significantly reduced.


## What is it?

1. `conda`: example Apptainer recipe and environment description for
   conda to set up a containder with the necessary dependencies.

# Conda containers

Tool to create apptainer images containing a conda environment.


## What is it?

1. `create_conda_container.slurm`: Slurm script to create an apptainer
   image with a conda environment.


## How to use it?

To create an image containing a conda environment, run the following command:

```bash
$ sbatch --account=my_credit_account --cluster=my_cluster \
    create_conda_container.slurm \
        --env environment.yml \
        --sif my_container.sif
```

Here, `environment.yml` is a conda environment file that specifies the
environment, typically created from an existing conda environment using the
command:

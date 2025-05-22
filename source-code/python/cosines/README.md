# Running a Python script

This example illustrates how to run a simple Python script on an HPC cluster
using the Slurm workload manager. The script generates a plot of a cosine wave
as well as text output.

*Note:* This example assumes you have a working Python environment with the
required libraries installed.

* First install conda, follow the instructions you find the the [VSC
  documentation](https://docs.vscentrum.be/).
* Next install the environment using the `environment.yml` file provided in
  this directory, you the following command:
  ```bash
  $ conda env create -f environment.yml
  ```

*Note:* The jobscript has to be modified.  You have to change
* the <your_account> to your account name, i.e., a credit account you have access to.
* the <your_cluster> to the name of the cluster you intend to use.


## hat is it?

1. `environment.yml`: A YAML file that specifies the Python environment
   dependencies.  You can create the environment using the command above.
2. `cosine.py`: A Python script that generates a cosine wave plot and saves it
1. `cosine.slurm`: A Slurm job script that specifies the resources needed to run the
   Python script.  It includes the job name, output file, and the command to
   run the Python script.

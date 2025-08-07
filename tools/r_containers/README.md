# R containers

Tool to create apptainer images containing R and R packages.


## What is it?

1. `create_r_container.slurm`: Slurm script to create an apptainer image
   containing R and user-selected packages.
1. `apt_packages.txt`: list of apt packages that should cover the dependencies
   of the most common R packages.
1. `install_packages.R`: R script that installs the R packages to include in  
   in the image.  it contains some default packages helpful for package installation
   as well as tidyverse and optparse.
1. `labels.txt`: text files containing labels to be added to the image.


## How to use it?

To create an image containing R and user-selected packages, run the following
command:

```bash
$ sbatch --account=my_credit_account --cluster=my_cluster \
    create_r_container.slurm \
        --apt apt_packages.txt \
        --r-install install_packages.R \
        --sif my_container.sif
```

Here, `apt_packages.txt` is a text file containing the names of the apt packages
to install to cover system dependencies, and `install_packages.R` is an R script
that installs the R packages to include in the image. The script should contain
the command `install.packages(c("pkg1", "pkg2"))` to install the desired R
packages.  Note that this also allows for non-CRAN packages to be included.

Given that it takes quite a while to build an R image from scratch, the
`create_r_container.slurm` script also supports building new images from existing
images.  This can be done by the following command:

```bash
$ sbatch --account=my_credit_account --cluster=my_cluster \
    create_r_container.slurm \
        --apt apt_more_packages.txt \
        --r-install install_more_packages.R \
        --bootstrap localimage \
        --base-image my_old_container.sif \
        --sif my_new_container.sif
```

If the new R package don't require new apt packages, the `--apt` option can be
omitted. The `--bootstrap localimage` option indicates that the base image is a
local image, and the `--base-image` option specifies the path to the existing
image to use as a base for the new image. The `--sif` option specifies the name
of the new image to create. The `install_more_packages.R` script should contain
the command `install.packages(c("pkg3", "pkg4"))` to install the new R packages
to include in the new image. The new packages will be added to the existing
image, and the existing packages will not be removed or updated.
The original image remains unchanged.

Optionally (but best practice), you can also add labels to the image by using
the `--labels` option and specifying a text file containing the labels to add.
The labels will be added to the image metadata. For example:

```bash
$ sbatch --account=my_credit_account --cluster=my_cluster \
    create_r_container.slurm \
        --apt apt_packages.txt \
        --r-install install_packages.R \
        --sif my_container.sif \
        --labels labels.txt
```

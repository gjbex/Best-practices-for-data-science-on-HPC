# Text data

An I/O pattern that has detrimental performance is repeatedly reading many
small to medium size text files.  In this directory, you will find a number of
benchmarks to demonstrate the issue, as well as a number of solutions to the
problem.

The underlying assumption is that  the entire set of text files is too large to
fit into memory, but that the individual files are small enough to be read into
memory.


## What is it?

### Data generation

1. `create_data.sh`: Bash script that creates a directory with a number of text
   files, each containing a number of lines of text.  It also creates the
   necessary files for the benchmarks.
1. `create_data.slurm`: Slurm script that runs the `create_data.sh` script.
1. `datasets.ipynb`: Jupyter notebook that demonstrates how to use the
   `datasets` package from Hugging Face to read text files.

### Baseline

1. `benchmark_naive.py`: Python script that benchmarks reading individual text
   files in a directory.  This serves as the baseline.

### Indexed file

1. `index_text_files.py`: Python script that concatenates all text files that
   fit a given pattern into a single file, and creates an index file to
   facilitate random access to the content of the individual files.
1. `text_index.py`: Python module that implements a `TextIndex` class that can
   be used to access the content of the individual files.
1. `benchmark_text_index.py`: Python script that benchmarks reading a
   concatenated text files using the `TextIndex` class.
1. `indexed_files.ipynb`: Jupyter notebook that demonstrates the use of the
   `TextIndex` class and benchmarks it against the naive approach.

### Zip file

1. `benchmark_zip.py`: Python script that benchmarks reading individual text
   files from a zip file.

### Tar file

1. `benchmark_tar.py`: Python script that benchmarks reading individual text
   files from a tar file.

### Hugging Face dataset format

1. `concat_txt_to_dataset.py`: script to concatenate text files into a Hugging
   Face dataset, including labels.
1. `benchmark_dataset.py`: Python script that benchmarks reading individual
   text files from an datasets file.

### Running the benchmarks

1. `benchmark.py`: Python script that offers a uniform interface to each of the
   benchmarks.
1. `benchmarks.slurm`: Slurm script that runs the benchmarks.

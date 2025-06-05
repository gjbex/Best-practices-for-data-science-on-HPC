# Image data

Image data can be preprocessed to numpy arrays, that can all be stored in
a single dataset of an HDF5 file.


## What is it?

1. `create_data.sh`: Bash script to create the dataset.  It will generate
   TIFF files, convert those to numpy array files, store the
   data in an HDF5 files and a Hugging Face dataset of Pytorch tensors.
1. `create_data.slurm`: Slurm job script to create the data set.
1. `data`: directory containing the data.
1. `benchmark_naive.py`: Python script to benchmark reading individual TIFF files.
1. `benchmark_h5.py`: Python script to benchmark HDF5 data reading.
1. `benchmark_utils.py`: Python module containing common functions for benchmarking.
1. `h5.ipynb`: Jupyter notebook illustrating how to load image data from an
   HDF5 file.
1. `datasets.ipynb`: Jupyter notebook illustrating how to load images from a
   Huggingface dataset.
1. `benchmarks.slurm`: Slurm job script to run benchmarks.

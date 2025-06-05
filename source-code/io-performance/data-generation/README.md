# Data generation

This directory contains a number of scripts to create data for benchmarking and
conversion.


## What is it?

### CSV data generation

1. `create_csv_data.py`: script to create one or more CSV files with a column
   of timestamps and any number of columns with random double precision data.
   The number of rows can also be specified.
1. `convert_csv_to_parquet.py`: script to convert a CSV file to a Parquet file.
   The script uses polars lazy API to deal with very large files.
1. `concat_csv_to_parquet.py`: script to concatenate a CSV file to a Parquet
   file.  The script uses polars lazy API to deal with very large files.  Note
   that a temporary file is created to store the concatenated data.

### Text data generation

1. `create_text_data.py`: script to generate text data with given
   characteristics.

### Image data generation

1. `create_image_data.sh`: Bash script to generate an image file based on a
   template (`template.tif`).  An annotation is superimposed on the resulting
   image.
1. `template.tif`: template image to use as a background.
1. `convert_tiff_to_numpy.py`: Python script to convert a TIFF image to a NumPy
   array, saved as a `.npy` file.
1. `concat_numpy_to_hdf5.py`: Python script to store NumPy arrays in an HDF5
   file.
1. `convert_tiff_tars_to_pytorch_tensor_dataset.py`: Python script to convert a
   directory containing TAR files with TIFF files to a Hugging Face dataset with
   Pytorch tensors.

### Labels

1. `create_labels.py`: script to generate a CSV file with labels for the
   generated data.


## How to use?

### `create_csv_data.py`

To generate a CSV file with 1000 rows and 10 columns with random double
precision data, run

```bash $ python create_csv_data.py data  --rows 1000 --cols 10 ```

### `convert_csv_to_parquet.py`

To convert a CSV file to a Parquet file, run

```bash $ python convert_csv_to_parquet.py data.csv ```

### `concat_csv_to_parquet.py`

To concatenate a CSV file to a Parquet file, run

```bash
$ python concat_csv_to_parquet.py data.csv data.parquet
```


### `create_text_data.py`

To generate a text file with 1000 lines of 80 characters each, run

```bash
$ python create_text_data.py --output data.txt --words 1000 --max-words-per-line 80
```


### `create_image_data.sh`

To generate an image file based on the template with the string
"text-annotation" superimposed on it, and the rsulting image saved as
`data.tif`, run

```bash 
$ ./create_image_data.sh text-annotation data.tif
```


### `convert_tiff_to_numpy.py`

To convert a TIFF image to a NumPy array, run

```bash 
$ python convert_tiff_to_numpy.py data.tif
```

### `convert_tiff_tars_to_pytorch_tensor_dataset.py`

To convert a directory of TAR files that contain TIFF data files to
a Hugging Face dataset consisting of Pytorch tensors, run

```bash
$ python convert_tiff_tars_to_pytorch_tensor_dataset.py tar_dir
```

### `concat_numpy_to_hdf5.py`

To store NumPy arrays in an HDF5 file, run

```bash 
$ python concat_numpy_to_hdf5.py 'img/img*.npy' data.h5
```

### `create_labels.py`

To generate a CSV file with labels for the generated data, run

```bash 
$ python create_labels.py data.csv 'data/*.txt' --types int:2 str:5  --output data_lables.csv
```
This will create a CSV file with three columns, the first column is the
filename of the data file, the second is an integer with values 0 or 1, the
third a string with values A', ..., 'E'.

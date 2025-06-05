#!/usr/bin/env bash
#
# This script creates
#  - a directory for the data
#  - the individual data files in that directory
#  - a TextIndex text and index file
#  - a zip files that contains all the text files
#  - a tar files that contains all the text files
#
# To create the text files, the script uses the `../data-generation/create_text_data.py`
# script.  To create the text and index file for TextIndex, the script uses the
# `index_text_files.py` script.
#
# The scripts takes the following command line arguments:
#  - the name of the directory to write the files in,
#  - the number of text files to create.
#  - the maximum length of the words in the text files.
#
# If the `-h` or `--help` option is given, the script prints a help message and exits.

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    echo "Usage: $0 <directory> <number of text files> <max word length>"
    exit 0
fi

# Check the number of arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <directory> <number of text files> <max word length>"
    exit 1
fi

# Check that the directory does not exist
if [ -d "$1" ]; then
    echo "Directory $1 already exists"
    exit 1
fi

# Create the directory
mkdir "$1"

# Create the text files
(2>&1 echo "Creating $2 text files with max word length $3")
for i in $(seq 1 $2); do
    output_file="$1"/seq$(printf "%06d" $i).txt
    python ../data-generation/create_text_data.py \
        --words=1 \
        --max-word-length=$3 \
        --char-set=ACGT \
        --output-file "$output_file"
    echo "$output_file" >> "$1_files.txt"
done

# Create the TextIndex text and index file
(2>&1 echo "Creating text index file")
python index_text_files.py "$1/seq*.txt" "$1.txt"

# Create the zip file
(2>&1 echo "Creating zip file")
zip -q -j "$1.zip" "$1"/seq*.txt

# Create the tar file
(2>&1 echo "Creating tar file")
tar -cf "$1.tar" "$1"/seq*.txt

# Create the CSV labels file
(2>&1 echo "Creating labels file")
python ../data-generation/create_labels.py "$1/seq*.txt" --types int:2 str:10 --output "$1_labels.csv"

# Create dataset file
(2>&1 echo "Creating dataset file")
./concat_txt_to_dataset.py "$1/seq*.txt" "$1_labels.csv" "$1_dataset"

# Done
(2>&1 echo "Done")

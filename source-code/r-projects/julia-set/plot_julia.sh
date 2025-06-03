#!/usr/bin/env bash

# check whether there is at least one argument given
if [ "$#" -eq 0 ]
then
    (>&2 echo "### error: no data file name given")
    exit 1
fi
file="$1"

# determine size of image
y_size=$(wc -l $file | cut -d ' ' -f 1)
words=$(wc -w $file | cut -d ' ' -f 1)
x_size=$(( $words / $y_size ))

echo "### info: image size: $x_size x $y_size"

ulimit -s 65536

# plot the Julia set
gnuplot -persist <<- EOI
    plot "$file" matrix with image
    set size square
    unset key
    set xrange [0:$(( $x_size - 1))]
    set yrange [0:$(( $y_size - 1))]
    replot
EOI

#!/usr/bin/env bash

# image size
N=200

# implementations to compare
all_implementations="serial double_loops double_loops_column_major foreach"

# single_loops has been left out since it is very slow

# prepare command
prepare_cmd="./clear_cache"

# check whether the prepare command exists, if not, compile the C++ file
if [ ! -f clear_cache ]; then
    g++ -O3 -static -o clear_cache clear_cache.cpp
fi

# construct argument to hyperfine for each of the implementations in an array of strings
args=()
for implementation in $all_implementations; do
    args+=("./julia.R --width $N --height $N --implementation julia_${implementation}.R > /dev/null 2>/dev/null")  
done

# Show the commands that will be run
set -x
# Run the benchmark
hyperfine --prepare "$prepare_cmd" "${args[@]}"

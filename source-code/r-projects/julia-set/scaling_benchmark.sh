#!/usr/bin/env bash

# image size
N=500

# implementations to compare
implementation="foreach_parallel"

# gold-standard implementation
golden_implementation="foreach"

# prepare command
prepare_cmd="./clear_cache"

# check whether the prepare command exists, if not, compile the C++ file
if [ ! -f clear_cache ]; then
    g++ -O3 -static -o clear_cache clear_cache.cpp
fi

# construct argument to hyperfine for each of the implementations in an array of strings
args=()
# Add serial implementation
args+=("./julia.R --width $N --height $N --implementation julia_${golden_implementation}.R > /dev/null 2>/dev/null")  
for num_cores in 1 2 4 8 16; do
    args+=("./julia.R --width $N --height $N --implementation julia_${implementation}.R --parallel --nr_cores=${num_cores} > /dev/null 2>/dev/null")  
done

# Show the commands that will be run
set -x
# Run the benchmark
hyperfine --prepare "$prepare_cmd" "${args[@]}"


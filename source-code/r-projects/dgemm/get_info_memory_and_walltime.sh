#!/usr/bin/env -S bash

# for job ID read from STDIN, get memory and walltime info from Slurm using sacct
while read -r line; do
    job_id=$(echo "$line" | cut -d' ' -f1)
    output=$(sacct \
                 --jobs="${job_id}.batch" \
                 --allclusters \
                 --delimiter=' ' --parsable2 --noheader \
                 --format=MaxRSS,Elapsed)
    echo "$line $output"
done

#!/usr/bin/env -S bash -l

for SIZE in 1000 5000 10000 20000;
do
    for POWER in 10 20 40;
    do
        OUTPUT=$(sbatch --export=ALL,SIZE=$SIZE,POWER=$POWER memory_and_walltime_generous.slurm)
        echo $OUTPUT
        job_id=$(echo $OUTPUT | sed 's/[^0-9]*//g')
        echo "$job_id $SIZE $POWER" >> jobids_memory_and_walltime.txt
    done
done

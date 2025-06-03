#!/usr/bin/env -S Rscript --no-save --no-restore

# Start the profiler
Rprof(interval=0.01)
source("dgemm.R")
Rprof(NULL)
summaryRprof()

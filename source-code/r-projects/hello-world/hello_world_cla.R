#!/usr/bin/env -S Rscript --no-save --no-restore
#
# This script takes two arguments:
#  --name: the name of the person to greet
#  --count: the number of times to greet the person
# It prints "Hello <name> !" to the console <count> times.
#
# The command line arguments are parsed using the optparse package.

# Load the optparse package
library(optparse)

# Define the command line options
option_list <- list(
  make_option(c("--name"), type="character", default="world",
              help="The name of the person to greet"),
  make_option(c("--count"), type="integer", default=1,
              help="The number of times to greet the person")
)

# Parse the command line arguments
opt <- parse_args(OptionParser(option_list=option_list))

# Print the message
for (i in 1:opt$count) {
  cat("Hello", opt$name, "!\n")
}

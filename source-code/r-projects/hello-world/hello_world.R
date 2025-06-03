#!/usr/bin/env -S Rscript --no-save --no-restore
#
# This script prints "Hello from <hostname>!" to the console.
# The hostname is obtained using the Sys.info() function.

# Get the hostname
hostname <- Sys.info()["nodename"]

# Print the message
cat("Hello from", hostname, "!\n")

#!/usr/bin/env -S Rscript --no-save --no-restore
#
# This script reads a CSV file containing weather data and prints the
# average temperature for each month.
#
# An example CSV file is provided in the data directory, `data/London.csv`.
# The CSV file should have the following columns:
# - name: the name of the location
# - datetime: the date and time of the observation
# - tempmax: the maximum temperature in degrees Celsius
# - tempmin: the minimum temperature in degrees Celsius
# - temp: the mean temperature in degrees Celsius
# - feelslikemax: the maximum "feels like" temperature in degrees Celsius
# - feelslikemin: the minimum "feels like" temperature in degrees Celsius
# - feelslike: the mean "feels like" temperature in degrees Celsius
# - dew: the dew point in degrees Celsius
# - humidity: the relative humidity as a percentage
# - precip: the precipitation in mm
# - precipprob: the probability of precipitation as a percentage
# - precipcover: the cloud cover as a percentage
# - windspeed: the wind speed in km/h
# - windgust: the wind gust in km/h
# - winddir: the wind direction in degrees
# - pressure: the atmospheric pressure in hPa
# - visibility: the visibility in km
#
# The script has the following command line arguments:
# - input <file>: the path to the input CSV file
# - quantity <column>: the name of the quantity to analyze (e.g., temp, tempmax, tempmin)
# - output <file>: the path to the output CSV file
#
# The script computes the monthly average of the specified quantity.
#
# Command line options are parsed using the `optparse` package.

# Load the required packages
library(optparse)
library(here)

# Define the options and parse the command line arguments
option_list <- list(
                    make_option(c("-c", "--city"), type = "character",
                                help = "Name of the city to analyze weather data for"),
                    make_option(c("-q", "--quantity"), type = "character", default = "temp",
                                help = "Name of the quantity to analyze (e.g., temp, tempmax, tempmin)"),
                    make_option(c("-o", "--output"), type = "character",
                                help = "Path to the output CSV file")
)
opt <- parse_args(OptionParser(option_list = option_list))

# Check if the the output file name contains a directory, that this directory exists, and if not, create it
if (dirname(opt$output) != ".") {
    dir.create(dirname(opt$output), showWarnings = FALSE, recursive = TRUE)
}

# Construct the path to the input CSV file
input_file <- here("data", paste0(opt$city, ".csv"))

# Check if the input CSV file exists, if not, print an error message to STDERR and exit
if (!file.exists(input_file)) {
    stop(paste("The input CSV file", input_file, "does not exist"))
}

# Read the input CSV file
data <- read.csv(input_file)

# Check if the specified quantity is present in the data
if (!(opt$quantity %in% colnames(data))) {
    stop(paste("The specified quantity", opt$quantity, "is not present in the data"))
}

# Extract the month from the datetime column
data$month <- format(as.Date(data$datetime), "%m")

# Compute the monthly average of the specified quantity
monthly_avg <- aggregate(data[[opt$quantity]], by = list(data$month), FUN = mean)

# Set the names of the columns
colnames(monthly_avg) <- c("Month", "Average")

# Write the monthly average to the output CSV file
write.csv(monthly_avg, file = opt$output, row.names = FALSE)

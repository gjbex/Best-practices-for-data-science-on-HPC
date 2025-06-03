#!/usr/bin/env python
#
# script to generate a (large) dataset for testing purposes.
# The data is saved to a CSV file and consists of
#  - date/time column (format YYYY-MM-DD HH:MM:SS, here the
#    year is fixed to 2025, the months are in the range January to March)
#  - temerature column (float in the range 200 to 400)
#  - pressure column (float in the range 1000 to 2000)
#  - sensor ID column (integer in the range 1 to max_sensors, inclusive)
#  - sensor status column (string, either "OK" or "ERROR")
#
# The script takes the following command line arguments:
#  - output file name (default: 'sensor_data.csv')
#  - number of rows to generate (default: 10_000)
#  - number of sensors (default: 10)
#  - seed for random number generator (default: 42)
#
# The script uses the `pandas` library to create a DataFrame and save it to a CSV file.  It uses argparse to handle command line arguments.

import argparse
import pandas as pd
import numpy as np
from datetime import datetime, timedelta


MIN_TEMPERATURE = 200.0
MAX_TEMPERATURE = 400.0
MIN_PRESSURE = 1000.0
MAX_PRESSURE = 2000.0
MIN_DATETIME = datetime(2025, 1, 1, 0, 0, 0)
MAX_DATETIME = datetime(2025, 3, 31, 23, 59, 59)
SENSOR_STATUS_OPTIONS = ['OK', 'ERROR']
SENSOR_STATUS_PROBABILITIES = [0.99, 0.01]
NUM_DECIMAL_PLACES = 2

def generate_data(num_rows, num_sensors):
    
    # Generate date/time column
    date_range = np.random.choice(
        pd.date_range(start=MIN_DATETIME, end=MAX_DATETIME, freq='s'),
        size=num_rows,
        replace=True
    )

    # Generate temperature and pressure columns
    temperatures = np.random.uniform(MIN_TEMPERATURE, MAX_TEMPERATURE, num_rows).round(NUM_DECIMAL_PLACES)
    pressures = np.random.uniform(MIN_PRESSURE, MAX_PRESSURE, num_rows).round(NUM_DECIMAL_PLACES)
    
    # Generate sensor ID column
    sensor_ids = np.random.randint(1, num_sensors + 1, num_rows)
    
    # Generate sensor status column
    statuses = np.random.choice(SENSOR_STATUS_OPTIONS, num_rows, 
                                p=SENSOR_STATUS_PROBABILITIES)
    
    # Create DataFrame
    data = pd.DataFrame({
        'datetime': date_range,
        'temperature': temperatures,
        'pressure': pressures,
        'sensor_id': sensor_ids,
        'status': statuses
    })
    
    return data


if __name__ == "__main__":
    arg_parser = argparse.ArgumentParser(description='Generate a dataset for testing purposes.')
    arg_parser.add_argument('--output', type=str, default='sensor_data.csv', help='Output file name (default: sensor_data.csv)')
    arg_parser.add_argument('--rows', type=int, default=10_000, help='Number of rows to generate (default: 10,000)')
    arg_parser.add_argument('--sensors', type=int, default=10, help='Number of sensors (default: 10)')
    arg_parser.add_argument('--seed', type=int, default=42, help='Seed for random number generator (default: 42)')  
    args = arg_parser.parse_args()
    np.random.seed(args.seed)  # Set seed for reproducibility
    data = generate_data(args.rows, args.sensors)
    data.to_csv(args.output, index=False)

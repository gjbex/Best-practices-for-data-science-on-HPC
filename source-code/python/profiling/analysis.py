#!/usr/bin/env python

import argparse
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns


def parse_args():
    parser = argparse.ArgumentParser(description='Analyze sensor data.')
    parser.add_argument(
        '--data',
        type=str,
        default='sensor_data.csv',
        help='Path to the sensor data CSV file.'
    )
    return parser.parse_args()

def read_data(file_path):
    """Read sensor data from a CSV file."""
    return pd.read_csv(
        file_path,
        parse_dates=['datetime'],
        dtype={
            'temperature': pd.Float32Dtype(),
            'pressure': pd.Float32Dtype(),
            'sensor_id': pd.UInt32Dtype(),
            'status': pd.CategoricalDtype(),
        },
    )


def main():
    args = parse_args()
    data = read_data(args.data)

    # Display basic information about the dataset
    print("Dataset Information:")
    data.info()

    print("\nFailure Counts per sensor:")
    failures = data[['sensor_id', 'status']][data.status != 'OK'] \
        .groupby('sensor_id') \
        .count()
    print(failures)


    sns.histplot(
        data=failures.index.repeat(failures.status),
        bins=data.sensor_id.unique().size,
        discrete=True
    )
    plt.savefig('failures_per_sensor.png')

    measure_count = data[['datetime', 'status']][data.status == 'OK'] \
        .groupby(data.datetime.dt.date).size() \
        .reset_index(name='meassurement_count')
    measure_count.columns = ['date', 'measurement_count']
    print("\nMeasurement Counts per day:")
    print(measure_count)

    sns.lineplot(data=measure_count, x='date', y='measurement_count')
    plt.xticks(rotation=55);
    plt.savefig('measurements_per_day.png')


    print(f'number of measurements/day: {measure_count.measurement_count.min():.2f} '
          f'<= {measure_count.measurement_count.mean():.2f} '
          f'<= {measure_count.measurement_count.max():.2f}')

    min_temperatures = data.groupby(data.datetime.dt.date).temperature.min()
    mean_temperatures = data.groupby(data.datetime.dt.date).temperature.mean()
    temperatures = pd.merge(min_temperatures, mean_temperatures, on='datetime', )
    max_temperatures = data.groupby(data.datetime.dt.date).temperature.max()
    temperatures = pd.merge(temperatures, max_temperatures, on='datetime')
    temperatures.columns = ['min_temperature', 'mean_tempeature', 'max_temperature']

    print(temperatures.info())

    plt.figure(figsize=(12, 6))
    plt.fill_between(temperatures.index, temperatures.min_temperature, temperatures.max_temperature, alpha=0.2)
    sns.lineplot(data=temperatures, x=temperatures.index, y='mean_tempeature');
    plt.xticks(rotation=55)
    plt.savefig('temperature_per_day.png')


    high_termperatures = data[['sensor_id', 'temperature']][data.temperature > 375.0] \
        .groupby('sensor_id') \
        .count()
    sns.histplot(
        high_termperatures.index.repeat(high_termperatures.temperature),
        bins=10,
        discrete=True
    )
    plt.savefig('high_temperatures_per_sensor.png')


if __name__ == '__main__':
    main()

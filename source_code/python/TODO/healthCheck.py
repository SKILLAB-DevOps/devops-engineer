#!/usr/bin/env python3

import datetime
import subprocess
import psutil

# Check date and time
current_datetime = datetime.datetime.now()
print(f"Current Date and Time: {current_datetime}")

# Check uptime of the machine using 'uptime' command
try:
    uptime_output = subprocess.run(
        ["uptime"], capture_output=True, text=True
    ).stdout.strip()
    print(f"Uptime: {uptime_output}")
except Exception as e:
    print(f"Failed to get uptime. Error: {e}")

# Check disk usage using 'df' command
try:
    df_output = subprocess.run(
        ["df", "-h"], capture_output=True, text=True
    ).stdout.strip()
    print(f"Disk Usage:\n{df_output}")
except Exception as e:
    print(f"Failed to get disk usage. Error: {e}")

# Check memory usage using 'free' command
try:
    free_output = subprocess.run(
        ["free", "-h"], capture_output=True, text=True
    ).stdout.strip()
    print(f"Memory Usage:\n{free_output}")
except Exception as e:
    print(f"Failed to get memory usage. Error: {e}")

# Check disk and memory usage using 'psutil'
disk_usage = psutil.disk_usage("/")
memory_info = psutil.virtual_memory()

print(f"Disk Usage using psutil: {disk_usage.percent}%")
print(f"Memory Usage using psutil: {memory_info.percent}%")

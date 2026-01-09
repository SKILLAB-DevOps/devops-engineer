#!/usr/bin/env python3
import requests
import subprocess

# Read the location from the keyboard
location = input("Enter the location for the weather report: ")

# Validate the location using the Nominatim OpenStreetMap API
response = requests.get(
    f"https://nominatim.openstreetmap.org/search?format=json&q={location}"
)
data = response.json()

# Check if the API returned any valid locations
if len(data) == 0:
    print(f"{location} is not a valid location.")
else:
    print(f"{location} is a valid location.")

    # Fetch the weather report using curl
    try:
        result = subprocess.run(
            ["curl", f"https://wttr.in/{location}?format=3"],
            capture_output=True,
            text=True,
        )
        print(f"Weather in {location}: {result.stdout}")
    except Exception as e:
        print(f"An error occurred: {e}")

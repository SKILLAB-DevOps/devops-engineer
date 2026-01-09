#!/usr/bin/env python3.11
"""Dictionaries in Python."""

# Dictionary is a key-value pair
animals = {"reptile": "python", "primates": "monkey", "mammal": "dog"}

# Accessing elements using key
animals["primates"]

# Accessing keys
animals.keys()

# Accessing values
animals.values()

# Loop through dictionary values
for animal in animals.values():
    print(animal.title())

muscle_cars = {"brand": "Dodge", "model": "Challenger", "year": 1970}

# Add new elements in dictionary
muscle_cars["color"] = "black"

# Update dictionary
muscle_cars.update({"color": "red"})

#!/usr/bin/env python3.11

# List is a sequence of elements
animals = ["rabbit", "cat", "dog", "python", "monkey"]

# Check if element is in the list
if "python" in animals:
    animals.remove("python")
    print(animals)

# Check if element is not in the list
if "whale" not in animals:
    animals.append("whale")
    print(animals)

animals = []
if not animals:
    animals.append("python")
    print(animals)
else:
    print(animals)

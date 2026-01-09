#!/usr/bin/env python3.11
"""Strings in Python."""

# String is a sequence of characters
single_name = "DevOps"
doubleName = "DevOps"

# How to print a string
print("Course name is " + single_name)
# or
print(f"Course name is {single_name}")

print("skillab".title())

name = "skillab"

print(name.title())
print(name.lower())
print(name.upper())
print(name.replace("a", "A"))

# How to find out all the available alternatives
print(dir(name))

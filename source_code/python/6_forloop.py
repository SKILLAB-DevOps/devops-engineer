#!/usr/bin/env python3.11
"""For loop in Python.""" ""
animals = ["rabbit", "cat", "dog", "python", "monkey"]

# Looping string lists
for animal in animals:
    print(animal)

# Loop numeral lists
for value in range(1, 5):
    print(value)

squares1 = []
for value in range(1, 11):
    square = value**2
    squares1.append(square)
print(squares1)

# List Comprehensions
squares2 = [value**2 for value in range(1, 11)]
print(squares2)

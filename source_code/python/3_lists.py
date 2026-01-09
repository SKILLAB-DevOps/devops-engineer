#!/usr/bin/env python3.11
"""Lists in Python."""

# List is a sequence of elements
animals = ["cat", "dog", "python"]

print(animals)

# Lists are ordered collections, so you can access any element in a list by telling Python the position, or index, of the item desired. To access an element in a list, write the name of the list followed by the index of the item enclosed in square brackets.
print(animals[2])

# You can also format the result
print(animals[2].title())

# Add elements
animals.append("monkey")
print(animals)

# Insert element at any position
animals.insert(0, "rabbit")
print(animals)

# Remove elements by position
del animals[3]
print(animals)

# Removing an Item Using the pop() Method
# Example want to remove a user from a list of active members and then add that user to a list of inactive members.
# pop() with no argument last element
# pop(1) 2nd element
popped_animal = animals.pop()

# Remove elements by value
animals.remove("python")

animals = ["rabbit", "cat", "dog", "python", "monkey"]

# how long is the list
len(animals)

print(animals)

animals.sort()
animals.sort(reverse=True)

# sort() is a irreversible procedure
# if you need something temporary without affecting the original list use sorted(list_name)
print("Here is the original list:")
print(animals)

print("\nHere is the sorted list:")
print(sorted(animals))

print("\nHere is the original list again:")
print(animals)

animals = ["rabbit", "cat", "dog", "python", "monkey"]

print(animals[5])

# Instead of using last element by explicitly using position value we can use
print(animals[-1])

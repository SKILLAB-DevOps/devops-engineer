##########################
4.3 Loops and conditionals
##########################

==============
If Conditional
==============

.. code-block:: python

    animals = ['rabbit', 'cat', 'dog', 'python', 'monkey']

    if 'python' in animals:
        animals.remove('python')
        print(animals)
        
    if "whale" not in animals:
        animals.append("whale")
        print(animals)

    # Checking that a list is not empty
    animals = []
    print(animals)
    if not animals:
        animals.append("python")
        print(animals)
    else:
        print(animals)

========
For loop
========

.. code-block:: python
    
    animals = ['rabbit', 'cat', 'dog', 'python', 'monkey']

    # Looping string lists
    for animal in animals:
        print(animal)

    # Loop numeral lists
    for value in range(1, 5):
        print(value)
    
    # Creating new list
    squares1 = []
    for value in range(1, 11):
        square = value ** 2
        squares1.append(square)
    
    print(squares1)

    # List Comprehensions
    squares2 = [value**2 for value in range(1, 11)]

    print(squares2)

.. note::
    
    Four lines of code were used in the older method for creating the list squares.
    With just one line of code, you can create the same list using list comprehension.
    A list comprehension automatically appends each new element and condenses the for loop and production of new elements into a single line.

==========
While loop
==========

You can use a while loop to count up through a series of numbers. For example, the following while loop counts from 1 to 5:

.. code-block:: python
    
    current_number = 1
    while current_number <= 5:
        print(current_number)
        current_number += 1

    # Running while true until break
    user_input = "\nPlease enter the name of a country you have visited:"
    user_input += "\n(Enter 'exit' when you are finished.) "

    while True:
        country = input(user_input)

        if country == 'exit':
            break
        elif country == 'romania':
            continue
        else:    
            print(f"I'd love to go to {country.title()}!")
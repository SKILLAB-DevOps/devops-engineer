#################################
4.2 Variables and Data structures
#################################

=========
Variables 
=========

Variables Are Labels - Variables are often described as boxes you can store values in - a variable references a certain value.

When declaring a variable we use the syntax: `name = value`

.. code-block:: python

   x = 1

We can also do multiple assignments

.. code-block:: python

   x, y, z = "A", "B", "C"

   print(x, y, z)

======
Naming
======

When you are using variables in Python, you need to adhere to a few rules and guidelines. Breaking some of these rules will cause errors; other guidelines just help you write code that is easier to read and understand. Be sure to keep the following variable rules in mind:

   - Variable names can contain only **letters**, **numbers**, and **underscores**.
   - Variable names are **case-sensitive** (``name``, ``Name`` and ``NAME`` are three different variables)
   - They can start with a **letter or an underscore**, but not with a number. For instance, you can call a variable ``name_1`` but not ``1_name``.
   - **Spaces are not allowed** in variable names, but underscores can be used to separate words in variable names. For example, ``first_name`` works, but ``first name`` will cause errors.
   - **Avoid using Python keywords** and function names as variable names; that is, do not use words that Python has reserved for a particular programmatic purpose, such as the word print. Read more:  https://docs.python.org/3/reference/lexical_analysis.html#keywords
   - Variable names should be **short but descriptive**. For example, ``name`` is better than ``n``, ``first_name`` is better than ``f_n``, and ``name_length`` is better than ``length_of_persons_name``.
   - Be careful when using the lowercase letter ``l`` and the uppercase letter ``O`` because they could be confused with the numbers ``1 and 0``.

++++++++++++++++++
Naming conventions 
++++++++++++++++++

In **Python** naming conventions will not affect your code, but will affect your way for working in the team (in other languages naming convention matters)

We have 4 different ways of declaring:

1. **Snake case** (ex: some_variable) 
2. **Screaming Snake case** (ex: SOME_VARIABLE)
3. **Pascal case** (ex: SomeVariable)
4. **Camel case** (ex: someVariable)

Read more about the Python conventions in https://peps.python.org/pep-0008/

**I** use them like this:

- **Snake case** - for functions, methods, attributes, variables (this is the preferred way in Python)

Function names should be lowercase, with words separated by underscores as necessary to improve readability.

Is preferred ``def function_name():`` not ``def functionName():``.

.. code-block:: python
   
   first_name = input("Enter your name: ")

- **Screaming Snake case** - Constants  

.. code-block:: python
   
   PI = 3.14

- **Pascal case** - defining class name.

.. code-block:: python
   
   class Student:
      def __init__(self, name, age): 
         self.name = name
         self.age = age

      def displayInfo(self): # class method
         print('Student Name: ', self.name,', Age: ', self.age)

- **Camel case**- to name some methods (ex: toJson, fromFile, updateFile) - because when you are using them they look like this ``Student.displayInfo``

==========
Data types
==========

In Python3.6, PEP 498 introduces a new kind of string literals: f-strings, or formatted string literals.

Read more about f-strings https://docs.python.org/3/whatsnew/3.6.html#whatsnew36-pep498

==========
1. Strings
==========

In Python, strings are enclosed in either single or double quotation marks. Single quotes will not let variable pass, so be careful.

.. code-block:: python
   
   single_name = 'skillab'
   doubleName = "skillab"

   print("Course name is " + single_name)
   # or
   print(f"Course name is {single_name}")

+++++++++++++++++++
String Manipulation
+++++++++++++++++++

When we talk about string manipulation, we means either using the string methods or using the f-strings.

Keep in mind that some of the methods:
   - are case sensitive - ``title()`` and ``Title()`` are not the same
   - are irreversible - if you want to keep the original string you need to create a new variable - Example ``count()`` method
   - are not changing the original string - Example ``title()`` method
   - are badly documented - you need to read the documentation to understand what they are doing and how to use them properly. Example float's method ``is_integer()``.

.. code-block:: python
   
   print("skillab".title())

   name = "skillab"

   print(name.title())
   print(name.lower())
   print(name.upper())
   print(name.replace('a','A'))

   # How to find out all the available alternatives
   dir(name)

Methods available for strings:

.. code-block:: python

   '__add__',
   '__class__',
   '__contains__',
   '__delattr__',
   '__dir__',
   '__doc__',
   '__eq__',
   '__format__',
   '__ge__',
   '__getattribute__',
   '__getitem__',
   '__getnewargs__',
   '__getstate__',
   '__gt__',
   '__hash__',
   '__init__',
   '__init_subclass__',
   '__iter__',
   '__le__',
   '__len__',
   '__lt__',
   '__mod__',
   '__mul__',
   '__ne__',
   '__new__',
   '__reduce__',
   '__reduce_ex__',
   '__repr__',
   '__rmod__',
   '__rmul__',
   '__setattr__',
   '__sizeof__',
   '__str__',
   '__subclasshook__',
   'capitalize', # returns a copy of the string with its first character capitalized and the rest lowercased
   'casefold', # returns a copy of the string with all its characters lowercased
   'center', # returns a centered string of length width
   'count', # returns the number of times a specified value occurs in a string
   'encode', # returns an encoded version of the string
   'endswith', # returns true if the string ends with the specified value
   'expandtabs', # sets the tab size of the string
   'find', # searches the string for a specified value and returns the position of where it was found
   'format', # formats specified values in a string
   'format_map', # formats specified values in a string
   'index', # searches the string for a specified value and returns the position of where it was found
   'isalnum', # returns True if all characters in the string are alphanumeric
   'isalpha', # returns True if all characters in the string are in the alphabet
   'isascii', # returns True if all characters in the string are ascii characters
   'isdecimal', # returns True if all characters in the string are decimals
   'isdigit', # returns True if all characters in the string are digits
   'isidentifier', # returns True if the string is an identifier
   'islower', # returns True if all characters in the string are lower case
   'isnumeric', # returns True if all characters in the string are numeric
   'isprintable', # returns True if all characters in the string are printable
   'isspace', # returns True if all characters in the string are white spaces
   'istitle', # returns True if the string follows the rules of a title
   'isupper', # returns True if all characters in the string are upper case
   'join', # joins the elements of an iterable to the end of the string
   'ljust', # returns a left justified version of the string
   'lower', # converts a string into lower case
   'lstrip', # returns a left trim version of the string
   'maketrans', # returns a translation table to be used in translations
   'partition', # returns a tuple where the string is parted into three parts
   'removeprefix', # removes a specified prefix from the string
   'removesuffix', # removes a specified suffix from the string
   'replace', # returns a string where a specified value is replaced with a specified value
   'rfind', # searches the string for a specified value and returns the last position of where it was found
   'rindex', # searches the string for a specified value and returns the last position of where it was found
   'rjust', # returns a right justified version of the string
   'rpartition', # returns a tuple where the string is parted into three parts
   'rsplit', # splits the string at the specified separator, and returns a list  
   'rstrip', # returns a right trim version of the string
   'split', # splits the string at the specified separator, and returns a list
   'splitlines', # splits the string at line breaks and returns a list
   'startswith', # returns true if the string starts with the specified value
   'strip', # returns a trimmed version of the string
   'swapcase', # swaps cases, lower case becomes upper case and vice versa
   'title', # converts the first character of each word to upper case
   'translate', # returns a translated string
   'upper', # converts a string into upper case
   'zfill' # fills the string with a specified number of 0 values at the beginning

+++++++++++++
Magic methods
+++++++++++++ 


..code-block:: python 
   
   __len__()

One of the many magic methods in the Python programming language, ``__len__`` is primarily used to implement the ``len()`` function because every time the ``len()`` function is called, the magic method ``__len__`` is also called internally.

After all is said and done, it returns an integer value larger than or equal to zero, which is the length of the object for which it was called. 

.. code-block:: python
   
   print("skillab".__len__())
   print(len("skillab"))

==========
2. Numbers
==========

Python supports 3 types of numbers:

 - integers(whole numbers)
 - floating point numbers(decimals).
 - complex numbers

.. code-block:: python
    
   # When declaring a variable we use the syntax
   # name = value
   x = 1
   xint = int(x)
   xfloat = float(x)
   universe_age = 14_000_000_000

   print(x)
   print(xint)
   print(xfloat)
   print(universe_age)

   print(type(x))
   print(type(xint))
   print(type(xfloat))

   print(dir(x))
   print(dir(xint))
   print(dir(xfloat))

Methods available for numbers:

.. code-block:: python

   '__abs__',
   '__add__',
   '__bool__',
   '__ceil__',
   '__class__',
   '__delattr__',
   '__dir__',
   '__divmod__',
   '__doc__',
   '__eq__',
   '__float__',
   '__floor__',
   '__floordiv__',
   '__format__',
   '__ge__',
   '__getattribute__',
   '__getformat__',
   '__getnewargs__',
   '__getstate__',
   '__gt__',
   '__hash__',
   '__init__',
   '__init_subclass__',
   '__int__',
   '__le__',
   '__lt__',
   '__mod__',
   '__mul__',
   '__ne__',
   '__neg__',
   '__new__',
   '__pos__',
   '__pow__',
   '__radd__',
   '__rdivmod__',
   '__reduce__',
   '__reduce_ex__',
   '__repr__',
   '__rfloordiv__',
   '__rmod__',
   '__rmul__',
   '__round__',
   '__rpow__',
   '__rsub__',
   '__rtruediv__',
   '__setattr__',
   '__sizeof__',
   '__str__',
   '__sub__',
   '__subclasshook__',
   '__truediv__',
   '__trunc__',
   'as_integer_ratio', # returns a pair of integers whose ratio is exactly equal to the original float
   'conjugate', # returns the complex conjugate of the float
   'fromhex', # converts a hexadecimal string to a float
   'hex', # converts a float to a hexadecimal string
   'imag', # returns the imaginary part of a complex number
   'is_integer', # returns True if the float is an integer
   'real' # returns the real part of a complex number

+++++++++++++++++
Number operations
+++++++++++++++++

.. code-block:: python

   # add 
   print(1+2)
   # subtract
   print(1-2)
   # multiply
   print(1*2)
   # divide
   print(1/2)
   # modulo
   print(1%2)

========
3. Lists
========

A list is a collection of objects in a specific sequence.
A list can contain anything you want, and there is no requirement that the items on it link to one another in any specific way.
It's a good idea to name your list in the plural, such as letters, numerals, or names, because lists typically contain many elements.

.. code-block:: python

   animals = ["cat", "dog", "python"]

   print(animals)

   # Lists are ordered collections, so you can access any element in a list by telling Python the position, or index, of the item desired. To access an element in a list, write the name of the list followed by the index of the item enclosed in square brackets.
   print(animals[2])

   # You can also format the result
   print(animals[2].title())

Methods available for lists:

.. code-block:: python

   '__add__',
   '__class__',
   '__class_getitem__',
   '__contains__',
   '__delattr__',
   '__delitem__',
   '__dir__',
   '__doc__',
   '__eq__',
   '__format__',
   '__ge__',
   '__getattribute__',
   '__getitem__',
   '__getstate__',
   '__gt__',
   '__hash__',
   '__iadd__',
   '__imul__',
   '__init__',
   '__init_subclass__',
   '__iter__',
   '__le__',
   '__len__',
   '__lt__',
   '__mul__',
   '__ne__',
   '__new__',
   '__reduce__',
   '__reduce_ex__',
   '__repr__',
   '__reversed__',
   '__rmul__',
   '__setattr__',
   '__setitem__',
   '__sizeof__',
   '__str__',
   '__subclasshook__',
   'append', # adds an element at the end of the list
   'clear', # removes all the elements from the list
   'copy', # returns a copy of the list
   'count', # returns the number of elements with the specified value
   'extend', # add the elements of a list (or any iterable), to the end of the current list
   'index', # returns the index of the first element with the specified value   
   'insert', # adds an element at the specified position
   'pop', # removes the element at the specified position
   'remove', # removes the first item with the specified value
   'reverse', # reverses the order of the list
   'sort' # sorts the list

+++++++++++++++++
List Manipulation
+++++++++++++++++

The majority of lists you create will be dynamic, meaning that when your program executes, you'll add, update and remove items from the list you've created. 

.. code-block:: python

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

.. warning:: 

   Only the first instance of the value you specify is removed by the ``remove()`` method.
   You'll need to use a loop if there's a chance that the value could appear more than once in the list to ensure that all instances are eliminated.

.. code-block:: python

   digits = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]
   min(digits)
   max(digits)
   sum(digits)

+++++++++++++++++
List Organization
+++++++++++++++++

Because you can't always control the order in which your users submit their data, your lists will frequently be generated in an unpredictable order.

.. code-block:: python

   animals = ['rabbit', 'cat', 'dog', 'python', 'monkey']
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

.. warning::

   When all the values are not lowercase, sorting a list alphabetically becomes a little more challenging.
   When determining a sort order, capital letters can be interpreted in a variety of ways, and specifying the precise order can be more difficult than we want to handle right now.

+++++++++++++++++++++++++++++++++++++++++++++
Avoiding Index Errors When Working with Lists
+++++++++++++++++++++++++++++++++++++++++++++

When you are working with lists for the first time, one type of error is frequent to see is Index error.

.. code-block:: python

   animals = ['rabbit', 'cat', 'dog', 'python', 'monkey']

   print(animals[5])

   # Instead of using last element by explicitly using position value we can use
   print(animals[-1])

===============
4. Dictionaries
===============

In Python, a dictionary is a collection of key-value pairs.
Each key has a value associated with it, and you may use a key to get that value.
The value of a key could be an integer, string, list, dictionary, or even another dictionary.
In actuality, you may use any Python-created object as a value in a dictionary.

What Are Dictionaries in Python?
In Python, dictionaries are a built-in data type used to store collections of data. Unlike lists or tuples, dictionaries are unordered and store data in key-value pairs. Here's a simple example:

+++++++++++++++++++++++++++
When Are Dictionaries Used?
+++++++++++++++++++++++++++

Dictionaries are highly flexible and useful in a variety of situations, such as:

   - Caching: To remember previously computed values.
   - Data grouping: To categorize and summarize data by specific keys.
   - Configuration: To hold settings and parameters.
   - JSON representation: Python dictionaries can easily be converted to JSON format, making them useful in web development.
   - Hash table implementations: To create sets, bags, or other abstract data types.

++++++++++++++
Best Practices
++++++++++++++

   - Key Uniqueness: Ensure each key in the dictionary is unique. Adding a duplicate key will overwrite the existing value for that key.
   - Immutable Keys: Use only immutable data types like strings, numbers, or tuples as keys.
   - Readability: Choose meaningful names for keys to make the code more understandable.
   - Exception Handling: Use methods like dict.get(key, default) or dict.setdefault(key, default) to avoid key errors.
   - Dictionary Comprehensions: Use dictionary comprehensions for concise and expressive creation of dictionaries.
   - Iteration: Use items(), keys(), and values() methods to iterate through dictionaries in a readable manner.
   - Updates: Use the update() method to merge two dictionaries, which is more efficient than looping through keys.
   - Deep Copy: Use copy.deepcopy() when you need to copy nested dictionaries.

+++++++++++++++
Common Problems
+++++++++++++++

   - KeyError: Trying to access a key that does not exist.
   - Memory Usage: Dictionaries can consume a lot of memory when they grow large.
   - Order Sensitivity: Prior to Python 3.7, dictionaries did not maintain order. Even now, relying on the insertion order could make your code less readable and harder to understand.
   - Type Errors: Using mutable or unhashable types as keys.
   - Concurrency: Dictionaries are not thread-safe, which can lead to unpredictable behavior in concurrent programs.
   - Inconsistency: Since dictionaries are mutable, changes in the dictionary can lead to bugs if not handled carefully, especially when the dictionary is being shared across functions or objects.

Methods available for dictionaries:

.. code-block:: python

   '__class__',
   '__class_getitem__',
   '__contains__',
   '__delattr__',
   '__delitem__',
   '__dir__',
   '__doc__',
   '__eq__',
   '__format__',
   '__ge__',
   '__getattribute__',
   '__getitem__',
   '__getstate__',
   '__gt__',
   '__hash__',
   '__init__',
   '__init_subclass__',
   '__ior__',
   '__iter__',
   '__le__',
   '__len__',
   '__lt__',
   '__ne__',
   '__new__',
   '__or__',
   '__reduce__',
   '__reduce_ex__',
   '__repr__',
   '__reversed__',
   '__ror__',
   '__setattr__',
   '__setitem__',
   '__sizeof__',
   '__str__',
   '__subclasshook__',
   'clear', # removes all the elements from the dictionary
   'copy', # returns a copy of the dictionary
   'fromkeys', # returns a dictionary with the specified keys and value
   'get', # returns the value of the specified key
   'items', # returns a list containing a tuple for each key value pair
   'keys', # returns a list containing the dictionary's keys
   'pop', # removes the element with the specified key
   'popitem', # removes the last inserted key-value pair
   'setdefault', # returns the value of the specified key. If the key does not exist: insert the key, with the specified value 
   'update', # updates the dictionary with the specified key-value pairs
   'values' # returns a list of all the values in the dictionary

.. code-block:: python

   animals = { 'reptile': 'python', 'primates': 'monkey', 'mammal': 'dog'}
   
   # Accessing elements using key
   animals['primates']

   # Accessing keys
   animals.keys()

   # Accessing values
   animals.values() 

   # Loop through dictionary values
   for animal in animals.values():
      print(animal.title())

   muscle_cars = {
   "brand": "Dodge",
   "model": "Challenger",
   "year": 1970
   }

   # Add new elements in dictionary
   muscle_cars["color"] = "black"

   # Update dictionary
   muscle_cars.update({"color": "red"})

   # Remove items
   # `pop()` method removes the item with the specified key name
   muscle_cars.pop("color")

   # `popitem()` method removes the last inserted item
   muscle_cars.pop("year")

   # `del` keyword removes the item with the specified key name
   del muscle_cars["model"]

   # clear() method empties the dictionary
   muscle_cars.clear()
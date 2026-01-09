####
TODO
####

======
Task 1
======

Create a script ``wikiPython.py`` that:

    - reads a Wikipedia page: ``https://en.wikipedia.org/wiki/Python_(genus)`` (use ``requests`` command)
    - extracts Species elements - python name (what kind of pythons are there) (use ``BeautifulSoup``)
    - save the output the to a new file
    - append to the new file the last line that is the count of species

======
Task 2
======

Create script ``weather.py`` that gives you the weather from ``curl`` https://wttr.in/(location)

    - the location will be read from the keyboard - for example ``weather Bucharest``
    - test that location is valid using ``https://nominatim.openstreetmap.org/search?format=json&q=`` + location

======
Task 3
======

Create a health check script ``healthCheck.py`` that looks at:

    - date and time using ``import datetime``
    - the uptime of the machine using ``uptime``
    - how much disk ``df`` and memory usage ``free`` using ``import psutil``

=========
Questions
=========

1. What is the difference between ``requests`` and ``curl``?

    a. ``requests`` is a Python library, ``curl`` is a command line tool
    b. ``requests`` is a command line tool, ``curl`` is a Python library
    c. ``requests`` is a Python library, ``curl`` is a Python module
    d. ``requests`` is a Python module, ``curl`` is a Python library

2. What will the following code output?

    .. code-block::

        print(type(3.5))

    a. <class 'int'>
    b. <class 'float'>
    c. <class 'string'>
    d. <class 'decimal'>

3. What is the correct syntax to open a file for reading as a text file?

    a. open('file.txt', 'r')
    b. open('file.txt', 'w')
    c. open('file.txt', 'rb')
    d. open('file.txt', 'wb')

4. Which of the following is not a core data type in Python?

    a. Lists
    b. Arrays
    c. Tuples
    d. Dictionaries

5. In Python, what is a lambda function?

    a. A named function, defined with the def keyword
    b. An anonymous function, defined with the lambda keyword
    c. A built-in function
    d. A function that can only be used once

6. Which of the following data types does NOT allow duplicate elements?

    a. list
    b. tuple
    c. set
    d. dictionary

7. What is the output of the following tuple operation?

    .. code-block::

        my_tuple = (1, 2, 3, 4)
        print(my_tuple[1:3])

    a. (1, 2)
    b. (2, 3)
    c. (3, 4)
    d. (2, 3, 4)

=======
Answers
=======

1. 
    Answer: a

    Explanation: ``requests`` is a Python library, ``curl`` is a command line tool

2. 
    Answer: b

    Explanation: The number 3.5 is a floating-point number, so Python will recognize it as a float type.

3. 
    Answer: a

    Explanation: The open() function opens a file in one of three modes: read, write, or append. The default mode is read. In this case, the file will be opened for reading as a text file.

4. 
    Answer: b

    Explanation: Arrays are not a core data type in Python; lists can be used where arrays are used in other languages. However, arrays can be used by importing the array module.

5. 
    Answer: b

    Explanation: A lambda function is an anonymous function that can be defined without a name. It is defined with the lambda keyword, not the def keyword.

6. 
    Answer: c

    Explanation: Sets are unordered collections of unique elements. Lists, tuples, and dictionaries can all contain duplicate elements.

7. 
    Answer: b

    Explanation: The slice [1:3] will return the second and third elements of the tuple, which are 2 and 3.


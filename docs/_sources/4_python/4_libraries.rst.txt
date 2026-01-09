#########################
4.4 Libraries and modules
#########################

A Python library is a collection of related modules, contains code that can be reused in different programs.

When importing libraries in Python, you essentially allow your program to use additional functionality that is not built into the core language. This can be standard libraries like math, datetime, or json, or external libraries like numpy, pandas, or requests.

========================
How to install a library
========================

.. code-block:: bash

    pip install <library_name>

===============
Using libraries 
===============

.. code-block:: python
    
    import datetime

    today = datetime.datetime.today()
    print(f"{today:%B %d, %Y}")

++++++++++++++++++++++++++++++
Full import of specific module
++++++++++++++++++++++++++++++

.. code-block:: python

    import math

    result = math.sqrt(16)
    print(result)

or

.. code-block:: python

    from math import sqrt

    result = sqrt(16)
    print(result)

++++++++++++++++
Alias the module
++++++++++++++++
.. code-block:: python

    import library_name as alias_name

==============
Best Practices
==============

1. **Explicit is Better than Implicit**: Whenever possible, explicitly import what you need. This makes the code more readable and can reduce load time. Use ``from math import sqrt`` rather than ``import math``. 
2. **Standard Library First**: When listing import statements, import standard libraries first, followed by third-party libraries and then your own modules. This is mostly for readability and to recognize dependencies more clearly.
3. **Avoid * Imports**: Do not use wildcard imports like ``from library_name import *``. It makes the code harder to read by losing the context about which library a certain function or class comes from.
4. **Use Aliases Judiciously**: Aliases can make code more readable or concise, but ensure that the alias is commonly used and easily understandable. For instance, import numpy as np is widely understood.
5. **Local vs Global Imports**: Typically, imports are at the top of the file, but Python allows local imports inside functions or classes. Use local imports sparingly and only if necessary, such as for avoiding circular dependencies. 
6. **Group and Sort Imports**: Use a linter like flake8 or a formatter like black to automatically sort and group your imports.
7. **Circular Imports**: Be careful of circular dependencies. For example, if module A imports module B and module B imports module A, this can lead to issues.

===============
Common Problems
===============

1. **Module Not Found**: Make sure the library is properly installed and available in your environment.
2. **Circular Dependencies**: As mentioned, this can occur when two modules depend on each other. This can often be resolved by using local imports or re-organizing your code.
3. **Name Clashes**: Avoid naming your files with the same names as standard library or third-party packages to avoid import issues.
4. **Version Conflicts**: In a complex project, you might find that you need two different versions of a library. This can be difficult to manage and may require you to create isolated environments.
5. **Performance**: Importing a large library can slow down the startup time of your program. This may or may not be critical depending on your application.
6. **Deprecated Modules**: Libraries can be updated and sometimes functions or classes are deprecated. Make sure to read the documentation to keep your code up-to-date.
7. **Too many dependencies**, sometimes if you have just a small part of the library that you need it's better to just copy the code into the program (Dependency hell).

.. important:: 
    
    When libraries are needed - When you need to do something that is not in the standard library and you don't want to write it yourself!

==========================
When libraries are trusted
==========================

How do we know if a library is trusted:

    - Is it popular?
    - Is it well documented?
    - Is it well maintained?
    - Is it well tested?
    - Is it well reviewed?
    - Is it well supported?
    - Is it well licensed?
    
How to check:

    - check the github page: how many committees and maintainers, how many issues and PR, how many updates, when was last commit
    - check a tool like https://debricked.com/select/

=============================
How to create a Python module
=============================

.. code-block:: python

    # mathishard.py
    def hello():
        print("Hello, World!")

    def add(a, b):
        return a + b

    def subtract(a, b):
        return a - b

    def multiply(a, b):
        return a * b

    def divide(a, b):
        return a / b

    def main():
        print("Hello, World!")
        print(add(2, 2))
        print(subtract(4, 2))
        print(multiply(2, 2))
        print(divide(4, 2))

    if __name__ == "__main__":
        main()

.. important::

    Create an empty file called ``__init__.py`` in the same directory as ``mathishard.py``.

==========================
How to use a Python module
==========================

.. code-block:: python

    import my_module

    mathishard.hello()
    print(mathishard.add(2, 2))
    print(mathishard.subtract(4, 2))
    print(mathishard.multiply(2, 2))
    print(mathishard.divide(4, 2))

#########################
4.9 Python Language Rules
#########################

=======
Linting
=======

Lint, often known as a `linter`, is a tool that analyzes source code in order to detect programming errors, bugs, stylistic errors, and suspicious structures.

A `linter`, in its simplest form, is a program that examines your code in order to identify problems that could result in errors or inconsistencies with code health and style. Some even assist you in fixing them!

Tools to lint code in Python:
    - pylint
    - flake8
    - black

.. code-block:: bash

    # To install pylint, flask8, and black
    pip install pylint flake8 black

    # To run pylint, flake8, and black
    pylint my_code.py
    flake8 my_code.py
    black my_code.py

===================
Static type checker
===================

``Mypy`` is a Python static type checker that is optional and attempts to combine the advantages of static and dynamic (or "duck") typing.
``Mypy`` combines a robust type system and compile-time type verification with Python's expressive power and simplicity.
``Mypy`` type verifies common Python programs, which can be executed on any Python virtual machine with almost no runtime overhead.

.. code-block:: bash
    
    mypy *py

=============
Autoformatter
=============

Formatting - making your code look pretty

Tools to format code in Python:
    - black
    - yapf
    - autopep8

Black is the uncompromising Python code formatter. By using it, you agree to cede control over minutiae of hand-formatting. In return, Black gives you speed, determinism, and freedom from pycodestyle nagging about formatting. You will save time and mental energy for more important matters.

Blackened code looks the same regardless of the project you're reading. Formatting becomes transparent after a while and you can focus on the content instead.

.. code-block:: bash
    
    black *py
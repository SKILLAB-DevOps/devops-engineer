################
4.0 Introduction
################

===================
Learning Objectives
===================

By the end of this chapter, you will be able to:

• **Write** Python scripts to automate infrastructure management and deployment tasks
• **Build** command-line tools and utilities for DevOps workflows
• **Create** REST APIs for monitoring, configuration, and service integration
• **Implement** data processing and analysis for logs, metrics, and system information
• **Develop** testing frameworks and automated test suites for infrastructure code
• **Package** and distribute Python applications using modern packaging tools
• **Integrate** Python scripts with CI/CD pipelines, containers, and cloud services
• **Apply** Python best practices for code quality, security, and maintainability

**Prerequisites:** Basic programming concepts and familiarity with command-line interfaces.

.. important:: 

   Does it make sense to learn Python now?

   YES!

More about on:
   
    - StackOverflow survey: https://insights.stackoverflow.com/survey
    - IEEE Spectrum: https://spectrum.ieee.org/top-programming-languages-2022

===============================
1. Is Python the best language?
===============================

.. important:: 

   **No**. There are no best languages.

Every language has pros and cons.

   - **Pro**: 
      - easy to learn
      - easy to code
      - has support from the community

   - **Con**: 
      - not fast or too performant
      - needs libraries on locally to run
      - management of libraries versions is weird

=================================================
Why do **I** use Python and not another language?
=================================================

   - Python is an **efficient language**: my applications will do more in fewer lines of code than many other languages would require. 
   - I can build cli applications, machine learning algorithms, and cloud microservices. 
   - The community - I believe in **open source** and its ability to deliver good alternatives.

==================
2. Python features
==================

   * **Simple** - has a minimalist feel, the code feels like pseudo-code, allowing developers to concentrate on solving the problem not on writing the code. 
   * **Easy to use** - most of the components are easy to pick up
   * it's **FLOSS** - Free/Libre and Open Source Software
   * **High-level** Language
   * **Portable**
   * **Interpreted**
   * **Object-oriented** - everything in Python is an object
   * **Extensive libraries** - from the web apps to ml - it does all

   .. note::
      **Naming convention** - the Python programming language was named after the BBC program "Monty Python's Flying Circus" by Guido van Rossum.

==================
3. Python versions
==================

Release notes - what is new in every version?

https://docs.python.org/3.13/whatsnew/index.html

.. note::

   **Python 2** - is no longer supported. The last version was 2.7.18, released in April 2020. It's time to move on.

.. important::

   **When to update?**

   - when new features are needed

      - bugs solved
      - performance improved
      - newly added API's
   
   - when bored and you don't have work to do

==============
4. How to code
==============

1. **The Style Guide**

   A Python Enhancement Proposal is written when someone wants to alter the Python programming language (PEP).

   PEP 8, which teaches Python programmers how to style their code, is one of the first PEPs.Read more about the Python conventions at https://peps.python.org/pep-0008/

2. **Indentation**

   Per level of indentation, PEP 8 advises using four spaces. Four spaces allow for many levels of indentation on each line while also improving readability.

3. **Line Length**

   The rule of thumb among Python programmers is that lines should be no more than 80 characters. Because most computers could only fit 79 characters on a single line in a terminal window, this rule originated in the past. I personally use 120 characters per line.

4. **Blank Lines**

   Use blank lines to visually group the various components of your application.

5. **Comments**

   Comments are used to explain the code and make it easier to understand. Comments are ignored by the Python interpreter.

6. **Naming Conventions**

   The following are the most common naming conventions:

      - **Class names** - should be written in CamelCase, with the first letter of each word capitalized.
      - **Function names** - should be written in lowercase, with words separated by underscores.
      - **Variable names** - should be written in lowercase, with words separated by underscores.
      - **Constants** - should be written in all capital letters, with words separated by underscores.

7. **Docstrings**

   Docstrings are used to document Python modules, classes, functions, and methods. Docstrings are used to generate documentation automatically.

8. **Whitespace**

   Whitespace is used to improve readability. Whitespace is ignored by the Python interpreter.

9. **Encoding**

   The default encoding for Python source code is UTF-8. UTF-8 is a variable-length encoding that can encode any Unicode character.

10. **Imports**

   Imports should be on separate lines. Imports should be grouped in the following order:

      - standard library imports
      - related third-party imports
      - local application/library specific imports

11. **Parentheses**

   Parentheses are used to group statements. Parentheses are also used to indicate tuples and other data structures.

=================
The Zen of Python
=================

Experienced Python programmers will encourage you to avoid complexity and aim for simplicity whenever possible. The Python community's philosophy is contained in “The Zen of Python” by Tim Peters. You can access this brief set of principles for writing good Python code by entering import this into your interpreter.

.. code-block:: python

   python3.12

   # then run
   import this

================
Python filosophy
================

.. note::
   
   Everything in Python is an object!

+++++++++++++++++++
What is everything?
+++++++++++++++++++

Anything that can be assigned to a variable is an object. That includes functions, classes, and modules, and of course int's, str's, float's, list's, and everything else. It does not include whitespace, punctuation, or operators(+,-,*,/,%).

There is the operator module in the standard library which includes functions that implement operators; those functions are objects. That doesn't mean + or * are objects.

.. important::

   If something is an object, it means it is instantiated from a class.

   If something is instantiated from a class, it means it has access to its class's attributes and methods.

1. What is a ``class``?

   A class is a blueprint for creating objects.

2. What is a ``method``?

   A method is a function that is defined inside a class.

   A **magic method** is a method that is surrounded by **double underscores** example ``__init__``, and it is also called a ``dunder`` method. It's role is to change the behavior of the class, and it should not be called directly.

   There are 3 type of methods in Python:
   
   - **actions** - they change the state of the object but the don't change the object itself. Example ``title()`` method for strings.
   - **accessors** - they return information about the object. Example ``len()`` method for strings.
   - **mutators/transformers** - they change the state of the object and change the object itself. Example ``append()``, ``sort()`` method for lists.

3. What is an ``attribute``?

   An attribute is a variable that is defined inside a class.

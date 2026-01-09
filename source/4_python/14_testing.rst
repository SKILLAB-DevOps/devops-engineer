#############################
4.14 Testing and Unit Testing
#############################

.. image:: ../diagrams/testing_pyramid.png
  :width: 1500 px
  :alt: Testing Pyramid

Unit tests are a type of automated tests that focus on verifying the smallest "unit" of code in isolation, typically a function or method in an object-oriented system. The primary goal is to validate that each unit of the software performs as designed.

====================================
Libraries for Unit Testing in Python
====================================

1. ``unittest``: This is the built-in library for Python, following the xUnit style.
2. ``pytest``: A third-party library that offers more features and a simpler, less verbose syntax.
3. ``nose2``: Successor to the now-unmaintained nose, it extends unittest to make testing easier.
4. ``doctest``: Allows you to test that the docstrings in your code hold up as examples.
5. ``mock``: Although now part of the standard library, it allows for easy mocking of tests. This is useful in unit tests where you need to isolate the code being tested.

====
Pros
====


1. Code Quality: Writing tests often leads to better code design, as developers need to consider how to structure their code to make it testable.
2. Regression Testing: Unit tests can catch regressions, where a change in one part of the software inadvertently affects another part.
3. Refactoring: Unit tests make refactoring easier because you can be confident that your changes didn't introduce regressions.
4. Documentation: Well-written unit tests can serve as documentation, demonstrating how a piece of code is intended to be used.
5. Simplifies Debugging: When a unit test fails, you only need to consider the latest changes, making debugging simpler.

====
Cons
====

1. Initial Time Investment: Writing tests takes time, which may not be justified for short scripts or prototypes.
2. Complexity: For complex systems, writing unit tests can be complicated and difficult to manage.
3. False Sense of Security: Passing unit tests do not mean your software is free from bugs. Other types of testing are often necessary.
4. Maintenance: Tests themselves have to be maintained. As software evolves, the tests need to be updated too.

.. code-block:: python

    # install pytest
    pip install pytest

Now, let's say you have a simple function that calculates the factorial of a number.

.. code-block:: python

    # my_module.py

    def factorial(n):
        if n == 0:
            return 1
        else:
            return n * factorial(n-1)

You could write a pytest test as follows:

.. code-block:: python

    # test_my_module.py

    from my_module import factorial

    def test_factorial():
        assert factorial(0) == 1
        assert factorial(1) == 1
        assert factorial(2) == 2
        assert factorial(3) == 6
        assert factorial(4) == 24

To run the test:

.. code-block:: python

    pytest test_my_module.py

If the tests pass, you'll see output indicating that they were successful. If they fail, pytest will provide detailed information about the failures.
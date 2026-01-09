#######################
4.13 Lambda Expressions
#######################

Lambda expressions are anonymous functions that you can use to create delegates or expression tree types. By using lambda expressions, you can write local functions that can be passed as arguments or returned as the value of function calls. Lambda expressions are particularly helpful for writing LINQ query expressions.

Lambda expressions are used in method-based LINQ queries as arguments to standard query operator methods such as Where.

.. code-block:: python

    # lamda example
    square = lambda x: x * x

    # lamda example with multiple arguments
    add = lambda x, y: x + y

    # lamda example with default argument
    add = lambda x, y=10: x + y

    # lamda example with variable number of arguments
    add = lambda *args: sum(args)

    # lamda example with variable number of arguments
    add = lambda **kwargs: sum(kwargs.values())

    # lamda example with variable number of arguments
    add = lambda *args, **kwargs: sum(args) + sum(kwargs.values())


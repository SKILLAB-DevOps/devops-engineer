#############
4.5 Functions
#############

Functions - blocks of code that are designed to do one specific job.

=====================
How to use functions?
=====================

.. code-block:: python
    
    def hello_world():
        """Display a simple greeting.
        
        Args:
            None

        Returns:
            None
        """
        print("Hello World!")

    hello_world()

Passing arguments to the function

.. code-block:: python
    
    def hello_name(username):
        """Display a simple greeting with one parameters.
        
        Args:
            username (str): The username of your user

        Returns:
            None
        """
        print(f"Hello World {username.upper()}!")

    hello_name('skillab')

==========================
Input - Multiple arguments
==========================

A function call would require multiple arguments since a function specification could contain many parameters.

There are many different ways to give arguments to your functions: 
    
    - **keyword arguments**, where each argument consists of a variable name and a value, lists and dictionaries of values
    - **positional arguments**, which must be in the same order as the parameters were written.

.. code-block:: python
    
    # Positional arguments
    def hello_name(username, email):
        """Display a simple greeting with 2 parameters.
        
        Args:
            username (str): The username of your user
            email (str): The email of your user

        Returns:
            None
        """
        print(f"Hello World {username.upper()} with {email.upper()}!")

    hello_name('skillab', 'admin@skillab.com')

    # Keyword arguments
    def hello_name(username, email):
        """Display a simple greeting with 2 parameters.
        
        Args:
            username (str): The username of your user
            email (str): The email of your user

        Returns:
            None
        """
        print(f"Hello World {username.upper()} with {email.upper()}!")

    hello_name(username='skillab', email='admin@skillab.com')
    hello_name(email='admin@robotdreams.com', username='robotdreams')

    # Best practice is to specify default values and also document them
    def hello_name(username='skillab', email='admin@skillab.com'):
        """Display a simple greeting with 2 parameters.
        
        Args:
            username (str): The username of your user
            email (str): The email of your user

        Returns:
            None
        """
        print(f"Hello World {username.upper()} with {email.upper()}!")

    hello_name(email='admin@robotdreams.com', username='robotdreams')
    hello_name(username='robotdreams')
    hello_name()

=============
Return Values
=============

- A function's result should not always be displayed on screen.
- A value or combination of values may be returned after processing some data, as an alternative.
- A return value is the value that the function returns.
- A value is taken from a function's return statement and sent back to the line that called the function.
- Return values let you relocate a lot of your program's manual tasks into functions, which can reduce the code itself.

.. code-block:: python

    def hello_name(username='skillab', email='admin@skillab.com'):
        """Display a simple greeting with 2 parameters.
        
        Args:
            username (str): The username of your user
            email (str): The email of your user

        Returns:
            string: a string with information about user and mail
        """
        return f"Hello World {username.upper()} with {email.upper()}!"

    hello_world = hello_name()
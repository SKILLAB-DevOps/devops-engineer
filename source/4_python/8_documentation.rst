#########################
4.8 Documenting your code
#########################

=========================================
Why Documenting Your Code Is So Important
=========================================

.. tip::

    “Code is more often read than written.”

    — Guido van Rossum


.. important::
    
    Every piece of code you write code has three primary audiences:

    1. your users
    2. your developers 
    3. you

    **Everyone is equally important!**

.. warning::

    "Well, Miss Barrett, when that passage was written only God and Robert Browning understood it. Now, only God understands it."

    — Robert Browning

.. attention::

    “It doesn't matter how good your software is, because if the documentation is not good enough, people will not use it.“

    — Daniele Procida

===================================
Commenting vs Documenting your code
===================================

`Comments` - to explain a decision in code

`Documentation` - information about how to install, use, update, debug.

++++++++++
Docstrings
++++++++++

The use of Python documentation strings, sometimes known as "docstrings," makes it simple to link documentation to specific Python modules, functions, classes, and methods.

It is stated in source code that it is used to document a particular section of code, much like a comment.
The docstring should explain what the function does, not how it accomplishes it, unlike traditional source code comments. 

More about Docstring Conventions in https://peps.python.org/pep-0257/.

-----------------
Google Docstrings
-----------------

More about https://github.com/google/styleguide/blob/gh-pages/pyguide.md#38-comments-and-docstrings

.. code-block:: python

    def hello_name(username='skillab', email='admin@skillab.com'):
        """Display a simple greeting with 2 parameters.
        
        Args:
            username (str): The username of your user (default is skillab)
            email (str): The email of your user (default is admin@skillab.com)

        Returns:
            string: a string with information about user and mail
        """
        return f"Hello World {username.upper()} with {email.upper()}!"

---------------------------
reStructuredText Docstrings
---------------------------

More about http://docutils.sourceforge.net/rst.html

.. code-block:: python

    def hello_name(username='skillab', email='admin@skillab.com'):
        """Display a simple greeting with 2 parameters.
        
        :param username: The username of your user (default is skillab)
        :type username: str
        :param email: The email of your user (default is admin@skillab.com)
        :type email: str
        :returns: a string with information about user and mail
        :rtype: string
        """
        return f"Hello World {username.upper()} with {email.upper()}!"

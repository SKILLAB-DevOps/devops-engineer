################
6.1 Installation
################

=====================
Installation on Linux
=====================

.. warning::

   Python is also used by the Linux kernel, take care of how you update the default one

Setup Python virtual environment

.. code-block:: bash

   # Create a virtual environment
   python3 -m venv venv

   # Activate the virtual environment
   source venv/bin/activate

To install a Python package we will use

.. code-block:: bash

   # Install a Python package
   pip install sphinx

But for this case, we will run

.. code-block:: bash
   
   # Install all dependencies
   pip install -r requirements.txt

---------------
Getting started
---------------

To create a quickstart documentation we will run:

.. code-block:: bash

   # Create a quickstart documentation
   sphinx-quickstart

---------------------------
Install Read-the-docs theme
---------------------------

.. code-block:: bash

   # Install Read-the-docs theme
   pip install sphinx-rtd-theme

Added code in your ```conf.py``` file

.. code-block:: bash

   import sphinx_rtd_theme

   extensions = [
         'sphinx_rtd_theme',
   ]

   html_theme = "sphinx_rtd_theme"

Build documentation

.. note:: 

   If you don't have to make installed it, you can install it.

.. code-block:: bash

   sudo apt install make

Then run (you should run this command from the root of the project)

.. code-block:: bash
   
   make html

.. note:: 

   **Complete documentation**: https://www.sphinx-doc.org/en/master/index.html

========================
What are all these files
========================

--------------
File structure
--------------

Your file system should now look similar to this

.. code-block:: bash

    docs-as-code
    ├── build
    └── source
    ├── index.rst
        ├── conf.py
        ├── _build
        ├── _static
        ├── _templates
    ├── venv
    ├── .gitignore
    ├── Makefile
    ├── make.bat
    └── requirements.txt

We have a top-level docs directory in the main project directory. Inside this is:

``index.rst``:

        This is the index file for the documentation, or what lives at /. It normally contains a Table of Contents that will link to all other pages of the documentation.

``conf.py``:

        Allows for customization of Sphinx. You would not need to use this too much yet, but it is good to be familiar with this file.

``Makefile`` & ``make.bat``:

        This is the main interface for local development, and should not be changed.

``_build``:

        The directory that your output files go into.

``_static``:

        The directory includes all your static files, like images.

``_templates``:

        Allows you to override Sphinx templates to customize the look and feel.

``venv``:

        The Python virtual environment where we will install all dependencies.

``requirements.txt``

        The Python requirements needed to install sphinx.

``.gitignore``

        A special file is interpreted by git and will ignore adding files or directories.

``.nojekyll``

        A special file interpreted by GitHub will allow us to push our site.

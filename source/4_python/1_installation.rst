################
4.1 Installation
################

===========================
Install on WSL(Ubuntu22.04)
===========================

Python is already installed on your machine (the Linux Kernel is using it) - with version 3.12.

But because ``Python3.11`` has a major performance improvement - we want it or something later.

.. code-block:: bash

    # Add deadsnakes(from old versions of Python) repository
    # More information about deadsnakes https://github.com/deadsnakes/
    sudo add-apt-repository ppa:deadsnakes/ppa

    # Refresh the cache using the below command.
    sudo apt update

    # And install Python 3.12 using the below command.
    sudo apt install python3.12 python3.12-venv -y

====================
Virtual Environments
====================

.. important::

    In order not to affect the Kernel, we are using virtual environments.

Applications written in Python frequently use packages and modules that are not included in the standard library.
Applications will sometimes require a particular version of a library because they may need a specific issue to be solved or they may have been created using an outdated version of the library's interface.

Making a virtual environment — a self-contained directory tree including a Python installation for a certain version of Python and a number of additional packages—is the answer to this issue.

In Python we normally don't use as much docker when deploying/running applications - we use Virtual Environment

More about virtual environments: https://docs.python.org/3/tutorial/venv.html

.. code-block:: bash

   python3.12 -m venv venv
   source venv/bin/activate

   # Once in venv run
   python3.12
   
   # Write your hello world
   print("Hello World")

   # To exit
   # Control+D or write exit()

   # Care about the different version of Python
   # If you run
   python
   # or
   python3
   # or
   python3.12

   # That means our shebang will be different
   #!/usr/bin/env python3.12

===========================
Set Default Python Versions
===========================

.. note::

    You can install multiple versions of Python in Linux distros, but the default can only be one version.

.. warning::

    Make sure you know which applications depend on Python 3.10, because you can break some application

You can easily find it out using apt-cache rdepends command as below.

.. code-block:: bash

    apt-cache rdepends python3.10

Create symbolic links for the executable and set it up as default

.. code-block:: bash
    
    # Use update-alternatives to create symbolic links to python3
    sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1
    sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 2


    # And choose which one to use as Python3 via the command:
    sudo update-alternatives --config python3

========================
Manage multiple versions
========================

++++++++++++
How It Works
++++++++++++

At a high level, ``pyenv`` intercepts Python commands using shim executables injected into your PATH, determines which Python version has been specified by your application, and passes your commands along to the correct Python installation.

++++++++++++++++++
Understanding PATH
++++++++++++++++++

When you run a command like python or pip, your operating system searches through a list of directories to find an executable file with that name. This list of directories lives in an environment variable called PATH, with each directory in the list separated by a colon:

``/usr/local/bin:/usr/bin:/bin``

Directories in PATH are searched from left to right, so a matching executable in a directory at the beginning of the list takes precedence over another one at the end. In this example, the /usr/local/bin directory will be searched first, then /usr/bin, then /bin.
Understanding Shims

pyenv works by inserting a directory of shims at the front of your PATH:

``$(pyenv root)/shims:/usr/local/bin:/usr/bin:/bin``

Through a process called rehashing, ``pyenv`` maintains shims in that directory to match every Python command across every installed version of Python—python, pip, and so on.

Shims are lightweight executables that simply pass your command along to ``pyenv``.
So with ``pyenv`` installed, when you run, ``pip``, your operating system will do the following:

    - Search your PATH for an executable file named pip
    - Find the pyenv shim named pip at the beginning of your PATH
    - Run the shim named pip, which in turn passes the command along to ``pyenv``

.. note::

    You can install multiple versions of Python in Linux distros, but the default can only be one version.

.. warning::

    Make sure you know which applications depend on Python 3.10, because you can break some application

You can easily find it out using apt-cache rdepends command as below.

.. code-block:: bash

    apt-cache rdepends python3.10

Install pyenv

.. code-block:: bash

    # Install dependencies
    sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev

    # Install pyenv
    curl https://pyenv.run | bash

    # Add pyenv to PATH

    #WARNING: seems you still have not added 'pyenv' to the load path.

    # Load pyenv automatically by appending
    # the following to
    ~/.bash_profile if it exists, otherwise ~/.profile (for login shells)
    and ~/.bashrc (for interactive shells) :

    export PYENV_ROOT="$HOME/.pyenv"
    command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"

    # Restart your shell for the changes to take effect.

    # Load pyenv-virtualenv automatically by adding
    # the following to ~/.bashrc:

    eval "$(pyenv virtualenv-init -)"

=============
Where to code
=============

++++++++++++++++++++++++++
1. Python's embedded shell
++++++++++++++++++++++++++

.. note::
    
    Why???

+++++++++++++++++
2. Microsoft Code
+++++++++++++++++

A powerful, lightweight free code editor with integrated tools to easily deploy your code to Azure. - https://code.visualstudio.com/

**PRO**:
    - lots of extensions
    - available Linux and Windows
    - can run code on WSL
    - support for Azure, docker and Kubernetes
**CON**:
    - some extensions are behind a paywall
    - you need to tune it before it's amazing

+++++++++++++++++++
3. Jupyter Notebook
+++++++++++++++++++

JupyterLab is the latest web-based interactive development environment for notebooks, code, and data. Its flexible interface allows users to configure and arrange workflows in data science, scientific computing, computational journalism, and machine learning. A modular design invites extensions to expand and enrich functionality. - https://jupyter.org/

It's Python based so you need to install it using ``pip``

.. code-block:: bash

    # If you have not created and activated venv
    python3.12 -m venv venv
    source venv/bin/activate
    
    # Install 
    pip install jupyter

    # Run
    jupyter notebook

    # Copy the link into a browser

**PRO**:
    - it allows you to start and play with code
    - is amazing for data science/ml or if you're trying to visualize data
    - can be run on a server and multiple people can access it
    - is embedded into Microsoft Code
**CON**:
    - it's not for OOP programming
    - hard to work if the feed will grow too much

4. PyCharm

PyCharm is an integrated development environment (IDE) used in computer programming, specifically for the Python language. It is developed by the Czech company JetBrains. It provides code analysis, a graphical debugger, an integrated unit tester, integration with version control systems (VCSes), and supports web development with Django as well as data science with Anaconda. - https://www.jetbrains.com/pycharm/

**PRO**:
    - lots of extensions
    - available Linux and Windows
    - can run code on WSL
    - support for Azure, docker and Kubernetes

**CON**:
    - some extensions are behind a paywall
    - you need to tune it before it's amazing

5. vim or nano

.. note::

    If you're using vim or nano you're a masochist
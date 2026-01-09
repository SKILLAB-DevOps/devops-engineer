##############
4.15 Packaging
##############

Packaging in Python refers to the process of bundling code into a distributable format that can be easily installed and used by others. A Python package typically contains a collection of Python modules, accompanied by metadata like package name, version, and dependencies. This makes it easier to manage, distribute, and install software libraries and applications.

============================
Libraries Used for Packaging
============================

    1. ``setuptools``: The most widely used packaging library in Python. It includes functionalities for building, installing, and distributing Python packages.
    2. ``wheel``: A built-package format for Python that provides faster installation compared to traditional source distributions.
    3. ``pip``: Not a packaging library per se, but it's the package installer for Python that works in conjunction with packaging libraries to install packages.
    4. ``twine``: Utility for securely uploading packages to PyPI (Python Package Index).
    5. ``conda``: A cross-platform package manager that can also handle Python packages. Often used in data science and scientific computing contexts.
    6. ``poetry``: A more modern packaging tool that aims to improve package creation and management, with a focus on simplicity and being opinionated.
    7. ``flit``: Simplified package creator that makes it easier to make a package out of simple Python modules.

The ``wheel`` format is a newer standard than the ``egg`` format, and is designed to replace the ``egg`` format. The ``wheel`` format is specified in PEP 427, and it has several advantages over the egg format and other previous packaging formats:

    - faster installation
    - fewer incompatibilities between Python versions
    - easier creation of packages
    - safer installation (no arbitrary code execution) - arbitrary code execution means that a user can run any code they want on your computer
    - consistent behavior across platforms
    - more consistent file naming and location conventions
    - less implementation complexity

====
Pros
====

    1. Reusability: Once a package is created, it can be easily shared, reused, and installed on other systems.
    2. Version Control: Packaging allows versioning, which helps in using and maintaining different versions of the same package.
    3. Dependency Management: Packages can specify dependencies, making it easier for users to install everything they need.
    4. Professionalism: Packaging your code makes it accessible and usable, which can be essential if you're trying to share it for public consumption or even within a large organization.

====
Cons
====

    1. Complexity: The packaging process can be complex, especially for beginners or for projects with complex dependencies.
    2. Maintenance: Once a package is public, it requires ongoing maintenance to keep it updated and to fix bugs.
    3. Package Conflicts: Multiple packages might have conflicting dependencies, making package management challenging.
    4. Security Concerns: Public packages can be a vector for malware if not properly vetted.

==========================================
Creating a simple package using setuptools
==========================================

1. Directory Structure

    ::

        my_package/
        ├── my_module.py
        └── setup.py
        
2. ``my_module.py``: This file contains the actual Python code.

    .. code-block:: python

        def hello_world():
            return "Hello, world!"
        
3. ``setup.py``: This file contains metadata about your package.

    .. code-block:: python

        from setuptools import setup

        setup(
            name="my_package",
            version="0.1",
            description="A simple package",
            author="Your Name",
            author_email="your.email@example.com",
            packages=["my_package"],
        )

4. Building the Package

Open the terminal, navigate to the directory containing ``setup.py``, and run:

    .. code-block:: python

        python setup.py sdist bdist_wheel
        # This will create a source distribution (sdist) and a built distribution (bdist_wheel) under a dist/ directory.

5. Installing the Package Locally

    .. code-block:: python

        pip install ./dist/my_package-0.1-py3-none-any.whl

6. Using the Package

Now, in any Python script, you can do:

    .. code-block:: python

        import my_package.my_module

        print(my_package.my_module.hello_world())  # Output: Hello, world!

7. Uploading to PyPI (Optional)

    .. code-block:: python

        # First, install twine:
        pip install twine
        
        # Then, upload your package:
        twine upload dist/*
        
        # You'll need a PyPI account, and you'll be prompted for your credentials during the upload process.
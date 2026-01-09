##################
4.7 Your first CLI
##################

=========
Libraries
=========

For building a ``cli`` (Command Line Interface) you can write pure Python (no external libraries) or use a library like:

- `Click <https://click.palletsprojects.com/en/8.1.x/>`_
- `Invoke <https://www.pyinvoke.org//>`_
- `Tox <https://github.com/tox-dev/tox>`_
- `Typer <https://typer.tiangolo.com/>`_
- `Python Fire <https://github.com/google/python-fire>`_
- `Argparse <https://docs.python.org/3/library/argparse.html>`_

===============
Getting started
===============

1. Install ``click`` library.

    .. code-block:: bash

        pip install click

2. Create the directory and the file structure.

    :: 

        cli  # directory project
        ├── devops_cli  # directory package
        │  ├── __init__.py
        │  └── devops_cli.py  # your script
        └── setup.py

    .. note::
        
        The Python interpreter is informed that a directory contains code for a Python module by the ``__init__.py`` file.
        A file named ``__init__.py`` may be empty.
        You cannot import modules into your project from another location without one.

3. Write your first ``cli``.

    .. code-block:: python

        import click
        import psutil

        @click.group()
        def cli():
            """Simple command line tool to extract system information."""

        @cli.command("cpu", short_help="Show CPU")
        def cpu():
            """Shows CPU Resources."""
            click.echo(psutil.cpu_times())

        @cli.command("disk", short_help="Show Disk")
        def disk():
            """Shows Disk Status."""
            click.echo(psutil.disk_partitions())

#####################
3.4 Shell Style Guide
#####################

==============
1. File Header
==============

Start each file with the environment where it will run (the ``#!`` shebang) and a description of its contents.

Every file must have a top-level comment including a brief overview of its contents and usage. Copyright notice and author information are optional, if there are no regulatory requirements to be avoided, because you need to update it every time you change the file.

Example:

.. code-block:: bash

    # !/usr/bin/env bash
    # Automates the git push process.
    # Usage: ./scriptName
    # Author: Skillab Team
    # Copyright: Bla Bla Bla

=================
2. File extension
=================

Although we learn in school that we need one, an executable shouldn't have an extension. We need to have the shebang.

.. code-block:: bash

    # !/usr/bin/env python
    # !/usr/bin/env perl
    # !/usr/bin/env bash

==================================================
3. Always capture the STDOUT and STDERR into a log
==================================================

Example:

.. code-block:: bash
    
    # !/usr/bin/env bash

    err() {
      echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] [ERROR]: $*" >> script.log
    }

    if ! do_something; then
        err "Unable to do_something"
        exit 1
    fi

===========
4. Comments
===========

--------------
1. File Header
--------------

.. code-block:: bash

    # !/usr/bin/env bash

    ######################################
    # Automates the git push process.
    # Usage: ./scriptName
    # Author: Skillab Team
    # Copyright: Bla Bla Bla
    ######################################

--------------------
2. Function Comments
--------------------

All function comments should describe the intended API behavior using:

    #. Description of the function.
    #. Globals: List of global variables used and modified.
    #. Arguments: Arguments took.
    #. Outputs: Output to STDOUT or STDERR.
    #. Returns: Returned values other than the default exit status of the last command run.

Example:

.. code-block:: bash

    ######################################
    # Cleanup files from the backup directory.
    # Globals:
    #    BACKUP DIR
    #    TIME TO KEEP THE BACKUP
    # Arguments:
    #    None
    # Returns:
    #    None
    ######################################

    function cleanup() {

      …
    }

--------------------------
3. Implementation Comments
--------------------------

.. code-block:: bash

    # We're using the library x due a bug in conflict with library y

----------------
4. TODO Comments
----------------

Use TODO comments for temporary code, a short-term solution, or good enough but not perfect. Just avoid them, I have lots of TODO from like 7 years ago.

.. code-block:: bash

    # TODO: Works but we don't know why 

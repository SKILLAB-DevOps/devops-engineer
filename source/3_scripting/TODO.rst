####
TODO
####

===========================
1. Create a loading spinner
===========================

* find out how to use arrays

* learn to create scripts that run continuously

.. code-block:: bash
  
    touch spinner && chmod u+x spinner && vim spinner

.. code-block:: bash

    # !/usr/bin/env bash

    # declare array
    array=('-' '\' '|' '/')

    # loop until stopped
    while true; do
        # for every element in the array
        for c in "${array[@]}"; do

        # man echo
        # \-n     do not output the trailing newline
        # \-e     enable interpretation of backslash escapes
        echo \-en "\\r $c "

        # wait for half a second
        sleep .5

        # close for
        done
    # close while
    done


Run the script ``spinner``

=================================
2. Creating a backup of your home
=================================

How to create a backup?

Creating an archive from a directory, adding also the date in the name.


.. code-block:: bash

    tar --help
    man tar
    date


The script name will be ``BackUp1``

Creating, adding permission and opening the file

.. code-block:: bash

    touch BackUp1 && chmod u+x BackUp1 && vim BackUp1

.. code-block:: bash

    # !/usr/bin/env bash

    # create a backup of the home directory

    tar -czf /tmp/home/backup`date +"%Y*%m_%d"` ~/sandbox


======
Task 1
======

Create a script ``wikiPython`` that reads a Wikipedia page - https://en.wikipedia.org/wiki/Python_(genus) (use ``curl`` command)

    #. extracts Species elements - python name (what kind of pythons are there) - use ``grep``
    #. save the output the to a new file 
    #. append to the new file the last line that is the count of species - using ``wc``

======
Task 2
======

Create a script ``weather.py`` that give you the weather from curl https://wttr.in/(location)

    #. the location will be read from the keyboard - example ``weather Bucharest``
    #. test that you have the location
    #. test that location is a valid string and doesn't contain numbers using a regex operator compare a variable with ``$var =~ '^[0-9]+$'``

======
Task 3
======

Create a health check script ``healthCheck`` that looks at:

    #. ``date`` and time
    #. the ``uptime`` of the machine
    #. how much disk ``df`` and memory usage ``free``
    #. top most expensive process
    #. run this every 2 seconds using ``sleep`` or ``watch``

======
Task 4
======

Create a script that reads the file ``source_code/scripting/data/ip.txt`` and:

    #. Find out how many different IPs?
    #. How many exit different codes?
    #. How many occurrences of each exit code?
    #. How often an IP appears?
    #. Which IP has experienced the most successes and failures?

======
Task 5
======

Create a script that reads the file ``source_code/scripting/data/hadoop.log`` and:

    #. Find out how many INFO, WARN ERROR messages are, and print the percentage compared to the total lines
    #. Which error appears most frequently?
    #. Are there any weird messages in the log?

======
Task 6
======

Create a script ``randomWords.sh`` that generated with 1000 random words file from the ``/usr/share/dict/words``

    #. use ``shuf`` command to generate random words
    #. use ``head`` command to get the first 1000 words
    #. count all the words that have 9 characters using ``awk`` and ``wc``

======
Task 7
======

Create a ``Makefile`` that has the following targets:

    #. ``install`` - that installs the script ``healthCheck`` in ``/usr/local/bin``
    #. ``uninstall`` - that removes the script ``healthCheck`` from ``/usr/local/bin``
    #. ``test`` - that runs the script ``healthCheck`` and saves the output to a file ``healthCheck.log``
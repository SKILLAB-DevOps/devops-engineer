####################################
3.2 Data structures and conditionals
####################################

===============
DATA STRUCTURES
===============

``<variable_name>=<value>``

Notice that there are no spaces before and after the equal (=) operator; otherwise, you'll get an error. Why? Because the shell will interpret the ``variable_name`` as a command, not a variable.


* Variable ``PATH_TO_FILES='/some/path'``
* Constants ``readonly PATH_TO_FILES='/some/path'``
* Lists/Arrays

.. code-block:: bash

    # !/usr/bin/env bash
    declare -a projects

    # Instantiate the array with values
    projects=("introduction" \
              "environments" \
              "linux" \
              "scripts" )

============
CONDITIONALS
============

-------------
IF CONDITIONS
-------------

.. code-block:: bash

    if [[ condition ]]; then
    elif
        [COMMANDS]
    else
        [COMMANDS]
    fi

Example

.. code-block:: bash
  
    touch conditional && chmod u+x conditional && vim conditional

.. code-block:: bash

    # !/usr/bin/env bash

    if [[ ${1} -ge 10 ]]; then
        echo "Number is greater than 10"
    else
        echo "Number is lower than 10"
    fi

=====
LOOPS
=====

--------
FOR LOOP
--------

.. code-block:: bash

    # !/usr/bin/env bash

    for item in [LIST]; do
        [COMMANDS]
    done

Example:

.. code-block:: bash
  
    touch for_loop1 && chmod u+x for_loop1 && vim for_loop1

.. code-block:: bash

    # !/usr/bin/env bash

    for i in {1..10}; do
        echo "Print ${i}"
    done

.. code-block:: bash
  
    touch for_loop2 && chmod u+x for_loop2 && vim for_loop2

.. code-block:: bash

    # !/usr/bin/env bash

    for i in /var/*; do
      echo $i 
    done

----------
WHILE LOOP
----------

.. code-block:: bash
    
    # !/usr/bin/env bash

    while [ condition ]; do
        [COMMANDS]
    done

Example

.. code-block:: bash
  
  touch while_loop && chmod u+x while_loop && vim while_loop

.. code-block:: bash

    # !/usr/bin/env bash

    num=1
    while [ $num -le 10 ]; do
        echo $(($num * 7))
        num=$(($num+1))
    done

----------
UNTIL LOOP
----------

.. code-block:: bash

    until [ condition ]; do
    [COMMANDS]
    Done

Example:

.. code-block:: bash
  
    touch until_loop && chmod u+x until_loop && vim until_loop

.. code-block:: bash
    
    # !/usr/bin/env bash

    num=1
    until [ $num -gt 10 ]; do
        echo $(($num * 7))
        num=$(($num+1))
    done

.. warning::

    Don't forget about ``-le`` vs ``-lt`` and ``-ge`` vs ``gt``

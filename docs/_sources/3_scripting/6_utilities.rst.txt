#############
3.6 Utilities
#############

=======================
1. Generating test data
=======================

Most of the time we will need test data to work with. 

The ``wordlist`` command is used to generate a list of words. 

To install the command on Ubuntu, run the following command:

.. code-block:: bash

    # if you try to install wordlist, you will get the following error
    sudo apt install wordlist

    # Result will be
    # Reading package lists... Done
    # Building dependency tree... Done
    # Reading state information... Done
    # Package wordlist is a virtual package provided by:
    # wspanish 1.0.30
    # witalian 1.10
    # wfrench 1.2.7-2
    # wswedish 1.4.5-3
    # wcatalan 0.20111230b-14
    # wcanadian-small 2020.12.07-2
    # wcanadian-large 2020.12.07-2
    # wcanadian-insane 2020.12.07-2
    # wcanadian-huge 2020.12.07-2
    # wcanadian 2020.12.07-2
    # wbritish-small 2020.12.07-2
    # wbritish-large 2020.12.07-2
    # wbritish-insane 2020.12.07-2
    # wbritish-huge 2020.12.07-2
    # wbritish 2020.12.07-2
    # wamerican-small 2020.12.07-2
    # wamerican-large 2020.12.07-2
    # wamerican-insane 2020.12.07-2
    # wamerican-huge 2020.12.07-2
    # wamerican 2020.12.07-2
    # wnorwegian 2.2-4
    # miscfiles 1.5+dfsg-4
    # wgerman-medical 20220425-1
    # wportuguese 20220621-1
    # wukrainian 1.8.0+dfsg-1
    # wgalician-minimos 0.5-48
    # wfaroese 0.4.2+repack1-4
    # wpolish 20220301-1
    # wswiss 20161207-11
    # wngerman 20161207-11
    # wogerman 1:2-38
    # wesperanto 2.1.2000.02.25-61
    # wdutch 1:2.20.19-2
    # wdanish 1.6.36-14
    # wbrazilian 3.0~beta4-24
    # wbulgarian 4.1-7
    # You should explicitly select one to install.

    # E: Package 'wordlist' has no installation candidate
    # You need to install one of the packages listed above to get wordlist command
    sudo apt-get install wamerican-small

To generate a file with 1000 words, run the following command:

.. code-block:: bash

    # Pick 1000 random words and write them to random_words.txt
    shuf -n 1000 /usr/share/dict/words > random_words.txt

If you want more control over the words you can use awk to filter the words.

.. code-block:: bash

    # Pick 1000 random words and write them to random_words.txt
    awk 'length($0) > 5 && length($0) < 10' /usr/share/dict/words | shuf -n 1000 > random_words.txt


==========
2. ``sed``
==========

``sed``, short for "stream editor," is a command-line utility that allows for parsing and transforming text. It is commonly used for text substitutions, deletions, insertions, and more. Available on UNIX and UNIX-like operating systems such as Linux and macOS, ``sed`` reads text input—either from a file or from a stream—edits it according to a set of expressions or commands, and then outputs the edited text.

++++++++++++
Basic Syntax
++++++++++++

The basic syntax of a sed command is:

.. code-block:: bash

    sed [options] 'command' [input-file]

+++++++++++++++++
Common Operations
+++++++++++++++++

**Substitute**: Replace occurrences of a string (or regular expression) with another string.

.. code-block:: bash

    # Replace 'apple' with 'orange' in the file random_words.txt
    sed 's/apple/orange/' random_words.txt

.. note::
    
    Note that this only replaces the first occurrence of 'apple' on each line. To replace all occurrences, you'd use the g (global) flag:

.. code-block:: bash
    
    sed 's/apple/orange/g' random_words.txt

**Delete Lines**: Remove lines that match a particular pattern.

.. code-block:: bash

    # Delete all lines containing 'apple' from the file fruits.txt
    sed '/apple/d' random_words.txt

**Insert and Append**: Insert or append lines around a match.

.. code-block:: bash

    # Insert a line "Fruits:" before every line containing 'apple'
    sed '/apple/i\Fruits:' random_words.txt

    # Append a line "Yummy!" after every line containing 'apple'
    sed '/apple/a\Yummy!' random_words.txt

+++++++
Options
+++++++

1. ``-i``: Edit the file in-place (use with caution).

.. code-block:: bash

    sed -i 's/apple/orange/g' random_words.txt
    # This replaces all instances of 'apple' with 'orange' in random_words.txt, modifying the file directly.

2. ``-n``: Suppress automatic printing (useful with the ``p`` command to print specific lines).

.. code-block:: bash

    # Print only lines containing 'apple'
    sed -n '/apple/p' random_words.txt

3. ``-e``: Allows for multiple editing commands.

.. code-block:: bash

    sed -e 's/apple/orange/' -e 's/banana/peach/' random_words.txt
    # This replaces the first instance of 'apple' with 'orange' and the first instance of 'banana' with 'peach' on each line.

3. ``-f``: Specifies a file that contains sed commands.

.. code-block:: bash
    
    sed -f commands.sed random_words.txt
    # Here, commands.sed is a file containing sed commands that are to be applied to random_words.txt.

==========
3. ``awk``
==========

``awk`` is a text-processing utility in Unix-like operating systems that is often used for data extraction and reporting. Named after its original authors—**Alfred Aho, Peter Weinberger, and Brian Kernighan**- ``awk`` interprets a special-purpose programming language designed to handle a wide range of text manipulation tasks. It's particularly good for working with tabular data or text files separated by delimiters like commas, spaces, or tabs.

Basic Syntax
The basic syntax of awk is:

.. code-block:: bash

    awk 'pattern { action }' file

- **pattern**: Specifies a condition, or a set of conditions. If the pattern matches, the corresponding action is executed.
- **action**: Describes what to do when a match for the pattern is found in the text or stream.
- **file**: The file to read the data from.

Simple Example
Let's say you have a text file named ``party.txt`` containing:

.. code-block:: bash
    
    Tequila 4
    Vodka 6
    Wine 12
    Beer 48

You could use awk to print just the second column:

.. code-block:: bash

    awk '{ print $2 }' party.txt

This would output:

.. code-block:: bash

    4
    6
    12
    48

+++++++++++++++++++++++++
Features and Capabilities
+++++++++++++++++++++++++

1. Column manipulation: ``awk`` is commonly used to read and manipulate columnar data.

.. code-block:: bash

    # Prints the first column of the file "party.txt"
    awk '{ print $1 }' party.txt

2. Text Transformation: You can use ``awk`` to perform a variety of text transformations.

.. code-block:: bash

    # Converts the first column of data to lowercase
    awk '{ print tolower($1) }' data.txt

3. Mathematical Operations: ``awk`` can perform various mathematical operations.

.. code-block:: bash

    # Sum the second column of the file "data.txt"
    awk '{ sum += $2 } END { print sum }' data.txt

4. Conditional Statements: ``awk`` supports if-else, while, for loops, and more.

.. code-block:: bash

    awk '{ if ($2 > 10) print $1 " has value greater than 10"; else print $1 " has value less or equal to 10" }' data.txt

5. String Manipulation: awk offers functions for substring,
length, and other string manipulations.

.. code-block:: bash

    awk '{ print length($1) }' data.txt  # prints the length of the first column

6. Built-in Functions: awk has a number of built-in functions for string manipulation, mathematical operations, and more.

.. code-block:: bash

    awk '{ print sqrt($2) }' data.txt  # prints the square root

##################
1.5 Getting around
##################

======================
1. A sense of location
======================

.. note::

	Always know where are you!

.. code-block:: bash

	pwd

Now to the command itself. ``pwd`` is an abbreviation of "print working directory". All it does is print out the shell's current working directory. But what is a working directory?

One important concept to understand is that the shell has a notion of a default location in which any file operations will take place. This is its working directory. If you try to create new files or directories, view existing files, or even delete them, the shell will assume you are looking for them in the current working directory unless you take steps to specify otherwise. So it's quite important to keep an idea of what directory the shell is “in” at any given time, after all, deleting files from the wrong directory could be disastrous. If you are ever in any doubt, the ``pwd`` command will tell you exactly what the current working directory is.

You can change the working directory using the ``cd`` command, an abbreviation for "change directory".

.. code-block:: bash

	cd /

.. warning:: 

	Too many roots
	
	Beware: although the ``/`` directory is sometimes referred to as the ``root`` directory, the word ``root`` has another meaning. ``root`` is also the name that has been used for the superuser since the early days of Unix.

---------------------------------
Understanding what you're running
---------------------------------

Executing commands without understanding what they do, is the best way to fail. To get more information you can look at the help documentation or read the manual.

.. code-block:: bash

	# Getting the documentation for the command
	pwd --help
	
	# Reading the manual
	man pwd

-------------
What is here?
-------------

Executing commands in the terminal sometimes feels like searching for something in the dark. We need to get more information about the current location.

.. code-block:: bash

	# List all the files and directories in the current location
	ls
	
	ls --help
	# ls - command
	# --help - argument
	# think of the arguments as parameters input for functions

We rarely use simple ``ls``, we use.

.. code-block:: bash

	ls -l 
	# or
	ll 

	ls -ltrha
	# -l                         use a long listing format
	# -t                         sort by modification time, newest first
	# -r, --reverse              reverse order while sorting
	# -h, --human-readable       with -l and -s, print sizes like 1K 234M 2G, etc.
	# -a, --all                  do not ignore entries starting with.

---------------------------
Relative and absolute paths
---------------------------

Most of the examples we've looked at so far use relative paths. That is, the place you end up at depends on your current working directory. Consider trying to cd into the ``/etc`` folder. If you're already in the root directory that will work fine:

.. code-block:: bash

	cd / 
	# and
	cd etc

	# or
	cd /etc

------------
Finding home
------------

.. code-block:: bash

	linux_user@linux_machine:/$ cd /
	linux_user@linux_machine:/$ pwd
	/
	linux_user@linux_machine:/$ cd home
	linux_user@linux_machine:/home$ ls
	total 12K
	drwxr-xr-x  3 root root 4.0K Aug 25 12:49 .
	drwxr-xr-x 12 linux_user linux_user 4.0K Oct 25 14:58 linux_user
	drwxr-xr-x 19 root root 4.0K Nov  4 10:53 ..


Try out

.. code-block:: bash

	# home of the user
	cd ~ 

	# Going back to the previous directory
	cd -

	# Moving one step closer to /, getting to a level up
	cd ..

================================
2. Creating your first directory
================================

TODO:

	* Create 3 different directories: ``dir1`` ``dir2`` ``dir3``
	* Remove the 2nd one: ``dir2``
	* Remove the 1st and 3rd one: ``dir1`` ``dir3``
	* Create a directory with subdirectories: ``parent/child/grandchild``
	* Remove them: ``parent/child/grandchild``

.. code-block:: bash

	# Change the directory to the home of the user
	cd ~

	# Create a new sandbox directory where we will work from now
	mkdir sandbox

	# Check that directory was created
	ls -ltrha

	# Change the directory to the 
	cd sandbox

	# Creating multiple directories
	mkdir dir1 dir2 dir3

	# Removing directories
	rmdir dir2
	rmdir dir1 dir3

	# To create a directory structure
	mkdir -p parent/child/grandchild

	mkdir --help
	rmdir --help

	rmdir -p parent/child/grandchild/

=======================
3. Pipe and Redirection
=======================

-----------
Redirection
-----------

Most shells offer the ability to alter the way that application input and output flows. This can direct output away from the terminal and into files or other applications, or otherwise read input from files instead of the terminal.

All applications have three unique streams that connect them to the outside world.

These are referred to as :

	* Standard Input, or stdin
	* Standard Output, or stdout
	* Standard Error, or stderr.

.. code-block:: bash

	cd ~/sandbox

	echo "This is a test"


``echo`` just prints its arguments back out again (hence the name). But combine it with a redirect, and you have got a way to easily create small test files:

.. code-block:: bash

	echo "This is a test" > test_1.txt

	echo "This is a second test" > test_2.txt

	echo "This is a third test" > test_3.txt

	ls

	# Create a list of the existing files
	# > replace the content

	ls > listOfFiles
	# >> append to the content

	ls >> listOfFiles

-------------
Reading files
-------------

.. code-block:: bash

	# find out how to use the read file application
	cat --help

	# Getting the manual of the cat command
	man cat

	# Reading the content of multiple files
	cat test*1.txt test*2.txt test_3.txt

	# Reading the content of multiple files
	cat test_?.txt

	# Reading the content of multiple files
	cat test_*

	# Reading the content of multiple files and redirecting the output to a new file
	cat t* > combined.txt

	cat listOfFiles >> combined.txt

	cat combined.txt

	less combined.txt

.. note::

	When you consider both case sensitivity and escaping, a good rule of thumb is to keep your file names all lowercase, with only letters, numbers, underscores, and hyphens. For files, there is usually also a dot and a few characters on the end to indicate the type of file it is (referred to as the “file extension”). This guideline may seem restrictive, but if you end up using the command line with any frequency you will be glad you stuck to this pattern.|

--------------------------
Redirecting Standard Error
--------------------------

On occasion, we need to redirect standard error instead of standard output. This works in the same way, but we need to specify the exact stream.

.. code-block:: bash

	cat does-not-exist 2> log

---------------------------
Piping Between Applications
---------------------------

The final action that we can perform is to direct the output of one application into another one. This is commonly referred to as piping and uses the | operator instead

.. code-block:: bash

	wc --help
	man wc

	ls | wc

	wc -l combined.txt

	uniq --help
	man uniq

	cat combined.txt | uniq | wc -l
	sort combined.txt | uniq | wc -l

================================
4. Moving and manipulating files
================================

.. code-block:: bash

	mkdir dir1 dir2

	cp listOfFiles dir1

	cp dir1/listOfFiles dir2

	rm -rf dir1

===============
5. Hidden files
===============

Hidden files and directories are commonly used to store configuration data and settings, are hidden, so they don't clutter the view. There is nothing special about them, but they don't show while using the simple ``ls``.

.. code-block:: bash

	cd ~/sandbox

	cp combined.txt .combined.txt

	ls

	ls --help

	mkdir .hidden

	cp combined.txt .hidden

.. warning::

	Unlike graphical interfaces, rm does not move files to a folder called ``trash`` or similar. Instead, it deletes them totally, utterly and irrevocably. 
	You need to be ultra careful with the parameters you use with rm to make sure you are only deleting the files you intend to. 
	
	You should take particular care when using wildcards, as it is easy to accidentally delete more files than you intended. 
	An errant space character in your command can change it completely: ``rm t*`` means “delete all the files starting with t”, whereas ``rm t *`` means “delete the file t as well as any file whose name consists of zero or more characters, which would be everything in the directory! 
	
	If you are at all uncertain use the ``-i`` (interactive) option to rm, which will prompt you to confirm the deletion of each file; enter Y to delete it, N to keep it, and press Ctrl-C to stop the operation entirely.|

.. warning::

	Writing 1 line of code takes 1 minute, and knowing what line of code takes 1 year
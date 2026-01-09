###################
3.1 Getting started
###################

If you're planning to run this on Fedora container, complete the following section if you plan to work on WSL or directly on your machine skip to the next section and start with ``Create a sandbox location to facilitate script execution``.

=======================================
Prerequisites for executing the scripts
=======================================

* Run a new fedora container

* Create a new privileged user

.. code-block:: bash

    # Create a fedora docker container
    docker run -it fedora bash

    # install utilities (for normal virtual machines we don't need to install them)
    dnf install -y util-linux tree passwd vim

    # Create a new user and add it to the wheel group to have sudo permissions
    
    useradd <NAME> -G wheel

    # setup a password for the user
    
    passwd <NAME>

    # Remove the password request for the sudo commands   
    vim /etc/sudoers

    # comment
    # Allows people in group wheel to run all commands
    %wheel ALL=(ALL)       ALL
    
    # And uncomment
    # Same thing without a password
    %wheel  ALL=(ALL)       NOPASSWD: ALL

    # switch to the newly created user

    su <NAME>

=========================================================
Create a sandbox location to facilitate script execution.
=========================================================

.. code-block:: bash

    # change the directory to user's home
    cd 

    # create a new sandbox
    mkdir sandbox

    #change the directory to the new directory
    cd sandbox

    # or run everything in one single command
    mkdir ~/sandbox && cd ~/sandbox

    # Update bash profile file with the location of the scripts so we can call them directly from everywhere
    # Open file using vim

    # .bashrc and .bash_profile are 2 files that host all our custom settings for the bash shell
    vim ~/.bashrc

    # add at the end of the file the line and save
    export PATH="$PATH:/home/${USER}/sandbox/scripts"

    # sourcing means that you run a file to get some variables out of it
    source ~/.bashrc

===========================
1. Making your first script
===========================

    #. Create a script
    #. Add executable permission
    #. Add content
    #. Run the script

.. code-block:: bash

    # Create script
    touch HelloWorld1

    # add executable permission
    chmod u+x HelloWorld1

    # Edit content
    vim HelloWorld1   

---------------------------------
Add inside the file and then save
---------------------------------

.. code-block:: bash

    # !/usr/bin/env bash
    echo "Hell on World"

--------------------------------
Run the script using the command
--------------------------------

.. code-block:: bash

    bash HelloWorld1
    # or
    ./HelloWorld1

    # or if the script location is in PATH
    HelloWorld1

================
INPUT and OUTPUT
================

----
read
----

.. code-block:: bash

    touch Input1 && chmod u+x Input1 && vim Input1

.. code-block:: bash

    # !/usr/bin/env bash
    read name
    echo "Hello, $name"

Run using 

.. code-block:: bash
  
    touch Input2 && chmod u+x Input2 && vim Input2

.. code-block:: bash

    # !/usr/bin/env bash

    read -p "Enter your name: " name
    echo "Hello, $name"

.. code-block:: bash

    touch Input3 && chmod u+x Input3 && vim Input3

.. code-block:: bash
 
    # !/usr/bin/env bash
    echo "Hello, ${1}"

.. code-block:: bash
  
    touch Input4 && chmod u+x Input4 && vim Input4

.. code-block:: bash

    # !/usr/bin/env bash

    echo "Total arguments: $#"
    echo "Script Name = $0"
    echo "First Argument = $1"
    echo "Second Argument = $2"

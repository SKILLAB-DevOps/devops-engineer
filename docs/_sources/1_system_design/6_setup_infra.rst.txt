###################################
1.6 Setup developing infrastructure
###################################

=============
Prerequisites
=============

.. warning::

    You must be running Windows 10 version 2004 and higher (Build 19041 and higher) or Windows 11.

===========
Install WSL
===========

Run the command in an administrator PowerShell or Windows Command Prompt and then restart your machine.

.. image:: ../diagrams/gifs/0_InstallWSL.gif
    :width: 70%
    :alt: Installing packages

.. code-block:: bash

    # POWERSHELL - WINDOWS
    wsl --install

    # Some Windows distributions have obsolete packages, you need to specify the distribution name
    wsl --install -d Ubuntu

    # By default, it will install Ubuntu, to install a different distribution 
    # To see a list of available Linux distributions available for download through the online store, enter:

    wsl --list --online 
    # or
    wsl -l -o.

    # To install additional Linux distributions after the initial install, you may also use the command:
    wsl --install --distribution <Distribution Name>.

===========
Install GUI
===========

.. code-block:: bash

    # Install Kali Linux
    # POWERSHELL - WINDOWS
    wsl --install --distribution kali-linux

    # TERMINAL - KALI LINUX
    # Update the package list and install the Kali Linux Win-KeX package
    sudo apt update
    sudo apt install -y kali-win-kex

    # Start the Kali Linux GUI
    # Inside of Kali WSL
    # TERMINAL - KALI LINUX   
    kex --win -s

    # POWERSHELL - WINDOWS
    # On Window’s command prompt: 
    wsl -d kali-linux kex --win -s

======================
Install Docker Desktop
======================

Open `Docker Desktop Installer <https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe>`_ then run the installer.

.. code-block:: bash

    # POWERSHELL - WINDOWS
    # Create a fedora docker container
    docker run -it fedora bash

    # TERMINAL - FEDORA LINUX   
    # install utilities on the container (for normal virtual machines we don't need to install them)
    dnf install util-linux tree passwd

To find what distribution and version of Linux are you running

.. code-block:: bash

    # TERMINAL - LINUX
    # To find what distribution and version of Linux are you running
    cat /etc/os-release

===============
Install VS Code
===============

Install VS Code `VS Code <https://code.visualstudio.com/Download>`_  To be able to run code directly on the WSL we need the WSL Extension

The Linux command line is a text interface to your computer. Often referred to as the shell, terminal, console, prompt, or various other names,

=========================
Setup WSL - Prerequisites
=========================

I decided to upgrade my WSL to the latest version Ubuntu 22.04

Prerequisites:

1. Backup my information (I pushed all the code to git)

2. Stop and remove the WSL

.. code-block:: bash

    # POWERSHELL - WINDOWS
    wsl --shutdown

    wsl --unregister Ubuntu

========================
Setup WSL - Installation
========================

1. List available Linux distributions

.. code-block:: bash

    # POWERSHELL - WINDOWS
    wsl --list --online
    #or 
    wsl -l -o

2. Pick your distribution and install it. For this course we will use Ubuntu.

.. code-block:: bash

    # POWERSHELL - WINDOWS
    wsl --install -d Ubuntu

3. Access the WSL - setup a new user and password

4. Update all the packages

.. code-block:: bash

    # TERMINAL - UBUNTU LINUX
    sudo apt update && sudo apt upgrade -y

Install packages

.. code-block:: bash

    # TERMINAL - UBUNTU LINUX
    sudo apt install vim python3.13-venv make -y

5. Disabled password request for my user when running sudo

.. code-block:: bash

    # TERMINAL - UBUNTU LINUX
    sudo su

Update the ``/etc/sudoers`` file using ``vim /etc/sudoers``:

.. code-block:: bash

    # TERMINAL - UBUNTU LINUX
    %sudo   ALL=(ALL:ALL) ALL

to

.. code-block:: bash

    # TERMINAL - UBUNTU LINUX
    %sudo   ALL=(ALL:ALL) NOPASSWD:ALL

Save, you need to use ``wq!`` don't forget the ``!``.

6. Update the ``~/.bashrc`` with aliases for root and your user

.. code-block:: bash

    # TERMINAL - UBUNTU LINUX
    alias ll='ls -ltrha --color=auto' # add arguments to a command that exists
    alias ls='ls -ltrha --color=auto' # add arguments to a command that exists
    alias vi='vim' # redirect the old application to the new one
    alias exot='exit' # correct typing errors
    alias clera='clear' # correct typing errors
    alias qpositive='history -c && history -w && exit' # link more commands under one

    alias bing='git push'
    alias bang='git status && git add --all && git commit -m'
    
    alias qqqRunEnv='. venv/bin/activate'
    alias eeeCreateVEnv='python3 -m venv venv'
    alias rrrInstallRequirements='pip install -r requirements.txt'

    alias duck='cd /home/${USER}/sandbox'
    export PATH="$PATH:/home/${USER}/sandbox"

after the update of the aliases you need to source them to have them available run ``source ~/.bashrc``
 
7. Create your sandbox

.. code-block:: bash

    # TERMINAL - UBUNTU LINUX
    mkdir -p /home/${USER}/sandbox
    duck

8. Create an ssh-key for the machine

.. code-block:: bash

    # TERMINAL - UBUNTU LINUX
    ssh-keygen -t ed25519 -C "${USER}@$(hostname)"

read the newly created key

.. code-block:: bash

    # TERMINAL - UBUNTU LINUX
    cat ~/.ssh/id_ed25519.pub

and add it in the `GitHub <https://github.com/settings/keys>`_ 

9. Configure git

.. code-block:: bash

    # TERMINAL - UBUNTU LINUX
    git config --global user.email "<MAIL>"
    git config --global user.name "<USER>"
    git config --global core.editor vim

10. Clone all your projects

===============================
Extending software Installation
===============================

1. Install Terraform

Follow the instructions from `HashiCorp <https://learn.hashicorp.com/tutorials/terraform/install-cli>`_

.. code-block:: bash

    # Ensure that your system is up to date and you have installed the gnupg, software-properties-common, and curl packages installed. You will use these packages to verify HashiCorp's GPG signature and install HashiCorp's Debian package repository.
    sudo apt-get update && sudo apt-get install -y gnupg software-properties-common

    # Add the HashiCorp GPG key.
    wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

    # Add the official HashiCorp Linux repository.
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list

    # Update to add the repository and install Terraform.
    sudo apt update && sudo apt-get install terraform

2. Install Kubectl

.. code-block:: bash

    # Update the apt package index and install packages needed to use the Kubernetes apt repository:
    sudo apt-get update && sudo apt-get install -y ca-certificates curl apt-transport-https

    # Download the Google Cloud public signing key
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg

    # Add the Kubernetes apt repository
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

    # Update apt package index with the new repository and install kubectl
    sudo apt-get update && sudo apt-get install -y kubectl

3. Install Helm

.. code-block:: bash

    # Install prerequisite packages
    sudo apt-get install apt-transport-https --yes

    # Download the Helm signing key
    curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null

    # Add the Helm apt repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

    # Update apt package index with the new repository and install helm
    sudo apt-get update && sudo apt-get install helm

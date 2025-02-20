####
TODO
####

=========
Questions
=========

1. What is a cloud computing service?

    a. Infrastructure as a Service (IaaS)
    b. Software as a Service (SaaS)
    c. Code as a Service
    d. Platform as a Service (PaaS)
    e. Serverless
    f. All of them

2. What is not a model of deployment in the cloud?

    a. Private Cloud
    b. Public Cloud
    c. Deep Web/Dark Cloud
    d. Community Cloud
    e. Hybrid Cloud
    f. All of them are models of deployment in the cloud

3. What is an advantage of cloud computing?

    a. accessibility
    b. cost-effective
    c. security
    d. performance
    e. flexibility
    f. scalability
    g. usability
    h. All of them

4. What is the advantage of containers with virtual machines?

    a. Containers are more secure than virtual machines.
    b. Containers are more portable than virtual machines.
    c. Containers are more lightweight than virtual machines.
    d. Containers are more scalable than virtual machines.
    e. All of them

5. What is not a container runtime?
    
    a. Docker
    b. Podman
    c. LXC
    d. rkt
    e. LXD
    
6. When to use bare metal?

    a. When you need to run a single application.
    b. When you need to run a single application and you need to run it on a specific operating system.
    c. When you need to run a single application and you need to run it on a specific operating system and you need to run it on a specific hardware.
    d. When you need to run a single application and you need to run it on a specific operating system and you need to run it on a specific hardware and you need to run it on a specific location.

7. How to list all the hidden files from the current directory?

    a. ls -l
    b. ls -a
    c. ls -la
    d. ls -al
    e. ls -h
    f. ls -lh

8. How to ``change directory`` to home?

    a. cd
    b. cd ~
    c. cd /home
    d. cd /home/$USER
    e. cd $HOME
    f. cd / $HOME
    g. cd ~/
    h. cd ~$USER

9. When you don't know how to run a command?

    a. check --help
    b. read the manual
    c. google it
    d. ask a colleague
    e. all of them
    f. cry

====================
Open ended Questions
====================

1. What is the difference between a programming language and a scripting language?

2. What is the difference between a compiled language and an interpreted language?

====
TODO
====

Open your container using ``docker run -it fedora bash`` then:

    1. store tree output for the 2nd level of root ``tree -d -L 2 /`` output in a hidden file on your sandbox directory in home explicitly ``.output``
    2. append to the ``.output`` the output from ``/var/log/dnf.log``
    3. count total words and how many times DEBUG is present from the ``.output``
    4. clear the content of the ``.output`` file
    5. execute command ``rm -rf /*``

=======
Answers
=======

1. 
**Answer:** All of them are services

**Explanation:**

    a. **Infrastructure as a Service (IaaS)** IaaS is a pay-as-you-go cloud computing service that offers on-demand storage and networking resources.
    b. **Software as a Service (SaaS)** allows clients and customers to connect with cloud-based apps that provide email, teleconferencing, productivity, and storage services.
    c. **Code as a Service** offers you complete, no-to-low code integration with your software.
    d. **Platform as a Service (PaaS)** PaaS offers complete cloud-based development and deployment where a client can create simple or the most sophisticated cloud-based applications.
    e. **Serverless** Serverless cloud computing is an architecture where the service provider manages the execution of the code instead of deploying them on servers.”*

2. 
**Answer:** **Deep Web/Dark Cloud**

**Explanation:**
    The Deep Web is part of the Internet that is not indexed by search engines. It is also known as the Invisible Web, Hidden Web, or Dark Web. The Deep Web is not the same as the Dark Web, which is a subset of the Deep Web that is used for illegal purposes.

3. 
**Answer:** All of them

**Explanation:**

    a. **accessibility** - Access your data from anywhere with an internet connection.
    b. **cost-effective** - Eliminates the need to purchase hardware and software and it reduces the need for on-site data centers and IT personnel.
    c. **security** - Storing data on remote servers can raise security and privacy concerns, as you're entrusting a third-party provider with sensitive information. However, many cloud providers offer security features to protect your data, but there are law restrictions in some countries.
    d. **performance** - Allows consume performant hardware 
    e. **flexibility** - Allows you to use different self managed services without the need to buy it.
    f. **usability** - The interface is easy to use and understand. But sometimes there are problems, the backend API is updated but the interface is not.
    g. **scalability** - Allows you to scale your hardware to fit your needs, even add new hardware on the fly.

4. 
**Answer:** All of them

**Explanation:**

    a. **Containers are more secure than virtual machines.** - Are isolated from the host system and other containers, if you get root access to a ephemere container it doesn't give you root access on the VM
    b. **Containers are more portable than virtual machines.** - Have all the dependencies in the container
    c. **Containers are more lightweight than virtual machines.** - The container OS has a smaller footprint and less features.
    d. **Containers are more scalable than virtual machines.** - Due to orchestration tools like Kubernetes, Docker Swarm you can easily scale your containers.

5. 
**Answer:** c. **LXC** 

**Explanation:**
    
    a. **Docker** - Docker is a set of platform as a service products that use OS-level virtualization to deliver software in packages called containers.
    b. **Podman** - Podman is a daemonless container engine for developing, managing, and running OCI Containers on your Linux System. Containers can either be run as root or in rootless mode. Simply put: alias docker=podman.
    c. **LXC** - LXC is a user space interface for the Linux kernel containment features. Through a powerful API and simple tools, it lets Linux users easily create and manage system or application containers.
    d. **rkt** - rkt is a pod-native container engine for Linux. It is composable, secure, and built on standards.
    e. **LXD** - LXD is a next generation system container manager. It offers a user experience similar to virtual machines but using Linux containers instead. It's image based with pre-made images available for a wide number of Linux distributions and is built around a very powerful, yet pretty simple, REST API.

6. 
**Answer:** c. **When you need to run a single application and you need to run it on a specific operating system and you need to run it on a specific hardware and you need to run it on a specific location.** 

**Explanation:**

    Bare metal is a term used to describe a computer that is not running an operating system. Bare metal is the opposite of virtualization, which is the process of running a computer operating system on top of another operating system.

7. 
**Answer:** 

.. code-block:: bash

    ls -a
    ls -la
    ls -al

**Explanation:**

    We can see the hidden file using ``-a`` flag

8. 
**Answer:**

.. code-block:: bash
    
    ``cd``
    ``cd ~``
    ``cd /home/$USER``
    ``cd $HOME``
    ``cd ~/``

**Explanation:**

    We can go to our home directory using ``cd`` or ``cd ~`` or ``cd /home/$USER`` or ``cd $HOME`` or ``cd ~/``

9.
**Answer:**

.. code-block:: bash

    command --help
    man command

**Explanation:**
    
        We can check the help of a command using ``--help`` or ``man``

==================
Open ended Answers
==================

1. A programming language is a formal language comprising a set of strings that produce various kinds of machine code output. Programming languages are used in computer programming to implement algorithms. Most programming languages consist of instructions for computers, although there are programmable machines that use a limited set of specific instructions, rather than the general programming languages of modern computers. Programming languages can be used to create programs that implement specific algorithms.

A scripting language, script language or extension language is a programming language that allows control of one or more software applications. "Scripts" are distinct from the core code of the application, as they are usually written in a different language and are often created or at least modified by the end-user. Scripts are often interpreted from source code or bytecode, whereas the applications they control are traditionally compiled to native machine code. Scripting languages are nearly always embedded in the applications they control.

2. A compiled language is a programming language whose implementations are typically compilers (translators that generate machine code from source code), and not interpreters (step-by-step executors of source code, where no pre-runtime translation takes place). The term is somewhat vague. In principle, any language can be implemented with a compiler or with an interpreter.

An interpreted language is a type of programming language for which most of its implementations execute instructions directly and freely, without previously compiling a program into machine-language instructions. The interpreter executes the program directly, translating each statement into a sequence of one or more subroutines, and then into another language (often machine code). Interpreted languages can also be contrasted with machine languages. Functionally, both execution and interpretation mean the same thing — they both take instructions written in a programming language and execute them — but she difference is that a compiler outputs a standalone file that does not need to be interpreted by anything else, whereas an interpreter reads the source code instructions every time the program is run.

=============
Solution TODO
=============

0. Install ``tree`` utility using ``dnf`` package manager in Fedora:

.. code-block:: bash
    
    dnf update && dnf install tree

1. Store the output of ``tree -d -L 2 /`` in a hidden file ``.output``, we are using ``>`` to redirect the output to the file:

.. code-block:: bash

    tree -d -L 2 / > ~/.output

2. Append the output of ``/var/log/dnf.log`` to the ``.output`` file, we are using ``>>`` to append the output to the file:

.. code-block:: bash

    cat /var/log/dnf.log >> ~/.output

3. Count total words and how many times DEBUG is present from the ``.output`` file

.. code-block:: bash
    
    grep DEBUG ~/.output | wc -l

4. Clear the content of the ``.output`` file

.. code-block:: bash

    echo '' ~/.output

5. 

.. warning:: 
    
    This command ``rm -rf /*`` will delete all files and directories in the root directory, DON'T execute it in your system!
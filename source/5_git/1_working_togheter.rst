###########################
5.1 Working together on Git
###########################

====================
Markdown cheat sheet
====================

++++++++++++++++
Creating headers
++++++++++++++++

.. code-block:: bash

    # Header 1
    ## Header 2
    ### Header 3
    #### Header 4
    ##### Header 5

    or you can use:

    Header 1
    ========

    Header 2
    --------

.. code-block:: bash

    *This text will be italic*
    _This will also be italic_

    **This text will be bold**
    __This will also be bold__

    _You **can** combine them_

+++++
Lists
+++++

Unordered lists:

.. code-block:: bash

    * Item 1
    * Item 2
      * Item 2a
      * Item 2b


Ordered lists:

.. code-block:: bash

    1. Item 1
    1. Item 2
    1. Item 3
       1. Item 3a
       1. Item 3b

+++++
Links
+++++

.. code-block:: bash

    http://github.com - automatic!
    [GitHub](http://github.com)

++++++
Images
++++++

.. code-block:: bash

    ![GitHub Logo](/images/logo.png)
    Format: ![Alt Text](url)

++++++++++++++++++++++++++++
Code and Syntax Highlighting
++++++++++++++++++++++++++++

.. code-block:: bash

    ```javascript
    function fancyAlert(arg) {
      if(arg) {
        $.facebox({div:'#foo'})
      }
    }
    ```

    ```python
    def foo():
        if not bar:
            return True
    ```

    ```bash
    #! /usr/bin/env bash
    echo "Hello World"
    ```

    ```yaml
    ---
    - hosts: all
      tasks:
        - name: Install Apache
          yum:
            name: httpd
            state: latest
    ```

++++++
Tables
++++++

.. code-block:: bash

    First Header  | Second Header
    ------------- | -------------
    Content Cell  | Content Cell
    Content Cell  | Content Cell

===================================================
2. Add your presentation into Skillab - git project
===================================================

I have added an example, but be creative:

.. code-block:: bash

    **Claudiu**
    *DevOps Engineer*
    Likes:

      * [x] coding
      * [x] teaching
      * [x] video games
      * [x] mma

I would like to have in the presentation:

    #. name
    #. profession
    #. hobbies
    #. why are you here?
    #. do you like DevOps?
    #. what would you like more?
    #. what would you like less

++++++
How to
++++++

.. code-block:: bash

    vim presentations.md # keep this name so we can have some merge conflicts

    git add presentations.md
    # or
    # pay attention it adds everything

    git add --all

    # now press the letter "i" to insert
    # when you are done writing press the ESCAPE key

    # write :wq and press ENTER

    git commit -m "Message" # Keep message informative

    git push

+++++++++++++++++++++++
Solving merge conflicts
+++++++++++++++++++++++

To resolve a Git merge conflict, follow these steps:

    #. Identify the conflicting file(s): Git will mark the conflicts in the affected files with conflict markers.
    #. Open the conflicting file(s) and locate the conflict markers.
    #. Choose which version to keep or manually edit the file to include the changes you want.
    #. Remove the conflict markers (e.g. "<<<<<<<").
    #. Commit the resolved file(s).
    #. Repeat the process for any other conflicting files.

It's important to carefully review the changes and make sure the resulting file is what you intended before committing. You may also want to consider using a merge tool to assist with resolving conflicts.

####
TODO
####

======
Task 1
======

Create documentation for a new language:
    #. Create a new project ``learn_language_name`` example ``learn_go`` in your user space
    #. Add a new file README.md
    #. Update file with information:

        #. how to install language on WSL
        #. how to run ``hello world``
        #. how to declare data structures
        #. how to user conditions and loops
        #. what are the advantages compared with another language

=========
Questions
=========

1. What is the difference between git and GitHub?

   a. Git is a version control system, GitHub is a hosting service for Git repositories.
   b. Git is a hosting service for Git repositories, GitHub is a version control system.
   c. Git is a version control system, GitHub is a version control system.
   d. Git is a hosting service for Git repositories, GitHub is a hosting service for Git repositories.

2. What is the difference between ``git pull`` and ``git fetch``?

    a. git pull fetches the latest commits and merges them into your current branch, while git fetch fetches the latest commits but does not merge them into your current branch.
    b. git pull fetches the latest commits but does not merge them into your current branch, while git fetch fetches the latest commits and merges them into your current branch.
    c. git pull fetches the latest commits and merges them into your current branch, while git fetch fetches the latest commits but does not merge them into your current branch.
    d. git pull fetches the latest commits but does not merge them into your current branch, while git fetch fetches the latest commits and merges them into your current branch.

3. What command is used to download a repository from GitHub to your local machine?

    a. git commit
    b. git push
    c. git fork
    d. git clone

4. Which of the following commands will show you the history of commits in your repository?

    a. git log
    b. git commit
    c. git status
    d. git branch

5. How do you create a new branch and switch to it immediately?

    a. git branch new-branch
    b. git checkout new-branch
    c. git checkout -b new-branch
    d. git merge new-branch

6. What does the git status command do?

    a. Displays the commit history
    b. Lists all branches
    c. Shows the status of changes as untracked, modified, or staged
    d. Shows the current branch name

7. What is the purpose of .gitignore file?

    a. To ignore files during the commit process
    b. To list collaborators on the project
    c. To specify the remote repository URL
    d. To ignore files when pulling updates from remote

=======
Answers
=======

1. Answer: a

    Explanation: Git is a version control system, GitHub is a hosting service for Git repositories. Git is a command-line tool, while GitHub is a web-based interface. Git is maintained by a community of developers, while GitHub is a company.

2. Answer: c

    Explanation: ``git pull`` fetches the latest commits and merges them into your current branch, while ``git fetch`` fetches the latest commits but does not merge them into your current branch. ``git pull`` is a combination of ``git fetch`` and ``git merge``.

3. Answer: d

    Explanation: ``git clone`` is used to download a repository from GitHub to your local machine. ``git commit`` is used to save your changes to the local repository, ``git push`` is used to upload your changes to the remote repository, and ``git fork`` is used to create a copy of a repository on GitHub.

4. Answer: a. git log

    Explanation: git log is used to display the commit history of the current branch, showing a list of commits along with their details.

5. Answer: c. git checkout -b new-branch

    Explanation: ``git checkout -b new-branch`` creates a new branch and switches to it immediately. ``git branch new-branch`` creates a new branch but does not switch to it. ``git checkout new-branch`` switches to an existing branch. ``git merge new-branch`` merges a branch into the current branch.

6. Answer: c. Shows the status of changes as untracked, modified, or staged

    Explanation: git status provides information regarding the current branch, staged changes, and files that are not tracked by Git. 

7. Answer: a. To ignore files during the commit process

    Explanation: The .gitignore file is used to specify files that should be ignored during the commit process. This is useful for files that are generated automatically, such as log files, or files that contain sensitive information, such as passwords.
    

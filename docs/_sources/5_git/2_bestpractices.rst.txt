##################
5.1 Best practices
##################

#. Learn how to use ``git`` by playing https://ohmygit.org/
#. Keep your commits small and focused on a single change, try not to update more than one service or component.
#. Write clear, concise commit messages, a good example is to use the: Backlog #Task_Number Commit message "AzureBoards #12345 Initial Commit"
#. Regularly pull and merge from the main branch to avoid conflicts and keep your branch up-to-date.
#. Test your code before committing.
#. Use pull requests for code review and collaboration.
#. Avoid large binary files in your Git repository ( we use other tools for packages and artifacts)
#. Use .gitignore files to exclude files that should not be tracked by Git.
#. Use a branching strategy, such as Git Flow, to manage the development process.
    Is a git branching and release management workflow that helps developers keep track of features, hotfixes, and releases in bigger software projects.
        - Branch name for production releases: [master] - now ``main`` due to me2 movements
        - Branch name for "next release" development: [develop]
        - How to name your supporting branch prefixes
        - Feature branches [feature/]
        - Release branches [release/]
        - Hotfix branches [hotfix/]

    .. image:: ../diagrams/sem_ver.png
        :width: 1000 px
        :alt: Semantic Versioning

#. Back up your repository regularly.
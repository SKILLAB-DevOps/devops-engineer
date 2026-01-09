########################
6.3 Deploy Documentation
########################

1. Create a new project named ``docs-as-code`` into your user space (the link will be ``https://github.com/YOUR_USERNAME/docs-as-code``)

2. Clone to project locally using ``git clone git@github.com:YOUR_USERNAME/docs-as-code.git``

3. Change the directory to the newly cloned project ``cd docs-as-code``

4. Run ``sphinx-quickstart``

5. Update documentation

6. Build documentation ``make html``

7. Create a new directory and copy the documentation into it

.. code-block:: bash

   # Create a documentation directory
   mkdir docs

   # Copy the build content to the docs directory
   cp -r build/html/* docs/

8. Push local changes to GitHub using ``git push``

9. Enable gh-page from Project Settings - Pages - Deploy from a branch (select master) - /docs and press Save

10. An automated pipeline will start to build and deploy your documentation.

11. Go to the repository page, bottom right you will find Environments: github-pages - View deployment
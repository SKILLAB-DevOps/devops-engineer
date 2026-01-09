####################
First CI/CD Pipeline
####################

Build and deploy your first automated pipeline in under 10 minutes.

====================
GitHub Actions Setup
====================

**Step 1: Create Repository**

.. code-block:: bash

   # Create and clone repository
   git clone https://github.com/yourusername/my-first-pipeline.git
   cd my-first-pipeline

**Step 2: Add Test Script**

.. literalinclude:: ../../source_code/pipelines/basic/hello_world.py
   :language: python
   :caption: hello_world.py - Test script with proper error handling

**Step 3: Create Workflow**

.. code-block:: bash

   # Create workflow directory
   mkdir -p .github/workflows

.. literalinclude:: ../../source_code/pipelines/basic/ci.yml
   :language: yaml
   :caption: .github/workflows/ci.yml - Basic CI pipeline

**Step 4: Deploy**

.. code-block:: bash

   git add .
   git commit -m "Add CI pipeline"  
   git push origin main

**Result:** Automated testing on every push with modern Python tools (uv, ruff, mypy).

=============================
Troubleshooting Common Issues
=============================

**Pipeline Doesn't Run**

- Check ``.github/workflows/`` directory structure
- Verify `.yml` file extension
- Ensure correct branch in trigger configuration

**YAML Syntax Errors**

- Use consistent 2-space indentation (no tabs)
- Validate YAML at yamllint.com before committing
- Common issue: mixing spaces and tabs

**Action Version Errors**

- Use stable versions: `actions/checkout@v4`
- Check GitHub marketplace for current versions
- Pin to specific versions for reliability

**Debug Environment Issues:**

.. code-block:: yaml

   - name: Debug environment
     run: |
       pwd && ls -la
       python --version
       which python uv git

==========================
Advanced Workflow Patterns
==========================

**Matrix Testing (Multiple Versions):**

.. code-block:: yaml

   strategy:
     matrix:
       python-version: ["3.11", "3.12", "3.13"]
       os: [ubuntu-latest, windows-latest, macos-latest]
   
   steps:
     - uses: actions/setup-python@v5
       with:
         python-version: ${{ matrix.python-version }}

**Conditional Execution:**

.. code-block:: yaml

   - name: Deploy to production
     if: github.ref == 'refs/heads/main'
     run: echo "Deploying..."

**Artifact Sharing:**

.. code-block:: yaml

   - uses: actions/upload-artifact@v4
     with:
       name: test-results
       path: results/

===========================
Production Pipeline Example
===========================

**Complete CI/CD with Security and Deployment:**

.. literalinclude:: ../../source_code/pipelines/advanced/production_ci_cd.yml
   :language: yaml
   :lines: 1-80
   :caption: Production-ready pipeline with multi-stage deployment

**Key Features:**

- Multi-stage quality gates (lint → test → security → deploy)
- Cross-platform testing (Ubuntu, Windows, macOS)
- Security scanning (bandit, safety)
- Environment-specific deployments
- Automated artifact management

=====================
Modern Python Tooling
=====================

**Essential Development Stack:**

.. code-block:: bash

   # Install modern Python tools
   curl -LsSf https://astral.sh/uv/install.sh | sh
   
   # Create project with modern tooling
   uv init my-project
   cd my-project
   uv add --dev pytest ruff mypy bandit

**Project Configuration:**

.. literalinclude:: ../../source_code/pipelines/templates/pyproject.toml
   :language: toml
   :lines: 1-40
   :caption: Modern Python project configuration

Complete examples available in ``source_code/pipelines/``

==========
Next Steps
==========

**Explore Complete Examples:**

- ``source_code/pipelines/basic/`` - Simple getting started examples
- ``source_code/pipelines/advanced/`` - Production-ready patterns
- ``source_code/pipelines/templates/`` - Reusable configurations  
- ``source_code/pipelines/examples/`` - Complete applications

**Advanced Topics:**

- CLI applications with Typer framework
- Advanced GitHub Actions patterns
- Production deployment strategies
- Security and compliance integration

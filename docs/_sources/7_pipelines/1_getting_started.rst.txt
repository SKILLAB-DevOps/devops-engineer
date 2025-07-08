###################
7.1 Getting Started
###################

.. image:: ../diagrams/github_actions.png
  :alt: A diagram showing schematically how a Github Actions workflow is triggered and executed.
  :width: 600 px

**From Theory to Practice**

In the previous section, we explored the concepts behind CI/CD pipelines. Now it's time to build one yourself. By the end of this section, you'll have a working pipeline that automatically tests your code every time you push changes - and you'll understand exactly how it works.

This hands-on approach mirrors how the best development teams learn: start with something simple that works, then gradually add sophistication as you gain confidence and understanding.

===================
Learning Objectives
===================

By the end of this section, you will:

• **Create** your first GitHub Actions workflow from scratch in under 10 minutes
• **Master** YAML syntax and workflow structure through practical examples
• **Configure** different trigger events to match your development workflow
• **Troubleshoot** common setup issues with confidence
• **Build** and test a Python project automatically on every code change

**Prerequisites:** GitHub account, basic Git knowledge, text editor

**Why GitHub Actions?** We're starting with GitHub Actions because it's free for public repositories, integrates seamlessly with your code, and represents the modern standard for CI/CD. The concepts you learn here transfer directly to other platforms like GitLab CI/CD, Azure DevOps, or Jenkins.

=================================
Your First Pipeline in 10 Minutes
=================================

**The "Hello World" of CI/CD**

Every developer remembers their first "Hello World" program - it's simple, it works, and it proves the system is functional. This is your "Hello World" for CI/CD pipelines.

**What we're building:** A pipeline that automatically runs a Python script every time you push code to GitHub. Simple, but it demonstrates all the core concepts you'll use in production systems.

**Step 1: Repository Setup (2 minutes)**

First, let's create a minimal project structure:

1. **Create repository:** Go to GitHub.com → New repository → `my-first-pipeline` → Create
2. **Clone locally:** 
   
   .. code-block:: bash
   
       git clone https://github.com/yourusername/my-first-pipeline.git
       cd my-first-pipeline

3. **Create a simple Python script:**

   .. code-block:: python
   
       # hello.py
       def greet(name):
           """A simple greeting function."""
           return f"Hello, {name}!"
       
       def main():
           """Main function to demonstrate our pipeline."""
           message = greet("CI/CD World")
           print(message)
           print("🎉 Pipeline is working!")
           return True
       
       if __name__ == "__main__":
           success = main()
           exit(0 if success else 1)

**Why this structure matters:** Notice we have a function (`greet`) that can be tested, a main function that can be called, and proper exit codes. This mirrors real-world applications and makes our pipeline more meaningful than just printing text.

**Step 2: Create the Workflow (3 minutes)**

Now for the magic - creating the automated workflow:

1. **Create the workflow directory:**
   
   .. code-block:: bash
   
       mkdir -p .github/workflows

2. **Create the workflow file:** `.github/workflows/ci.yml`

   .. code-block:: yaml
   
       name: My First CI Pipeline
       
       # When should this pipeline run?
       on:
         push:
           branches: [ main ]
         pull_request:
           branches: [ main ]
       
       # What should the pipeline do?
       jobs:
         test:
           runs-on: ubuntu-latest
           
           steps:
             # Step 1: Get our code
             - name: Checkout repository
               uses: actions/checkout@v4
             
             # Step 2: Set up Python environment
             - name: Set up Python 3.12
               uses: actions/setup-python@v5
               with:
                 python-version: '3.12'
             
             # Step 3: Run our script
             - name: Run hello.py
               run: python hello.py
             
             # Step 4: Verify it worked
             - name: Celebrate success
               run: echo "Your first pipeline is working!"

**Understanding the YAML:** Every line serves a purpose:
- `name`: What you'll see in GitHub's interface
- `on`: Triggers (when the pipeline runs)  
- `jobs`: What work gets done
- `steps`: Individual tasks within a job
- `uses`: Pre-built actions from the marketplace
- `run`: Shell commands to execute

**Step 3: Push and Watch (2 minutes)**

Time to see your pipeline in action:

.. code-block:: bash

    git add .
    git commit -m "Add first CI pipeline"
    git push origin main

**Step 4: View Your Success (1 minute)**

1. **Go to your GitHub repository**
2. **Click the "Actions" tab** (should be visible in the top navigation)
3. **Watch your workflow run** - you should see a green checkmark within 2-3 minutes
4. **Click on the workflow run** to see detailed logs

**Step 5: Understanding What Happened (2 minutes)**

Behind the scenes, GitHub:
1. **Detected** your workflow file when you pushed
2. **Spun up** a fresh Ubuntu virtual machine
3. **Downloaded** your repository code
4. **Installed** Python 3.12
5. **Executed** your script
6. **Reported** the results back to you

This same pattern scales to the most complex production systems - the only difference is what happens in the steps.

.. tip::

    **Congratulations!** You've just created your first CI/CD pipeline. This is the foundation that Fortune 500 companies use to deploy software safely to millions of users. The concepts are identical; only the complexity scales.

=====================================
Troubleshooting: When Things Go Wrong
=====================================

**Learning from Failure: The Developer's Superpower**

Every experienced developer will tell you: learning to debug failing systems is more valuable than having everything work perfectly the first time. CI/CD pipelines fail for predictable reasons, and knowing how to diagnose and fix these issues quickly sets apart junior from senior engineers.

Here are the most common issues you'll encounter and exactly how to solve them:

**Problem 1: Workflow Doesn't Appear**

*Symptoms:* You push your code but see no workflow in the Actions tab

*Debugging steps:*

1. **Check file location:** Must be exactly `.github/workflows/filename.yml` (note the leading dot)
2. **Verify file extension:** Must be `.yml` or `.yaml` (case-sensitive)
3. **Confirm branch trigger:** Are you pushing to the branch specified in your trigger?

*Solution:*

.. code-block:: bash

    # Debug your file structure
    find . -name "*.yml" -o -name "*.yaml"
    # Should show: ./.github/workflows/ci.yml
    
    # Check branch name
    git branch
    # Ensure you're on 'main' if that's your trigger

*Root cause:* GitHub only recognizes workflows in the exact directory structure and with proper extensions.

**Problem 2: YAML Syntax Errors**

*Symptoms:* Workflow appears but immediately fails with "Invalid workflow file"

*Why YAML is tricky:* YAML is indentation-sensitive (like Python) but uses spaces, not tabs. One wrong space breaks everything.

*Common mistakes and fixes:*

.. code-block:: yaml

    # WRONG - inconsistent indentation
    jobs:
    test:
        runs-on: ubuntu-latest
    
    # CORRECT - consistent 2-space indentation  
    jobs:
      test:
        runs-on: ubuntu-latest
    
    # WRONG - tabs instead of spaces (invisible but deadly)
    jobs:
    	test:  # This line uses a tab
    
    # CORRECT - only spaces
    jobs:
      test:
        runs-on: ubuntu-latest

*Pro debugging tip:* Copy your YAML into an online validator (like yamllint.com) to catch syntax errors before committing.

**Problem 3: Action Version Errors**

*Symptoms:* Error like "Can't find action actions/checkout@v5" or "action not found"

*Root cause:* Action versions change over time. Using non-existent versions breaks workflows.

*Solution:* Use stable, tested versions:

.. code-block:: yaml

    # Recommended - use tested versions
    - uses: actions/checkout@v4          # Not v5
    - uses: actions/setup-python@v5      # Current stable

*How to find correct versions:* Visit the action's GitHub repository (e.g., github.com/actions/checkout) and check the latest release tags.

**Problem 4: Python Script Failures**

*Symptoms:* Pipeline runs but your Python code has errors

*Common issues and solutions:*

.. code-block:: python

    # Common mistake - file not found
    with open('config.txt', 'r') as f:  # File doesn't exist
        content = f.read()
    
    # Better - handle missing files
    import os
    if os.path.exists('config.txt'):
        with open('config.txt', 'r') as f:
            content = f.read()
    else:
        content = "default config"

*Debugging workflow:* Add debugging steps to understand the environment:

.. code-block:: yaml

    - name: Debug environment
      run: |
        echo "Current directory: $(pwd)"
        echo "Directory contents:"
        ls -la
        echo "Python version: $(python --version)"
        echo "Available commands:"
        which python pip git

**Problem 5: Permission and Resource Issues**

*Symptoms:* "Permission denied" or "No space left on device" errors

*Solutions:*

.. code-block:: yaml

    # Fix permission issues
    - name: Make script executable
      run: chmod +x ./scripts/deploy.sh
    
    # Clean up disk space
    - name: Free up runner space
      run: |
        sudo apt-get clean
        sudo rm -rf /usr/share/dotnet
        df -h  # Show remaining space

**Systematic Debugging Approach:**

When any pipeline fails, use this checklist:

1. **Read the error message completely** - don't just glance at it
2. **Check the exact line number** where failure occurred
3. **Verify the working directory** - are you where you think you are?
4. **Test locally first** - does your script work on your machine?
5. **Compare with working examples** - find a similar successful workflow

.. warning::

    **Beginner's Mistake:** Don't change multiple things at once when debugging. Make one small change, commit, and see if it fixes the issue. This approach helps you understand exactly what caused the problem.

    **Most Common Beginner Mistake:** Mixing tabs and spaces in YAML. Set your editor to show whitespace and use only spaces!

================================
Understanding Workflow Structure
================================

Now that you have a working pipeline, let's understand what each part does:

**Workflow Anatomy:**

.. code-block:: yaml

    name: Quick Start CI                    # 1. Workflow name (appears in Actions tab)
    on:                                     # 2. Trigger events
      push:
        branches: [ main ]
      pull_request:
        branches: [ main ]
    
    jobs:                                   # 3. Jobs run in parallel
      test:                                 # 4. Job name
        runs-on: ubuntu-latest              # 5. Virtual machine type
        steps:                              # 6. Sequential steps
          - name: Get the code              # 7. Step name (optional)
            uses: actions/checkout@v4       # 8. Pre-built action
          
          - name: Set up Python            # 9. Another step
            uses: actions/setup-python@v5   # 10. Action with parameters
            with:
              python-version: '3.12'
          
          - name: Run our script           # 11. Custom command
            run: python hello.py

**Key Concepts:**

• **Workflow**: The entire automation process (this YAML file)
• **Job**: A group of steps that run on the same runner
• **Step**: Individual task (run a command, use an action)
• **Action**: Reusable code (like installing Python)
• **Runner**: Virtual machine that executes your workflow

===============================
Understanding Workflow Triggers
===============================

The ``on`` keyword defines when your workflow runs. Choose triggers based on your team's workflow:

**Basic Triggers:**

.. code-block:: yaml

    # Trigger on any push
    on: push
    
    # Trigger on specific branches only
    on:
      push:
        branches: [ main, develop ]
        paths: [ 'src/**', 'tests/**' ]  # Only when these files change
    
    # Trigger on pull requests
    on:
      pull_request:
        branches: [ main ]

**Advanced Triggers:**

.. code-block:: yaml

    # Multiple triggers
    on:
      push:
        branches: [ main ]
      pull_request:
        branches: [ main ]
      schedule:
        - cron: '0 2 * * *'        # Daily at 2 AM
      workflow_dispatch:           # Manual trigger button
        inputs:
          environment:
            description: 'Environment to deploy to'
            required: true
            default: 'staging'
            type: choice
            options:
              - staging
              - production

**Real-World Trigger Strategies:**

• **Feature branches**: Run tests on every push to any branch
• **Main branch**: Run tests + deploy to staging
• **Release tags**: Deploy to production
• **Scheduled**: Run security scans nightly
• **Manual**: Emergency deployments or one-off tasks

.. tip::

    **Best Practice**: Start with simple triggers (`push`, `pull_request`) and add complexity as your team grows comfortable with CI/CD.

=========================================
Example: Complete Python Project Pipeline
=========================================

Let's build a production-ready workflow for a Python web application:

.. code-block:: yaml

    name: Production-Ready Python CI
    on:
      push:
        branches: [ main, develop ]
      pull_request:
        branches: [ main ]
    
    jobs:
      test:
        runs-on: ubuntu-latest
        strategy:
          matrix:
            python-version: ["3.11", "3.12", "3.13"]
        
        steps:
          - name: Checkout code
            uses: actions/checkout@v4
          
          - name: Install uv
            uses: astral-sh/setup-uv@v3
          
          - name: Set up Python ${{ matrix.python-version }}
            run: uv python install ${{ matrix.python-version }}
          
          - name: Install dependencies
            run: uv sync --dev
          
          - name: Code quality checks
            run: |
              uv run ruff check .           # Fast linting
              uv run ruff format --check .  # Format checking
              uv run mypy src/             # Type checking
          
          - name: Security scan
            run: uv run bandit -r src/
          
          - name: Run tests with coverage
            run: |
              uv run pytest --cov=src --cov-report=xml --cov-report=term-missing
          
          - name: Upload coverage reports
            uses: codecov/codecov-action@v4
            with:
              file: ./coverage.xml
              fail_ci_if_error: true

**Why This Pipeline Works Well:**

• **Matrix strategy**: Tests across Python 3.10, 3.11, and 3.12
• **Modern tools**: uv for speed, ruff for linting, mypy for types
• **Security**: bandit scans for common vulnerabilities
• **Coverage**: Tracks test coverage and uploads to Codecov
• **Fast feedback**: Parallel jobs complete in ~3 minutes

========================
Common Workflow Patterns
========================

**Pattern 1: Fail Fast**

Put quick checks first to give developers fast feedback:

.. code-block:: yaml

    jobs:
      quick-checks:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          - name: Install uv
            uses: astral-sh/setup-uv@v3
          - run: uv run ruff check .        # Fast linting first
          - run: uv run ruff format --check . # Format check second
      
      thorough-tests:
        needs: quick-checks                 # Only run if quick checks pass
        runs-on: ubuntu-latest
        steps:
          # ... full test suite

**Pattern 2: Conditional Jobs**

Run expensive jobs only when needed:

.. code-block:: yaml

    jobs:
      test:
        runs-on: ubuntu-latest
        # ... test steps
      
      deploy:
        needs: test
        if: github.ref == 'refs/heads/main'  # Only deploy from main branch
        runs-on: ubuntu-latest
        steps:
          # ... deployment steps

**Pattern 3: Artifact Sharing**

Share build artifacts between jobs:

.. code-block:: yaml

    jobs:
      build:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          - name: Build package
            run: uv build
          - name: Upload artifacts
            uses: actions/upload-artifact@v4
            with:
              name: dist
              path: dist/
      
      test:
        needs: build
        runs-on: ubuntu-latest
        steps:
          - name: Download artifacts
            uses: actions/download-artifact@v4
            with:
              name: dist
              path: dist/

===================
Progress Checkpoint
===================

**By now you should be able to:**

• Create GitHub Actions workflows from scratch
• Choose appropriate triggers for your use case
• Troubleshoot common YAML and workflow issues
• Build multi-job pipelines with dependencies
• Use modern Python tooling in CI/CD

**Next Steps:**

In the following sections, we'll dive deeper into:

- Building more complex Python applications with databases
- Advanced GitHub Actions features and optimizations
- Security scanning and best practices
- Multi-environment deployments

.. note::

    Practice Opportunity: Try modifying the Python pipeline above to include additional tools like pre-commit, bandit or safety (dependency vulnerability scanning) on python-version: [3.11, 3.12, 3.13]

.. code-block:: bash        
        
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Set up Python ${{ matrix.python-version }}
        uses: actions/setup-python@v4
        with:
          python-version: ${{ matrix.python-version }}
      
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install flake8 pytest
          if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
      
      - name: Lint with flake8
        run: |
          # Stop the build if there are Python syntax errors or undefined names
          flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
          # Exit-zero treats all errors as warnings
          flake8 . --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics
      
      - name: Test with pytest
        run: |
          pytest

.. note::

    **Matrix builds:** The ``strategy.matrix`` allows you to test against multiple Python versions simultaneously, ensuring your code works across different environments.

====================================
Example 3: Modern Python CI Pipeline
====================================

Here's a comprehensive CI pipeline using modern Python tools like ``uv``, ``ruff``, and ``bandit``:

.. code-block:: yaml

    name: Python CI with Modern Tools
    on:
      push:
        branches: [ main, develop ]
      pull_request:
        branches: [ main ]
    
    jobs:
      ci:
        runs-on: ubuntu-latest
        strategy:
          matrix:
            python-version: ["3.11", "3.12", "3.13"]
        
        steps:
          - name: Checkout code
            uses: actions/checkout@v4
          
          - name: Set up Python ${{ matrix.python-version }}
            uses: actions/setup-python@v4
            with:
              python-version: ${{ matrix.python-version }}
          
          - name: Install uv
            uses: astral-sh/setup-uv@v3
            with:
              enable-cache: true
              cache-dependency-glob: "uv.lock"
          
          - name: Install dependencies
            run: |
              uv sync --dev
          
          - name: Code formatting check with ruff
            run: |
              uv run ruff format --check .
          
          - name: Linting with ruff
            run: |
              uv run ruff check .
          
          - name: Type checking with mypy
            run: |
              uv run mypy src/
          
          - name: Security scan with bandit
            run: |
              uv run bandit -r src/ -f json -o bandit-report.json
              uv run bandit -r src/
          
          - name: Run tests with pytest
            run: |
              uv run pytest --cov=src --cov-report=xml --cov-report=term-missing
          
          - name: Upload coverage to Codecov
            uses: codecov/codecov-action@v3
            with:
              file: ./coverage.xml
              fail_ci_if_error: true
          
          - name: Upload security report
            uses: actions/upload-artifact@v4
            if: always()
            with:
              name: security-report-${{ matrix.python-version }}
              path: bandit-report.json

.. tip::

    **Modern Python Tools Explained:**
    
    - ``uv``: Ultra-fast Python package installer and resolver
    - ``ruff``: Lightning-fast Python linter and formatter (replaces flake8, black, isort)
    - ``bandit``: Security vulnerability scanner for Python
    - ``mypy``: Static type checker
    - ``pytest``: Testing framework with coverage reporting

=============================================
Example 4: Python CD Pipeline with Deployment
=============================================

This workflow shows continuous deployment for a Python application:

.. code-block:: yaml

    name: Python CD Pipeline
    on:
      push:
        branches: [ main ]
        tags: [ 'v*' ]
    
    jobs:
      # First run CI to ensure quality
      test:
        uses: ./.github/workflows/ci.yml  # Reference the CI workflow
      
      # Build and package the application
      build:
        needs: test
        runs-on: ubuntu-latest
        steps:
          - name: Checkout code
            uses: actions/checkout@v4
          
          - name: Set up Python
            uses: actions/setup-python@v4
            with:
              python-version: "3.11"
          
          - name: Install uv
            uses: astral-sh/setup-uv@v3
          
          - name: Build package
            run: |
              uv build
          
          - name: Upload build artifacts
            uses: actions/upload-artifact@v4
            with:
              name: python-package
              path: dist/
      
      # Deploy to staging environment
      deploy-staging:
        needs: build
        runs-on: ubuntu-latest
        environment: staging
        steps:
          - name: Download artifacts
            uses: actions/download-artifact@v4
            with:
              name: python-package
              path: dist/
          
          - name: Deploy to staging
            run: |
              echo "Deploying to staging environment..."
              # Example deployment commands:
              # pip install dist/*.whl
              # systemctl restart myapp
              # Or deploy to cloud platform
          
          - name: Run smoke tests
            run: |
              echo "Running smoke tests on staging..."
              # curl -f http://staging.myapp.com/health
              # python -m pytest tests/smoke/
      
      # Deploy to production (only on tags)
      deploy-production:
        needs: deploy-staging
        runs-on: ubuntu-latest
        environment: production
        if: startsWith(github.ref, 'refs/tags/v')
        steps:
          - name: Download artifacts
            uses: actions/download-artifact@v4
            with:
              name: python-package
              path: dist/
          
          - name: Deploy to production
            run: |
              echo "Deploying version ${{ github.ref_name }} to production..."
              # Production deployment commands
          
          - name: Create GitHub release
            uses: softprops/action-gh-release@v1
            with:
              files: dist/*
              generate_release_notes: true

============================================
Example 5: Complete Python Project Structure
============================================

For these workflows to work, your Python project should have this structure:

.. code-block:: text

    my-python-project/
    ├── .github/
    │   └── workflows/
    │       ├── ci.yml
    │       └── cd.yml
    ├── src/
    │   └── myapp/
    │       ├── __init__.py
    │       └── main.py
    ├── tests/
    │   ├── __init__.py
    │   ├── test_main.py
    │   └── smoke/
    │       └── test_health.py
    ├── pyproject.toml
    ├── uv.lock
    └── README.md

**Sample pyproject.toml:**

.. code-block:: toml

    [build-system]
    requires = ["hatchling"]
    build-backend = "hatchling.build"
    
    [project]
    name = "myapp"
    version = "0.1.0"
    description = "My awesome Python app"
    dependencies = [
        "fastapi>=0.100.0",
        "uvicorn>=0.20.0",
    ]
    
    [project.optional-dependencies]
    dev = [
        "pytest>=7.0.0",
        "pytest-cov>=4.0.0",
        "ruff>=0.1.0",
        "mypy>=1.5.0",
        "bandit>=1.7.0",
    ]
    
    [tool.ruff]
    target-version = "py310"
    line-length = 88
    
    [tool.ruff.lint]
    select = ["E", "F", "I", "N", "W", "UP"]
    
    [tool.mypy]
    python_version = "3.10"
    strict = true
    
    [tool.pytest.ini_options]
    testpaths = ["tests"]
    addopts = "--strict-markers --strict-config"

=========================
Sample Python Application
=========================

**src/myapp/main.py:**

.. code-block:: python

    """A simple FastAPI application."""
    from fastapi import FastAPI
    
    app = FastAPI(title="My App", version="0.1.0")
    
    @app.get("/")
    def read_root() -> dict[str, str]:
        """Return a welcome message."""
        return {"message": "Hello, World!"}
    
    @app.get("/health")
    def health_check() -> dict[str, str]:
        """Health check endpoint."""
        return {"status": "healthy"}
    
    if __name__ == "__main__":
        import uvicorn
        uvicorn.run(app, host="0.0.0.0", port=8000)

**tests/test_main.py:**

.. code-block:: python

    """Tests for the main application."""
    from fastapi.testclient import TestClient
    from myapp.main import app
    
    client = TestClient(app)
    
    def test_read_root():
        """Test the root endpoint."""
        response = client.get("/")
        assert response.status_code == 200
        assert response.json() == {"message": "Hello, World!"}
    
    def test_health_check():
        """Test the health check endpoint."""
        response = client.get("/health")
        assert response.status_code == 200
        assert response.json() == {"status": "healthy"}

===============================
Best Practices for Python CI/CD
===============================

1. **Use modern tools**: ``uv`` for dependency management, ``ruff`` for linting/formatting
2. **Pin versions**: Lock your dependencies with ``uv.lock``
3. **Multi-environment testing**: Test against multiple Python versions
4. **Security scanning**: Include ``bandit`` and dependency vulnerability checks
5. **Coverage tracking**: Aim for >90% test coverage
6. **Type safety**: Use ``mypy`` for static type checking
7. **Environment separation**: Use GitHub environments for staging/production

.. tip::
    **Quick Setup Commands:**
    
    .. code-block:: bash
    
        # Initialize a new Python project with uv
        uv init myapp
        cd myapp
        
        # Add development dependencies
        uv add --dev pytest pytest-cov ruff mypy bandit
        
        # Create basic CI workflow
        mkdir -p .github/workflows
        # Copy the CI example above to .github/workflows/ci.yml

#######
Answers
#######

This page contains comprehensive solutions for all exercises, multiple implementation approaches, and detailed explanations to help you understand not just the "how" but the "why" behind each solution.

=======================
Complete Task Solutions
=======================

---------------------------
Task 1: Your First Pipeline
---------------------------

**Solution 1: Basic Hello World**

.. code-block:: yaml

    name: Hello World CI
    on:
      push:
        branches: [ main, develop ]
      pull_request:
        branches: [ main ]
    
    jobs:
      hello:
        runs-on: ubuntu-latest
        steps:
          - name: Checkout code
            uses: actions/checkout@v4
          
          - name: Say hello
            run: |
              echo "Hello from GitHub Actions!"
              echo "Triggered by: ${{ github.event_name }}"
              echo "Repository: ${{ github.repository }}"
              echo "Actor: ${{ github.actor }}"
              
          - name: Show system info
            run: |
              echo "OS: ${{ runner.os }}"
              echo "Architecture: ${{ runner.arch }}"
              uname -a

**Solution 2: Parallel Jobs (Extension Challenge)**

.. code-block:: yaml

    name: Hello World CI with Parallel Jobs
    on: [push, pull_request]
    
    jobs:
      hello:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          - run: echo "Hello from job 1!"
      
      system-info:
        runs-on: ubuntu-latest
        steps:
          - run: |
              echo "System Information:"
              echo "OS: $(uname -s)"
              echo "Kernel: $(uname -r)"
              echo "CPU: $(nproc) cores"
              echo "Memory: $(free -h)"
      
      timestamp:
        runs-on: ubuntu-latest
        steps:
          - run: |
              echo "Pipeline started at: $(date -u)"
              echo "Timezone: $(date +%Z)"

**Why This Works:**

- Jobs run in parallel by default (faster execution)
- Each job gets its own fresh environment
- Can see different information from each runner

**Common Mistakes Students Make:**

1. **Forgetting checkout action** - Without `actions/checkout@v4`, your code isn't available
2. **Wrong YAML indentation** - GitHub Actions is strict about spacing
3. **Missing quotes** - Always quote string values in YAML

**Production Considerations:**

- Add `timeout-minutes: 10` to prevent stuck workflows
- Use specific action versions (`@v4` not `@main`) for reliability
- Consider runner costs (macOS costs 10x more than Linux)

------------------------------
Task 2: Automated Code Quality
------------------------------

**Solution 1: Basic Linting with Ruff**

.. code-block:: yaml

    name: Code Quality
    on: [push, pull_request]
    
    jobs:
      lint:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          
          - name: Set up Python
            uses: actions/setup-python@v5
            with:
              python-version: '3.12'
              
          - name: Install dependencies
            run: |
              python -m pip install --upgrade pip
              pip install ruff black
              
          - name: Run ruff linting
            run: ruff check .
            
          - name: Check code formatting
            run: black --check .

**Solution 2: Advanced Setup with uv and pre-commit**

.. code-block:: yaml

    name: Advanced Code Quality
    on: [push, pull_request]
    
    jobs:
      lint:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          
          - name: Install uv
            uses: astral-sh/setup-uv@v3
            
          - name: Set up Python
            run: uv python install 3.12
            
          - name: Install dependencies
            run: |
              uv add --dev ruff black mypy pre-commit
              
          - name: Run pre-commit hooks
            run: |
              uv run pre-commit install
              uv run pre-commit run --all-files

**Multiple Approaches Comparison:**

1. **pip approach**: Simple, widely understood, slower
2. **uv approach**: 10-100x faster, modern Python tooling
3. **pre-commit approach**: Consistent with local development, additional overhead

**Performance Analysis:**

- pip install: ~45 seconds
- uv install: ~5 seconds  
- pre-commit: +10 seconds setup, but catches more issues

**Extension Challenge Solution: Adding mypy**

.. code-block:: yaml

    - name: Type checking
      run: |
        uv add --dev mypy
        uv run mypy src/ --strict

---------------------------
Task 3: Basic Test Coverage
---------------------------

**Solution 1: pytest with coverage**

.. code-block:: yaml

    name: Test Coverage
    on: [push, pull_request]
    
    jobs:
      test:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          
          - name: Install uv
            uses: astral-sh/setup-uv@v3
            
          - name: Set up Python
            run: uv python install 3.12
            
          - name: Install dependencies
            run: |
              uv add pytest pytest-cov
              uv sync
              
          - name: Run tests with coverage
            run: |
              uv run pytest --cov=src --cov-report=term-missing --cov-fail-under=80
              
          - name: Generate coverage report
            run: |
              uv run pytest --cov=src --cov-report=xml
              
          - name: Upload coverage to Codecov
            uses: codecov/codecov-action@v4
            with:
              file: ./coverage.xml

**Example Test File (test_calculator.py):**

.. code-block:: python

    import pytest
    from src.calculator import Calculator
    
    class TestCalculator:
        def setup_method(self):
            self.calc = Calculator()
            
        def test_addition(self):
            assert self.calc.add(2, 3) == 5
            assert self.calc.add(-1, 1) == 0
            
        def test_division_by_zero(self):
            with pytest.raises(ValueError, match="Cannot divide by zero"):
                self.calc.divide(10, 0)
                
        def test_edge_cases(self):
            assert self.calc.multiply(0, 100) == 0
            assert self.calc.subtract(5, 5) == 0

**Coverage Badge Solution (Extension Challenge):**

Add to your README.md:

.. code-block:: markdown

    [![Coverage Status](https://codecov.io/gh/username/repo/branch/main/graph/badge.svg)](https://codecov.io/gh/username/repo)

**Why 80% Coverage?**

- Industry standard for production code
- Catches most critical bugs without over-testing
- Higher percentages often lead to diminishing returns

------------------------------
Task 4: Environment Management
------------------------------

**Solution: Modern Python with uv**

.. code-block:: yaml

    name: Multi-Python Testing
    on: [push, pull_request]
    
    strategy:
      matrix:
        python-version: ['3.11', '3.12', '3.13']
        
    jobs:
      test:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          
          - name: Install uv
            uses: astral-sh/setup-uv@v3
            
          - name: Set up Python ${{ matrix.python-version }}
            run: uv python install ${{ matrix.python-version }}
            
          - name: Cache dependencies
            uses: actions/cache@v4
            with:
              path: ~/.cache/uv
              key: ${{ runner.os }}-uv-${{ hashFiles('**/pyproject.toml') }}
              restore-keys: |
                ${{ runner.os }}-uv-
                
          - name: Install dependencies
            run: uv sync --dev
            
          - name: Run tests
            run: uv run pytest

**pyproject.toml Example:**

.. code-block:: toml

    [project]
    name = "my-project"
    version = "0.1.0"
    requires-python = ">=3.10"
    dependencies = [
        "fastapi>=0.100.0",
        "pydantic>=2.0.0",
    ]
    
    [project.optional-dependencies]
    dev = [
        "pytest>=7.0.0",
        "pytest-cov>=4.0.0",
        "ruff>=0.1.0",
        "black>=23.0.0",
    ]

**Performance Comparison:**

- Without caching: 2-3 minutes per job
- With caching: 30-45 seconds per job
- uv vs pip: 10x faster dependency resolution

============
Quiz Answers
============

**Basic GitHub Actions**

1. **Answer: b. .yml or .yaml**
   
   Explanation: GitHub Actions workflows are defined in YAML files with .yml or .yaml extensions.

2. **Answer: b. In the .github/workflows/ directory**
   
   Explanation: Workflow files must be placed in the .github/workflows/ directory of your repository for GitHub to recognize them.

3. **Answer: d. All of the above**
   
   Explanation: GitHub Actions workflows can be triggered by pushes, pull requests, releases, scheduled events, and many other GitHub events.

4. **Answer: c. The virtual environment in which the workflow runs**
   
   Explanation: A runner is a server (virtual machine) that executes your workflow jobs. GitHub provides hosted runners or you can use self-hosted ones.

5. **Answer: b. Using the uses keyword in your workflow to reference an action**
   
   Explanation: The ``uses`` keyword allows you to reference and reuse actions from the same repo, other repos, or the marketplace.

6. **Answer: c. A collection of steps that run in parallel**
   
   Explanation: Jobs contain multiple steps and run in parallel by default, unless dependencies are specified with ``needs``.

7. **Answer: c. In the repository settings as encrypted secrets**
   
   Explanation: GitHub encrypts secrets and makes them available as environment variables during workflow execution.

**Modern Python Tools**

8. **Answer: c. uv**
   
   Explanation: uv is a modern, extremely fast Python package installer and resolver written in Rust.

9. **Answer: b. flake8, black, and isort**
   
   Explanation: Ruff is an all-in-one tool that replaces multiple Python linting and formatting tools with much better performance.

10. **Answer: b. uv sync --dev**
    
    Explanation: ``uv sync --dev`` installs both regular dependencies and development dependencies from the lock file.

**CI/CD Concepts**

11. **Answer: b. Integrate code changes frequently and catch issues early**
    
    Explanation: CI focuses on frequent integration and early detection of issues through automated building and testing.

12. **Answer: b. Many unit tests, some integration tests, few E2E tests**
    
    Explanation: The test pyramid emphasizes having many fast unit tests at the base, fewer integration tests in the middle, and few slow E2E tests at the top.

13. **Answer: b. A method to run jobs across multiple configurations**
    
    Explanation: Matrix strategies allow you to run the same job with different configurations (e.g., different Python versions, operating systems).

14. **Answer: c. When you want to see all matrix job results even if some fail**
    
    Explanation: ``fail-fast: false`` prevents the entire matrix from stopping when one job fails, useful for seeing all results.

**Security and Best Practices**

15. **Answer: c. Stop the pipeline immediately when critical issues are found**
    
    Explanation: Fail fast means catching and stopping on critical errors early to provide quick feedback and save resources.

16. **Answer: c. bandit**
    
    Explanation: Bandit is specifically designed to scan Python code for common security vulnerabilities.

17. **Answer: b. Use GitHub repository secrets or environment secrets**
    
    Explanation: GitHub provides encrypted secret storage that's the secure way to handle sensitive information in workflows.

====================
Additional Resources
====================

**Documentation:**

- `GitHub Actions Documentation <https://docs.github.com/en/actions>`_
- `uv Documentation <https://docs.astral.sh/uv/>`_
- `Ruff Documentation <https://docs.astral.sh/ruff/>`_

**Example Repositories:**

- `FastAPI <https://github.com/tiangolo/fastapi>`_ - Excellent CI/CD example
- `Pydantic <https://github.com/pydantic/pydantic>`_ - Comprehensive testing
- `Rich <https://github.com/Textualize/rich>`_ - Modern Python tooling

**Tools for Local Testing:**

- `act <https://github.com/nektos/act>`_ - Run GitHub Actions locally
- `pre-commit <https://pre-commit.com/>`_ - Git hooks for quality checks

.. note::

    **Pro Tips for Success:**
    
    1. Start with simple workflows and add complexity gradually
    2. Use ``workflow_dispatch`` for easy testing during development
    3. Always test your workflows on a feature branch first
    4. Read error messages carefully - they usually point to the exact issue
    5. Use the GitHub Actions marketplace for common tasks
    6. Cache aggressively but invalidate when dependencies change

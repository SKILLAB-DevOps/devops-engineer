#######
Answers
#######

===============
Quick Questions
===============

**1. What is the main difference between Continuous Integration and Continuous Deployment?**

CI automatically builds and tests code changes. CD automatically deploys tested code to production.

**2. Where do you place GitHub Actions workflow files in a repository?**

In the `.github/workflows/` directory with `.yml` or `.yaml` extensions.

**3. What is a runner in GitHub Actions?**

A virtual machine that executes your workflow jobs. GitHub provides Ubuntu, Windows, and macOS runners.

**4. How do you make a job wait for another job to complete?**

Use the `needs` keyword:

.. code-block:: yaml

    jobs:
      test:
        needs: build
        runs-on: ubuntu-latest

**5. What is the purpose of caching in CI/CD pipelines?**

To speed up builds by storing and reusing dependencies between workflow runs.

**6. How do you securely store API keys and passwords in GitHub Actions?**

Use GitHub Secrets in repository settings, then access with `${{ secrets.SECRET_NAME }}`.

**7. What does a matrix strategy allow you to do?**

Run the same job across multiple configurations (Python versions, OS, etc.) in parallel.

**8. Why is `uv` preferred over `pip` for Python CI/CD?**

It's 10-100x faster for dependency installation and provides better dependency locking.

**9. What is the "fail fast" principle in CI/CD?**

Stop the pipeline immediately when critical issues are detected to provide quick feedback.

**10. How do you trigger a workflow only when specific files change?**

Use path filters in the workflow trigger:

.. code-block:: yaml

    on:
      push:
        paths: ['src/**', 'tests/**']

=====
Tasks
=====

-------------------
Task 1: Hello World
-------------------

**hello.py:**

.. code-block:: python

    print("Hello CI/CD!")

**.github/workflows/hello.yml:**

.. code-block:: yaml

    name: Hello World
    on: push
    jobs:
      hello:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          - uses: actions/setup-python@v5
            with:
              python-version: '3.12'
          - run: python hello.py

--------------------
Task 2: Python Setup
--------------------

**fetch_data.py:**

.. code-block:: python

    import requests
    
    response = requests.get('https://api.github.com/zen')
    print(f"GitHub Zen: {response.text}")

**requirements.txt:**

.. code-block:: text

    requests

**.github/workflows/python-setup.yml:**

.. code-block:: yaml

    name: Python Setup
    on: push
    jobs:
      run:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          - uses: actions/setup-python@v5
            with:
              python-version: '3.12'
          - run: pip install -r requirements.txt
          - run: python fetch_data.py

--------------------------
Task 3: Code Quality Check
--------------------------

**bad_code.py:**

.. code-block:: python

    import os,sys
    def calc(x,y):
        return x/y
    print(calc(10,2))

**.github/workflows/quality.yml:**

.. code-block:: yaml

    name: Code Quality
    on: push
    jobs:
      lint:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          - uses: actions/setup-python@v5
            with:
              python-version: '3.12'
          - run: pip install ruff
          - run: ruff check .
          - run: ruff format --check .

**Fix the code by properly formatting it and ruff will pass.**

---------------------
Task 4: Running Tests
---------------------

**calculator.py:**

.. code-block:: python

    def add(a, b):
        return a + b
    
    def divide(a, b):
        if b == 0:
            raise ValueError("Cannot divide by zero")
        return a / b

**test_calculator.py:**

.. code-block:: python

    import pytest
    from calculator import add, divide
    
    def test_add():
        assert add(2, 3) == 5
    
    def test_divide():
        assert divide(10, 2) == 5
    
    def test_divide_by_zero():
        with pytest.raises(ValueError):
            divide(10, 0)

**requirements.txt:**

.. code-block:: text

    pytest

**.github/workflows/test.yml:**

.. code-block:: yaml

    name: Tests
    on: push
    jobs:
      test:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          - uses: actions/setup-python@v5
            with:
              python-version: '3.12'
          - run: pip install -r requirements.txt
          - run: pytest -v

---------------------
Task 5: Using Secrets
---------------------

**api_client.py:**

.. code-block:: python

    import os
    import requests
    
    token = os.environ['GITHUB_TOKEN']
    headers = {'Authorization': f'token {token}'}
    
    response = requests.get('https://api.github.com/user', headers=headers)
    print(f"User: {response.json()['login']}")

**.github/workflows/secrets.yml:**

.. code-block:: yaml

    name: Using Secrets
    on: push
    jobs:
      api:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          - uses: actions/setup-python@v5
            with:
              python-version: '3.12'
          - run: pip install requests
          - env:
              GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
            run: python api_client.py

**Set up GITHUB_TOKEN in repository Settings → Secrets.**

----------------------------
Task 6: Caching Dependencies
----------------------------

**data_app.py:**

.. code-block:: python

    import pandas as pd
    
    data = {'name': ['Alice', 'Bob'], 'age': [25, 30]}
    df = pd.DataFrame(data)
    print(df)

**requirements.txt:**

.. code-block:: text

    pandas

**.github/workflows/caching.yml:**

.. code-block:: yaml

    name: Caching Demo
    on: push
    jobs:
      process:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          - uses: actions/setup-python@v5
            with:
              python-version: '3.12'
          - uses: actions/cache@v4
            with:
              path: ~/.cache/pip
              key: ${{ runner.os }}-pip-${{ hashFiles('requirements.txt') }}
          - run: pip install -r requirements.txt
          - run: python data_app.py

----------------------
Task 7: Matrix Testing
----------------------

**version_check.py:**

.. code-block:: python

    import sys
    
    version = sys.version_info
    print(f"Python {version.major}.{version.minor}")
    
    if version >= (3, 12):
        print("Has new f-string features")

**.github/workflows/matrix.yml:**

.. code-block:: yaml

    name: Matrix Testing
    on: push
    jobs:
      test:
        runs-on: ubuntu-latest
        strategy:
          matrix:
            python-version: ['3.11', '3.12', '3.13']
        steps:
          - uses: actions/checkout@v4
          - uses: actions/setup-python@v5
            with:
              python-version: ${{ matrix.python-version }}
          - run: python version_check.py

-----------------------------
Task 8: Environment Variables
-----------------------------

**config_app.py:**

.. code-block:: python

    import os
    
    env = os.environ.get('APP_ENV', 'dev')
    debug = os.environ.get('DEBUG', 'false') == 'true'
    
    print(f"Environment: {env}")
    print(f"Debug mode: {debug}")
    
    if env == 'production':
        print("Running in production!")
    else:
        print("Running in development")

**.github/workflows/environments.yml:**

.. code-block:: yaml

    name: Environment Config
    on: push
    jobs:
      dev:
        runs-on: ubuntu-latest
        env:
          APP_ENV: development
          DEBUG: true
        steps:
          - uses: actions/checkout@v4
          - uses: actions/setup-python@v5
            with:
              python-version: '3.12'
          - run: python config_app.py
      
      prod:
        runs-on: ubuntu-latest
        env:
          APP_ENV: production
          DEBUG: false
        steps:
          - uses: actions/checkout@v4
          - uses: actions/setup-python@v5
            with:
              python-version: '3.12'
          - run: python config_app.py

-------------------------
Task 9: Branch Protection
-------------------------

**.github/workflows/pr.yml:**

.. code-block:: yaml

    name: PR Checks
    on:
      pull_request:
        branches: [main]
    jobs:
      quality:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          - uses: actions/setup-python@v5
            with:
              python-version: '3.12'
          - run: pip install ruff pytest
          - run: ruff check .
          - run: pytest

**Set up branch protection in Settings → Branches → Add rule for main:**

- Require status checks to pass
- Select "quality" as required check
- Require pull request reviews

----------------------------
Task 10: Deployment Pipeline
----------------------------

**pyproject.toml:**

.. code-block:: toml

    [build-system]
    requires = ["hatchling"]
    build-backend = "hatchling.build"
    
    [project]
    name = "my-demo-package"
    version = "0.1.0"
    description = "Demo package"

**src/my_package/__init__.py:**

.. code-block:: python

    def hello():
        return "Hello from my package!"

**.github/workflows/deploy.yml:**

.. code-block:: yaml

    name: Deploy
    on:
      release:
        types: [published]
    jobs:
      deploy:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          - uses: actions/setup-python@v5
            with:
              python-version: '3.12'
          - run: pip install build twine
          - run: python -m build
          - env:
              TWINE_USERNAME: __token__
              TWINE_PASSWORD: ${{ secrets.TESTPYPI_API_TOKEN }}
            run: twine upload --repository testpypi dist/*

**Create a release on GitHub to trigger deployment.**

====================
Open-Ended Questions
====================

**Question 1: Pipeline Strategy**

For a 10-person team:

- Keep pipeline under 10 minutes total
- Run tests in parallel by module
- Use caching for dependencies
- Automatic staging deployment, manual production
- Set up notifications for failures

**Question 2: Testing Strategy**

For API with external services:

- 70% unit tests (mocked externals)
- 25% integration tests (test doubles)
- 5% end-to-end tests (real services)
- Test error scenarios and timeouts
- Use contract testing for API compatibility

**Question 3: Security Integration**

To maintain development speed:

- Run basic security checks in PR pipeline (< 2 minutes)
- Full security scans nightly
- Auto-fix simple vulnerabilities
- Block on critical issues, alert on medium/low
- Integrate security training in onboarding

**Question 4: Multi-Environment Strategy**

Environment management:

- Use environment variables for config differences
- Promote through: dev → staging → production
- Automatic deployment to dev/staging
- Manual approval for production
- Keep environments as similar as possible

**Question 5: Tool Selection**

Evaluation criteria:

- Start with team's existing tools and skills
- Consider integration with current workflow
- Evaluate setup time and learning curve
- Test with a pilot project
- Consider long-term maintenance needs
- Balance features with simplicity

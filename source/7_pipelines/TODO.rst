####
TODO
####

This section contains practical exercises designed to build your CI/CD skills progressively. Each task includes estimated completion time, skills practiced, and success criteria.

.. note::

    **How to Use This Section:**
    
    1. Start with Beginner tasks if you're new to CI/CD
    2. Check off each task as you complete it
    3. Use the ANSWERS.rst file for detailed solutions
    4. Don't skip ahead - each level builds on the previous one

==============
Beginner Tasks
==============

**Prerequisites:** Basic Git knowledge, GitHub account, simple Python project

---------------------------
Task 1: Your First Pipeline
---------------------------

**Objective:** Create a basic "Hello World" CI pipeline

**What you'll do:**

- Create a public repository in your GitHub account
- Create `.github/workflows/hello.yml`
- Add a workflow that runs on every push
- Test by pushing a commit

**Skills practiced:** YAML syntax, GitHub Actions basics, workflow triggers

**Success criteria:**

- Green checkmark appears on your commit
- Can see workflow run in Actions tab
- Understand what each line of YAML does

**Extension challenge:** Add a second job that runs in parallel


------------------------------
Task 2: Automated Code Quality
------------------------------

**Objective:** Add linting and formatting checks to your pipeline

**What you'll do:**

- Add ruff for Python linting
- Add black for code formatting  
- Configure pre-commit hooks
- Make pipeline fail on style violations

**Skills practiced:** Code quality tools, pipeline failure handling

**Success criteria:**

- Pipeline catches and reports style violations
- Can fix violations and see pipeline pass
- Understand the importance of consistent code style

**Extension challenge:** Add mypy for type checking

---------------------------
Task 3: Basic Test Coverage
---------------------------

**Objective:** Implement automated testing with coverage reporting

**What you'll do:**

- Write unit tests for provided functions
- Add pytest to pipeline
- Generate coverage reports
- Set minimum coverage threshold (80%)

**Skills practiced:** Unit testing, coverage analysis, quality gates

**Success criteria:**

- All tests pass in CI
- Coverage report shows in pipeline logs
- Pipeline fails if coverage drops below threshold

**Extension challenge:** Add coverage badge to README

------------------------------
Task 4: Environment Management
------------------------------

**Objective:** Learn proper Python dependency management

**What you'll do:**

- Convert requirements.txt to pyproject.toml
- Use uv for fast dependency installation
- Cache dependencies to speed up builds
- Test with multiple Python versions

**Skills practiced:** Modern Python tooling, build optimization

**Success criteria:**
- Build time reduced by 50% with caching
- Pipeline tests Python 3.11, 3.12, and 3.13
- Dependencies install consistently

**Extension challenge:** Add dependabot for automatic updates

====================
Knowledge Check Quiz
====================

This quiz tests your understanding of the concepts covered in this section. Each question has one correct answer.

**Basic GitHub Actions**

1. What file extension is used for GitHub Actions workflow files?

    a. .workflow
    b. .yml or .yaml
    c. .github
    d. .actions

2. Where must the GitHub Actions workflow files be placed in a repository?

    a. In the root directory of the repository
    b. In the .github/workflows/ directory
    c. In the actions/ directory
    d. In the workflow/ directory

3. Which event can trigger a GitHub Actions workflow?

    a. Push to a repository
    b. A pull request is opened
    c. A GitHub release is created
    d. All of the above

4. What is a runner in GitHub Actions?

    a. A type of workflow
    b. A user who triggers the workflow
    c. The virtual environment in which the workflow runs
    d. A specific task within a job

5. How can you reuse workflows in GitHub Actions?

    a. By linking to another workflow file in the repository
    b. Using the uses keyword in your workflow to reference an action
    c. By copying the workflow file to another repository
    d. It is not possible to reuse workflows

6. What is a job in the context of GitHub Actions?

    a. A step in a workflow
    b. An individual task that runs sequentially in a workflow
    c. A collection of steps that run in parallel
    d. A set of workflows that are executed on a trigger event

7. How are secrets stored and used in GitHub Actions?

    a. In plain text files within the repository
    b. As environment variables in the virtual environment
    c. In the repository settings as encrypted secrets
    d. They are not supported; all sensitive data must be hard-coded

**Modern Python Tools**

8. Which tool is recommended for fast Python package management?

    a. pip
    b. conda
    c. uv
    d. poetry

9. What does ``ruff`` replace in modern Python development?

    a. pytest
    b. flake8, black, and isort
    c. mypy
    d. bandit

10. Which command installs both regular and development dependencies with uv?

    a. ``uv install --dev``
    b. ``uv sync --dev``
    c. ``uv add --dev``
    d. ``uv pip install -r requirements.txt``

**CI/CD Concepts**

11. What is the main purpose of Continuous Integration?

    a. Deploy code to production automatically
    b. Integrate code changes frequently and catch issues early
    c. Monitor production applications
    d. Manage project documentation

12. Which testing strategy follows the "test pyramid" principle?

    a. Many E2E tests, few unit tests
    b. Many unit tests, some integration tests, few E2E tests
    c. Only integration tests
    d. Equal amounts of all test types

13. What is a matrix strategy in GitHub Actions?

    a. A way to organize secrets
    b. A method to run jobs across multiple configurations
    c. A type of workflow trigger
    d. A security feature

14. When should you use ``fail-fast: false`` in a matrix strategy?

    a. Always, for better performance
    b. Never, it's a bad practice
    c. When you want to see all matrix job results even if some fail
    d. Only for production deployments

**Security and Best Practices**

15. What is the principle of "fail fast" in CI/CD?

    a. Deploy quickly to production
    b. Run the slowest tests first
    c. Stop the pipeline immediately when critical issues are found
    d. Always use the fastest runner

16. Which tool scans Python code for security vulnerabilities?

    a. ruff
    b. mypy
    c. bandit
    d. pytest

17. What is the recommended approach for handling secrets in GitHub Actions?

    a. Store them in the code repository
    b. Use GitHub repository secrets or environment secrets
    c. Pass them as command line arguments
    d. Use environment variables in the workflow file


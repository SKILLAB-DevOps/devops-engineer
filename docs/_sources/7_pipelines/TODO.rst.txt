####
TODO
####

#########
Exercises
#########

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

==========================
Hands-On Programming Tasks
==========================

----------------------------------
Task 1: Create Your 2nd Python CLI
----------------------------------

**Objective**: Build a simple CLI application and set up basic CI/CD

**Requirements:**

1. Create a new GitHub repository named ``my-python-cli``
2. Build a CLI using Click that has these commands:

   - ``greet --name <name>`` - prints a greeting
   - ``weather <city>`` - shows mock weather data
   - ``calc add <a> <b>`` - adds two numbers
3. Use modern Python project structure with ``src/`` layout
4. Include comprehensive tests using pytest
5. Set up a basic CI pipeline that runs on push and pull requests

**Deliverables:**

- Working CLI installable with ``uv run python -m my_cli``
- Test coverage >80%
- Passing CI pipeline

-------------------------------------------
Task 2: Implement Modern Python CI Pipeline
-------------------------------------------

**Objective**: Create a comprehensive CI pipeline using modern tools

**Requirements:**

1. Fork or use the CLI from Task 1
2. Create a CI pipeline that includes:

   - Code formatting check with ``ruff format --check``
   - Linting with ``ruff check``
   - Type checking with ``mypy``
   - Security scanning with ``bandit``
   - Testing with ``pytest`` and coverage reporting
   - Matrix testing across Python 3.10, 3.11, and 3.12
3. Use ``uv`` for dependency management
4. Configure proper caching for faster builds
5. Upload test coverage to a service like Codecov

**Deliverables:**

- ``.github/workflows/ci.yml`` file
- Pipeline that completes in <5 minutes
- All quality checks passing

------------------------------------
Task 3: Build a Complete CD Pipeline
------------------------------------

**Objective**: Extend CI with deployment capabilities

**Requirements:**

1. Extend the CI pipeline from Task 2
2. Add a CD pipeline that:

   - Builds a Python package with ``uv build``
   - Creates GitHub releases on version tags
   - Publishes to PyPI (use TestPyPI for practice)
   - Deploys documentation to GitHub Pages

3. Use GitHub environments for staging and production
4. Implement proper secret management
5. Add deployment notifications (e.g., Slack webhook)

**Deliverables:**

- Working CD pipeline triggered by tags
- Published package on TestPyPI
- Automated GitHub releases

------------------------------------
Task 4: Create Custom GitHub Actions
------------------------------------

**Objective**: Build reusable GitHub Actions

**Requirements:**

1. Create a custom composite action for Python setup:

   - Sets up Python with specified version
   - Installs and configures uv
   - Installs dependencies
   - Caches appropriately
2. Create a custom action for Python quality checks:

   - Runs ruff, mypy, bandit
   - Generates and uploads reports
   - Provides clear success/failure feedback
3. Use these actions in multiple repositories
4. Publish actions to GitHub Marketplace (optional)

**Deliverables:**

- ``.github/actions/`` directory with custom actions
- Documentation for action inputs/outputs
- Example workflows using the actions

----------------------------------
Task 5: Advanced Pipeline Features
----------------------------------

**Objective**: Implement advanced CI/CD patterns

**Requirements:**

1. Implement a blue-green deployment simulation
2. Add conditional workflows based on changed files
3. Create a workflow that:

   - Runs different jobs based on branch (main vs feature)
   - Uses workflow artifacts for job communication
   - Implements approval gates for production deployments
   - Includes rollback capabilities
4. Add comprehensive monitoring and alerting
5. Create workflow templates for team use

**Deliverables:**

- Advanced workflow configurations
- Documentation for deployment procedures
- Monitoring dashboard (can use GitHub's built-in features)

===========================
Research and Analysis Tasks
===========================

--------------------------------
Task 6: Tool Comparison Analysis
--------------------------------

**Objective**: Compare different CI/CD platforms and tools

**Requirements:**

1. Research and compare:

   - GitHub Actions vs GitLab CI vs Jenkins
   - uv vs poetry vs pip-tools for dependency management
   - Different testing strategies and tools

2. Create a 1 ADR (Architectural Decision Record) document or 1 PoC (Proof of Concept) with:

   - Feature comparison table
   - Performance benchmarks
   - Cost analysis
   - Recommendations for different use cases

**Deliverables:**

- 1 ADR (Architectural Decision Record) document or 1 PoC (Proof of Concept)
- Practical recommendations with justification

----------------------
Task 7: Security Audit
----------------------

**Objective**: Perform a security review of CI/CD pipelines

**Requirements:**

1. Audit an existing CI/CD pipeline for security issues
2. Check for:

   - Secret management practices
   - Dependency vulnerabilities
   - Permission configurations
   - Code injection possibilities
3. Create a security checklist for CI/CD pipelines
4. Implement fixes for identified issues

**Deliverables:**

- Security audit report
- CI/CD security checklist
- Improved pipeline configuration

==================
Intermediate Tasks
==================

**Prerequisites:** Completed all Beginner tasks, basic Docker knowledge

------------------------------------
Task 5: Multi-Environment Deployment
------------------------------------

**Objective:** Deploy to staging and production environments

**What you'll do:**

- Set up staging environment (GitHub Pages)
- Create production environment with manual approval
- Use environment-specific configuration
- Implement proper secret management

**Skills practiced:** Environment management, deployment strategies, secrets

**Success criteria:**

- Code automatically deploys to staging on main branch
- Production deployment requires manual approval
- Different configurations for each environment

**Extension challenge:** Add smoke tests that run post-deployment

-------------------------------
Task 6: Matrix Testing Strategy
-------------------------------

**Objective:** Test across multiple operating systems and Python versions

**What you'll do:**

- Configure matrix strategy for OS (Ubuntu, Windows, macOS)
- Test Python versions 3.10, 3.11, 3.12
- Handle OS-specific test failures gracefully
- Optimize for fastest feedback

**Skills practiced:** Cross-platform testing, matrix configurations

**Success criteria:**

- Pipeline runs on all OS/Python combinations
- Total runtime under 10 minutes
- Clear reporting of which combinations fail

**Extension challenge:** Add performance benchmarking across platforms

-------------------------------
Task 7: Security and Compliance
-------------------------------

**Objective:** Integrate security scanning into your pipeline

**What you'll do:**

- Add Bandit for Python security scanning
- Implement dependency vulnerability checking
- Add SAST (Static Application Security Testing)
- Configure security failure thresholds

**Skills practiced:** Security automation, vulnerability management

**Success criteria:**

- Pipeline catches security vulnerabilities
- Clear reporting of security issues
- Automated blocking of high-severity findings

**Extension challenge:** Add license compliance checking

-----------------------------
Task 8: Container Integration
-----------------------------

**Objective:** Build and deploy containerized applications

**What you'll do:**

- Create Dockerfile for your application
- Build Docker images in pipeline
- Push images to container registry
- Deploy containerized app to staging

**Skills practiced:** Containerization, registry management, container deployment

**Success criteria:**

- Docker images build successfully
- Images pushed to GitHub Container Registry
- Application runs correctly in container

**Extension challenge:** Multi-stage builds for optimized image size

==============
Advanced Tasks
==============

**Prerequisites:** Completed Intermediate tasks, Kubernetes basics

-----------------------------------
Task 9: Microservices Orchestration
-----------------------------------

**Objective:** Coordinate CI/CD across multiple related services

**What you'll do:**

- Set up 3 microservices with dependencies
- Implement cross-service integration testing
- Coordinate deployments with proper ordering
- Handle partial deployment failures

**Skills practiced:** Microservices architecture, service dependencies

**Success criteria:**

- Services deploy in correct order
- Integration tests validate service communication
- Rollback works across all services

**Extension challenge:** Implement canary deployments

------------------------------
Task 10: Blue-Green Deployment
------------------------------

**Objective:** Implement zero-downtime deployment strategy

**What you'll do:**

- Set up blue and green environments
- Implement automated traffic switching
- Add health checks and rollback triggers
- Monitor deployment success metrics

**Skills practiced:** Advanced deployment patterns, traffic management

**Success criteria:**

- Zero downtime during deployments
- Automatic rollback on health check failure
- Deployment completes in under 2 minutes

**Extension challenge:** Add gradual traffic shifting (10%, 50%, 100%)

-----------------------------------
Task 11: Performance and Monitoring
-----------------------------------

**Objective:** Integrate performance testing and monitoring

**What you'll do:**

- Add load testing to pipeline
- Implement performance regression detection
- Set up monitoring and alerting
- Create performance budgets

**Skills practiced:** Performance testing, monitoring, SRE practices

**Success criteria:**

- Load tests run on every deployment
- Performance regressions block deployments
- Monitoring dashboards show key metrics

**Extension challenge:** Implement chaos engineering tests

-----------------------------
Task 12: Multi-Cloud Strategy
-----------------------------

**Objective:** Deploy to multiple cloud platforms

**What you'll do:**

- Deploy to AWS, Azure, and GCP
- Implement cloud-agnostic configuration
- Handle cloud-specific features gracefully
- Monitor costs across platforms

**Skills practiced:** Multi-cloud architecture, cost optimization

**Success criteria:**

- Application runs identically on all clouds
- Deployment costs tracked and optimized
- Failover between clouds works automatically

**Extension challenge:** Implement geographic load balancing

========================
Project-Based Challenges
========================

--------------------------------------
Challenge 1: Multi-Service Application
--------------------------------------

**Objective**: Set up CI/CD for a microservices architecture

**Requirements:**

1. Create a repository with:

   - 3 Python microservices
   - Shared library/common code
   - Database migrations
   - API documentation

2. Implement CI/CD that:

   - Detects which services changed
   - Runs tests only for affected services
   - Coordinates deployments across services
   - Manages database schema updates

--------------------------------------
Challenge 2: Open Source Project Setup
--------------------------------------

**Objective**: Create a production-ready open source Python project

**Requirements:**

1. Set up a complete open source project with:

   - Comprehensive documentation (README, CONTRIBUTING, etc.)
   - Code of conduct and issue templates
   - Automated dependency updates (Dependabot)
   - Multiple Python version support
   - Cross-platform testing (Linux, macOS, Windows)
   - Automated changelog generation
   - Semantic versioning with automated releases

=========================
Troubleshooting Scenarios
=========================

---------------------------------------
Scenario 1: Pipeline Performance Issues
---------------------------------------

You inherit a CI pipeline that takes 45 minutes to complete. Users complain about slow feedback. Analyze and optimize the pipeline to reduce runtime by at least 50%.

-----------------------
Scenario 2: Flaky Tests
-----------------------

The test suite has several tests that fail intermittently, causing developers to re-run pipelines frequently. Identify and fix the root causes of test flakiness.

-------------------------------
Scenario 3: Deployment Failures
-------------------------------

Production deployments are failing 30% of the time due to various issues. Design and implement a more robust deployment strategy with proper rollback mechanisms.

=====================
Submission Guidelines
=====================

**For Practical Tasks:**

1. Create GitHub repositories for each task
2. Include comprehensive README files
3. Ensure all pipelines are publicly visible
4. Add comments explaining complex configurations
5. Include screenshots of successful pipeline runs

**For Analysis Tasks:**

1. Submit documents in Markdown format
2. Include references and sources
3. Provide concrete examples and evidence
4. Make recommendations actionable

**Evaluation Criteria:**

- **Functionality**: Does it work as specified?
- **Best Practices**: Follows modern CI/CD principles?
- **Code Quality**: Clean, well-documented code?
- **Innovation**: Creative solutions to challenges?
- **Documentation**: Clear explanations and instructions?

.. note::

    **Getting Help:**
    
    - Use LLM for questions
    - Reference the documentation we've covered
    - Check GitHub Actions marketplace for existing solutions
    - Test workflows with ``workflow_dispatch`` for easier debugging

**Bonus Points:**

- Contribute improvements to open source projects
- Create tutorial content for others
- Present your solutions to the class
- Help teammates with their implementations
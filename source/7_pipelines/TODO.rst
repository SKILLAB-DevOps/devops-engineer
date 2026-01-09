####
TODO
####


This section contains practical exercises designed to build your CI/CD skills progressively. Each task includes estimated completion time and clear success criteria.

.. note::

    **How to Use This Section:**
    
    1. Start with Quick Questions to test your understanding
    2. Complete the 10-Minute Tasks to build hands-on experience
    3. Use the ANSWERS.rst file for detailed solutions
    4. Think through the Open-Ended Questions for deeper understanding

===============
Quick Questions
===============

**These questions test your foundational CI/CD knowledge. Check ANSWERS.rst for explanations.**

1. **What is the main difference between Continuous Integration and Continuous Deployment?**

2. **Where do you place GitHub Actions workflow files in a repository?**

3. **What is a runner in GitHub Actions?**

4. **How do you make a job wait for another job to complete?**

5. **What is the purpose of caching in CI/CD pipelines?**

6. **How do you securely store API keys and passwords in GitHub Actions?**

7. **What does a matrix strategy allow you to do?**

8. **Why is `uv` preferred over `pip` for Python CI/CD?**

9. **What is the "fail fast" principle in CI/CD?**

10. **How do you trigger a workflow only when specific files change?**

===============
10-Minute Tasks
===============

**Each task should take about 10-15 minutes to complete. All use Python applications.**

-------------------
Task 1: Hello World
-------------------

**Objective:** Create your first GitHub Actions workflow

**What to do:**

- Create a simple Python script that prints "Hello CI/CD!"
- Create `.github/workflows/hello.yml`
- Trigger workflow on push to main branch

**Success criteria:**

- Workflow runs successfully
- Output visible in Actions tab
- Green checkmark on commit

**Skills practiced:** Basic workflow creation, YAML syntax

--------------------
Task 2: Python Setup
--------------------

**Objective:** Set up Python environment in GitHub Actions

**What to do:**

- Create a Python script that uses `requests` library
- Install dependencies in workflow
- Run the script successfully

**Success criteria:**

- Python environment set up correctly
- Dependencies installed
- Script executes without errors

**Skills practiced:** Python setup, dependency installation

--------------------------
Task 3: Code Quality Check
--------------------------

**Objective:** Add linting to your pipeline

**What to do:**

- Install and configure `ruff` for linting
- Create intentionally bad Python code
- Watch the pipeline fail, then fix the code

**Success criteria:**

- Ruff catches style violations
- Pipeline fails on bad code
- Pipeline passes after fixes

**Skills practiced:** Code quality tools, failure handling

---------------------
Task 4: Running Tests
---------------------

**Objective:** Add automated testing to your pipeline

**What to do:**

- Write a simple function and its pytest test
- Run tests in GitHub Actions
- View test results in workflow

**Success criteria:**

- Tests run successfully in CI
- Test results clearly visible
- Failed tests break the pipeline

**Skills practiced:** Test automation, pytest

---------------------
Task 5: Using Secrets
---------------------

**Objective:** Safely handle sensitive information

**What to do:**

- Create a script that uses an API key
- Store API key as GitHub secret
- Access secret in workflow

**Success criteria:**

- Secret not visible in logs
- Script successfully uses API key
- Workflow completes securely

**Skills practiced:** Secret management, security

----------------------------
Task 6: Caching Dependencies
----------------------------

**Objective:** Speed up builds with caching

**What to do:**

- Add dependency caching to your workflow
- Compare build times before/after caching
- Test cache invalidation

**Success criteria:**

- Second run significantly faster
- Cache hits visible in logs
- Dependencies restored correctly

**Skills practiced:** Build optimization, caching

----------------------
Task 7: Matrix Testing
----------------------

**Objective:** Test across multiple Python versions

**What to do:**

- Configure matrix to test Python 3.11, 3.12, 3.13
- Run the same tests on all versions
- Handle version-specific differences

**Success criteria:**

- Tests run on all Python versions
- Matrix results clearly displayed
- Version-specific issues identified

**Skills practiced:** Matrix strategies, cross-version testing

-----------------------------
Task 8: Environment Variables
-----------------------------

**Objective:** Use environment-based configuration

**What to do:**

- Create Python script that behaves differently per environment
- Set different env vars for dev/prod workflows
- Test both configurations

**Success criteria:**

- Script adapts to environment variables
- Different behaviors in different environments
- Configuration managed externally

**Skills practiced:** Environment management, configuration

-------------------------
Task 9: Branch Protection
-------------------------

**Objective:** Enforce quality gates on pull requests

**What to do:**

- Create a pull request workflow
- Set up branch protection rules
- Test that bad code blocks merging

**Success criteria:**

- PR workflow runs automatically
- Branch protection prevents bad merges
- Status checks required for merge

**Skills practiced:** Quality gates, branch protection

----------------------------
Task 10: Deployment Pipeline
----------------------------

**Objective:** Deploy code automatically

**What to do:**

- Create a simple Python package
- Build and publish to TestPyPI on releases
- Test the deployment process

**Success criteria:**

- Package builds successfully
- Publishes to TestPyPI
- Triggered only on releases

**Skills practiced:** Deployment automation, package publishing

====================
Open-Ended Questions
====================

**These questions don't have single correct answers. Think through them and discuss with peers.**

**Question 1: Pipeline Strategy**

*How would you design a CI/CD pipeline for a team of 10 Python developers working on a web application?*

**Consider:**

- Build times and developer productivity
- Quality gates and testing strategies
- Security scanning and vulnerability management
- Deployment frequency and rollback capabilities
- Resource costs and optimization

**Guidelines:**

- Balance speed with thoroughness
- Consider developer experience
- Think about failure scenarios
- Plan for growth and scaling

**Question 2: Testing Strategy**

*What testing approach would you implement for a Python API that integrates with multiple external services?*

**Consider:**

- Unit vs integration vs end-to-end testing
- Mocking external services
- Test data management
- Performance and load testing
- Testing in different environments

**Guidelines:**

- Follow the test pyramid principle
- Consider test reliability and maintainability
- Think about test execution time
- Plan for different types of failures

**Question 3: Security Integration**

*How would you integrate security practices into your CI/CD pipeline without slowing down development?*

**Consider:**

- Vulnerability scanning timing and frequency
- Secret management and rotation
- Code analysis and SAST tools
- Dependency security monitoring
- Compliance requirements

**Guidelines:**

- Shift security left in the pipeline
- Automate as much as possible
- Provide clear feedback to developers
- Balance security with productivity

**Question 4: Multi-Environment Strategy**

*How would you manage deployments across development, staging, and production environments with different requirements?*

**Consider:**

- Environment-specific configurations
- Data management and migrations
- Rollback strategies
- Monitoring and alerting
- Approval processes

**Guidelines:**

- Keep environments as similar as possible
- Use environment variables for configuration
- Implement proper promotion workflows
- Plan for disaster recovery

**Question 5: Tool Selection**

*How would you evaluate and choose between different CI/CD platforms (GitHub Actions, GitLab CI, Jenkins, etc.) for your organization?*

**Consider:**

- Team size and technical expertise
- Integration with existing tools
- Cost and resource requirements
- Scalability and performance needs
- Maintenance and support

**Guidelines:**

- Start with organizational constraints
- Evaluate based on actual requirements
- Consider long-term maintenance costs
- Plan for team training and adoption

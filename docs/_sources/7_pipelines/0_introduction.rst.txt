###############
CI/CD Pipelines
###############

Automated software delivery pipelines that test, validate, and deploy code changes safely to production.

===========================
Continuous Integration (CI)
===========================

**Core Workflow:**

.. literalinclude:: ../../source_code/pipelines/basic/ci.yml
   :language: yaml
   :caption: Basic CI Pipeline - GitHub Actions

**Key Components:**

• **Automated builds** on every commit
• **Multi-version testing** (Python 3.11, 3.12, 3.13)
• **Code quality checks** (formatting, linting, type checking)
• **Fast feedback** (<5 minutes for basic validation)

==========================
Continuous Deployment (CD)
==========================

**Production Pipeline:**

.. literalinclude:: ../../source_code/pipelines/advanced/production_ci_cd.yml
   :language: yaml
   :lines: 1-50
   :caption: Multi-stage production pipeline with security and deployment

**Pipeline Stages:**

1. **Quality checks** (linting, formatting, type checking)
2. **Multi-platform testing** (Ubuntu, Windows, macOS)
3. **Security scanning** (vulnerability detection, dependency audit)
4. **Package building** (wheel and source distributions)
5. **Environment deployment** (staging → production)
6. **Monitoring and cleanup**

=========================
Modern Python CI/CD Stack
=========================

**Essential Tools (2024):**

.. code-block:: toml

   # Modern pyproject.toml configuration
   [project.optional-dependencies]
   dev = [
       "uv>=0.1.0",           # Fast package manager (replaces pip)
       "ruff>=0.1.0",         # Fast linter and formatter (replaces flake8/black/isort)
       "mypy>=1.5.0",         # Static type checking
       "pytest>=7.0.0",       # Testing framework
       "bandit>=1.7.0",       # Security scanning
   ]


===================
Platform Comparison
===================

**GitHub Actions** (Recommended for most teams)

- Native GitHub integration
- 2,000 free minutes/month for private repos
- Excellent marketplace ecosystem
- Simple YAML configuration

**GitLab CI/CD**

- All-in-one DevOps platform
- Built-in container registry
- Advanced deployment features
- Self-hosted options

**Jenkins**

- Maximum customization
- Large plugin ecosystem
- Higher maintenance overhead
- Self-hosted only

===========
Key Metrics
===========

**Deployment Frequency**

- Target: Daily deployments
- Measure: Commits per day reaching production

**Lead Time** 

- Target: <4 hours commit to production
- Measure: Time from code commit to user availability

**Change Failure Rate**

- Target: <5% of deployments require rollback
- Measure: Failed deployments / total deployments

**Mean Time to Recovery**

- Target: <1 hour for rollbacks
- Measure: Detection to resolution time

=====================
Container Integration
=====================

**Docker + CI/CD Pattern:**

.. literalinclude:: ../../source_code/pipelines/examples/Dockerfile
   :language: docker
   :lines: 1-30
   :caption: Multi-stage production Docker build

**Key Features:**

- Multi-stage builds for minimal image size
- Non-root user for security
- Health checks for deployment validation
- Dependency caching for faster builds

================
Common Solutions
================

**Slow Tests**

- Use test parallelization and caching
- Implement smart test selection
- Container-based consistent environments

**Security Integration**

- Automated vulnerability scanning with bandit
- Dependency security checks with safety
- Built-in compliance validation

**Cost Optimization**

- Intelligent caching strategies 
- Conditional job execution
- Right-sized runner selection

===========
Quick Start
===========

**1. Basic Pipeline (5 minutes):**

.. literalinclude:: ../../source_code/pipelines/basic/hello_world.py
   :language: python
   :caption: Simple test script with proper error handling

**2. GitHub Actions Setup:**

.. literalinclude:: ../../source_code/pipelines/basic/ci.yml
   :language: yaml
   :lines: 1-25
   :caption: .github/workflows/ci.yml

**3. Production Template:**

Full production-ready examples available in ``source_code/pipelines/``

- ``basic/`` - Getting started examples
- ``advanced/`` - Production patterns  
- ``templates/`` - Reusable configurations
- ``examples/`` - Complete applications

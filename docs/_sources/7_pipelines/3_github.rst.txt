###########################
7.3 GitHub Actions Advanced
###########################

**From Simple to Sophisticated**

You've built basic pipelines and understand the fundamentals. Now it's time to explore the advanced features that enable enterprise-grade automation. This section covers the patterns and techniques that separate hobby projects from production systems used by companies like Netflix, Spotify, and GitHub itself.

These aren't just "nice-to-have" features - they're essential capabilities that enable teams to scale their development practices, reduce costs, and maintain reliability as systems grow complex.

===================
Learning Objectives
===================

By the end of this section, you will:

• **Master** matrix strategies for testing across multiple platforms and configurations
• **Create** reusable workflows that eliminate duplication across projects
• **Implement** cost optimization strategies that can reduce CI/CD expenses by 50-80%
• **Integrate** with external services for notifications, deployments, and monitoring
• **Apply** advanced security practices including secrets management and supply chain security
• **Build** efficient caching and artifact strategies for faster pipelines

**Prerequisites:** Completed previous sections, understanding of YAML, experience with basic GitHub Actions workflows

**Real-World Context:** The techniques in this section are used by teams managing hundreds of repositories, thousands of daily deployments, and multi-million dollar infrastructure budgets.

================================
Advanced GitHub Actions Patterns
================================

**Scaling Beyond Basic Workflows**

As your projects grow from single applications to complex systems, your CI/CD needs evolve dramatically. Simple "build, test, deploy" workflows become insufficient when you're managing:

- Multiple applications with different technology stacks
- Cross-platform compatibility requirements (Windows, macOS, Linux)
- Various deployment environments (staging, production, region-specific instances)
- Integration with external systems (cloud platforms, monitoring tools, notification systems)
- Large development teams with different workflow requirements

Advanced GitHub Actions patterns solve these challenges by providing structure, reusability, and intelligence to your automation.

.. note::

    **Enterprise Reality Check:** Companies like Shopify manage over 2,000 repositories with GitHub Actions. Without advanced patterns, they would need thousands of similar workflow files. With reusable workflows and matrix strategies, they maintain consistency across their entire platform with just a handful of template workflows.

==========================================
Matrix Strategies & Cross-Platform Testing
==========================================

**The Combinatorial Testing Challenge**

Imagine you're building a Python CLI tool that needs to work on Windows, macOS, and Linux, across Python versions 3.10, 3.11, and 3.12. That's 9 different combinations to test. Add in different dependency versions or additional configurations, and you quickly have dozens of test scenarios.

Matrix strategies automate this combinatorial testing, running your tests across all combinations simultaneously.

**Strategic Matrix Design**

.. code-block:: yaml

    # Smart matrix strategy for real-world testing
    strategy:
      fail-fast: false  # Don't stop other jobs when one fails
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        python-version: ["3.11", "3.12", "3.13"]
        include:
          # Add experimental configurations
          - os: ubuntu-latest
            python-version: "3.13-dev"
            experimental: true
          # Add platform-specific configurations
          - os: windows-latest
            python-version: "3.12"
            extra-args: "--enable-optimizations"
        exclude:
          # Skip problematic combinations
          - os: macos-latest
            python-version: "3.10"  # Performance issues on older macOS

**Why This Approach Works:**

• **Comprehensive coverage** without manual test management
• **Parallel execution** - 9 combinations run simultaneously instead of sequentially
• **Selective exclusions** - Skip known problematic combinations
• **Experimental testing** - Test upcoming versions without blocking releases
• **Platform-specific optimizations** - Each OS can have tailored configurations

**Cost vs. Coverage Trade-offs:**

Matrix strategies can dramatically increase CI costs. Here's how teams balance thoroughness with budget:

- **Pull requests**: Test core combinations (Ubuntu + latest Python versions)
- **Main branch**: Full matrix across all platforms and versions
- **Releases**: Full matrix plus additional security and performance testing

======================================
Reusable Workflows & Composite Actions
======================================

**Eliminating Configuration Duplication**

One of the biggest maintenance burdens in multi-repository organizations is keeping CI/CD workflows consistent and up-to-date. Changes to security practices, new compliance requirements, or improved testing strategies need to propagate across dozens or hundreds of repositories.

Reusable workflows solve this by centralizing common automation patterns.

**Reusable Workflow Architecture**

.. code-block:: yaml

    # .github/workflows/reusable-python-ci.yml in your organization's shared repository
    name: Reusable Python CI
    
    on:
      workflow_call:
        inputs:
          python-version:
            required: false
            type: string
            default: "3.12"
          coverage-threshold:
            required: false
            type: number
            default: 80
          run-security-scan:
            required: false
            type: boolean
            default: true
        secrets:
          CODECOV_TOKEN:
            required: false

This reusable workflow can then be called from any repository in your organization:

.. code-block:: yaml

    # Any repository's .github/workflows/ci.yml
    name: CI
    on: [push, pull_request]
    
    jobs:
      ci:
        uses: myorg/shared-workflows/.github/workflows/reusable-python-ci.yml@main
        with:
          python-version: "3.11"
          coverage-threshold: 90
        secrets:
          CODECOV_TOKEN: ${{ secrets.CODECOV_TOKEN }}

**Business Impact:**

• **Consistency**: All repositories follow the same security and quality standards
• **Maintenance**: Update practices in one place, applies everywhere
• **Compliance**: Centralized enforcement of regulatory requirements
• **Onboarding**: New repositories get production-ready CI/CD automatically

**Real-World Example:**

Netflix uses reusable workflows to ensure that all of their microservices follow the same security scanning, testing, and deployment patterns. When they need to add a new compliance requirement, they update the central workflow and it automatically applies to thousands of repositories.

=====================================
Cost Optimization Strategies
=====================================

**CI/CD Costs Add Up Quickly**

GitHub Actions pricing is based on compute minutes. For small teams, this might seem negligible, but enterprise teams can easily spend thousands of dollars monthly on CI/CD. Smart optimization strategies can reduce these costs by 50-80% without sacrificing quality.

**Intelligent Caching Strategies**

*Problem*: Downloading and installing dependencies takes 2-5 minutes of every pipeline run
*Solution*: Cache dependencies that rarely change

.. code-block:: yaml

    - name: Cache Python dependencies
      uses: actions/cache@v4
      with:
        path: |
          ~/.cache/uv
          .venv
        key: ${{ runner.os }}-python-${{ hashFiles('uv.lock') }}
        restore-keys: |
          ${{ runner.os }}-python-

*Impact*: Reduces typical Python setup from 3 minutes to 30 seconds

**Conditional Execution**

*Problem*: Running expensive tests when only documentation changes
*Solution*: Smart path filtering

.. code-block:: yaml

    jobs:
      check-changes:
        outputs:
          code-changed: ${{ steps.changes.outputs.code }}
          docs-changed: ${{ steps.changes.outputs.docs }}
        steps:
          - uses: dorny/paths-filter@v2
            id: changes
            with:
              filters: |
                code:
                  - 'src/**'
                  - 'tests/**'
                docs:
                  - 'docs/**'
                  - '*.md'
      
      expensive-tests:
        needs: check-changes
        if: needs.check-changes.outputs.code-changed == 'true'
        # Only run when actual code changes

*Impact*: Documentation-only changes complete in 1 minute instead of 15 minutes

**Resource Right-Sizing**

*Problem*: Using expensive runners for simple tasks
*Solution*: Match runner size to workload

.. code-block:: yaml

    jobs:
      lint:  # Simple task, basic runner
        runs-on: ubuntu-latest
        
      integration-tests:  # CPU-intensive, larger runner
        runs-on: ubuntu-latest-4-cores
        
      security-scan:  # Memory-intensive, high-memory runner
        runs-on: ubuntu-latest-16-cores

=====================================
Security and Secrets Management
=====================================

**Beyond Basic Secret Storage**

Modern applications require sophisticated secret management that goes far beyond storing API keys in repository settings.

**Environment-Specific Secrets**

Different environments (development, staging, production) require different credentials, configurations, and access levels.

.. code-block:: yaml

    deploy:
      environment: ${{ inputs.environment }}
      steps:
        - name: Deploy to AWS
          run: |
            aws configure set aws_access_key_id ${{ secrets.AWS_ACCESS_KEY_ID }}
            aws configure set aws_secret_access_key ${{ secrets.AWS_SECRET_ACCESS_KEY }}
            deploy.sh ${{ inputs.environment }}

**Supply Chain Security**

Modern applications depend on dozens of external libraries and tools. Supply chain attacks target these dependencies.

.. code-block:: yaml

    security:
      steps:
        # Pin action versions to specific SHAs
        - uses: actions/checkout@8e5e7e5ab8b370d6c329ec480221332ada57f0ab  # v3.5.2
        
        # Verify action signatures
        - name: Verify action integrity
          run: |
            # Use cosign or similar tools to verify action signatures
            cosign verify github.com/actions/checkout@8e5e7e5ab8b370d6c329ec480221332ada57f0ab

**Least Privilege Access**

Grant workflows only the permissions they actually need.

.. code-block:: yaml

    permissions:
      contents: read      # Can read repository contents
      pull-requests: write # Can comment on PRs
      # Explicitly deny all other permissions

========================================
Integration with External Services
========================================

**Beyond GitHub's Ecosystem**

Production systems need to integrate with monitoring services, cloud platforms, notification systems, and deployment tools.

**Notification Strategies**

*Smart notifications* keep teams informed without overwhelming them:

.. code-block:: yaml

    notify:
      if: always()  # Run even if previous jobs fail
      steps:
        - name: Notify on failure
          if: failure()
          uses: 8398a7/action-slack@v3
          with:
            status: failure
            channel: '#critical-alerts'
            
        - name: Notify on success (main branch only)
          if: success() && github.ref == 'refs/heads/main'
          uses: 8398a7/action-slack@v3
          with:
            status: success
            channel: '#deployments'

**Cloud Platform Integration**

Deploy to AWS, Azure, Google Cloud, or other platforms:

.. code-block:: yaml

    deploy-to-aws:
      steps:
        - name: Configure AWS credentials
          uses: aws-actions/configure-aws-credentials@v2
          with:
            role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
            aws-region: us-east-1
            
        - name: Deploy to ECS
          run: |
            aws ecs update-service --cluster production --service myapp --force-new-deployment

=========================
Monitoring and Analytics
=========================

**Making Data-Driven CI/CD Decisions**

Successful teams treat their CI/CD pipelines like production systems - they monitor performance, track costs, and optimize based on data.

**Key Metrics to Track:**

• **Pipeline duration trends**: Are builds getting slower over time?
• **Success rates by repository**: Which projects need attention?
• **Cost per repository**: Where is budget being spent?
• **Developer satisfaction**: Are pipelines helping or hindering productivity?

.. code-block:: yaml

    - name: Record pipeline metrics
      run: |
        curl -X POST ${{ secrets.METRICS_ENDPOINT }} \
          -H "Content-Type: application/json" \
          -d '{
            "repository": "${{ github.repository }}",
            "workflow": "${{ github.workflow }}",
            "duration": "${{ env.PIPELINE_DURATION }}",
            "result": "${{ job.status }}",
            "commit_sha": "${{ github.sha }}"
          }'

=============
Key Takeaways
=============

**Advanced GitHub Actions patterns enable:**

1. **Scale** - Manage hundreds of repositories with consistent practices
2. **Efficiency** - Reduce costs while improving quality and speed
3. **Security** - Implement enterprise-grade security practices
4. **Integration** - Connect with your entire development and deployment ecosystem
5. **Intelligence** - Make data-driven decisions about your automation

**Implementation Strategy:**

Don't try to implement all advanced patterns at once. Start with the biggest pain points:
- If you have multiple similar repositories → Implement reusable workflows
- If CI/CD costs are high → Focus on caching and conditional execution
- If you need cross-platform support → Implement matrix strategies
- If security is a concern → Start with secrets management and supply chain security

**Next Steps:**

The final section will tie together everything you've learned with comprehensive best practices that ensure your CI/CD implementations are production-ready and sustainable.
        secrets:
          CODECOV_TOKEN: ${{ secrets.CODECOV_TOKEN }}

--------------------------------------------------------------
Composite Action (.github/actions/setup-python-env/action.yml)
--------------------------------------------------------------

.. code-block:: yaml

    name: 'Setup Python Environment'
    description: 'Set up Python with uv and install dependencies'
    
    inputs:
      python-version:
        description: 'Python version to use'
        required: false
        default: '3.12'
      cache-key-suffix:
        description: 'Additional cache key suffix'
        required: false
        default: ''
    
    outputs:
      cache-hit:
        description: 'Whether cache was hit'
        value: ${{ steps.cache.outputs.cache-hit }}
    
    runs:
      using: 'composite'
      steps:
        - name: Set up Python
          uses: actions/setup-python@v5
          with:
            python-version: ${{ inputs.python-version }}
        
        - name: Install uv
          uses: astral-sh/setup-uv@v3
          shell: bash
        
        - name: Cache dependencies
          id: cache
          uses: actions/cache@v4
          with:
            path: ~/.cache/uv
            key: uv-${{ runner.os }}-${{ inputs.python-version }}-${{ hashFiles('**/pyproject.toml', '**/uv.lock') }}-${{ inputs.cache-key-suffix }}
            restore-keys: |
              uv-${{ runner.os }}-${{ inputs.python-version }}-
        
        - name: Install dependencies
          shell: bash
          run: uv sync --dev

============================
Cost Optimization Strategies
============================

GitHub Actions pricing can add up quickly in large organizations. Here are proven strategies to reduce costs:

---------------------------
1. Optimal Runner Selection
---------------------------
.. code-block:: yaml

    jobs:
      # Expensive - unnecessarily powerful
      lint:
        runs-on: ubuntu-latest-4-cores  # $0.032/minute
        steps:
          - run: ruff check .  # Takes 10 seconds
      
      # Cost-effective - right-sized
      lint:
        runs-on: ubuntu-latest  # $0.008/minute
        steps:
          - run: ruff check .

----------------------------
2. Conditional Job Execution
----------------------------

.. code-block:: yaml

    jobs:
      changes:
        runs-on: ubuntu-latest
        outputs:
          backend: ${{ steps.filter.outputs.backend }}
          frontend: ${{ steps.filter.outputs.frontend }}
        steps:
          - uses: actions/checkout@v4
          - uses: dorny/paths-filter@v2
            id: filter
            with:
              filters: |
                backend:
                  - 'src/**'
                  - 'tests/**'
                frontend:
                  - 'web/**'
                  - 'package.json'
      
      test-backend:
        needs: changes
        if: needs.changes.outputs.backend == 'true'
        runs-on: ubuntu-latest
        # Only runs when backend files change
      
      test-frontend:
        needs: changes
        if: needs.changes.outputs.frontend == 'true'
        runs-on: ubuntu-latest
        # Only runs when frontend files change

---------------------
3. Aggressive Caching
---------------------

.. code-block:: yaml

    - name: Cache everything possible
      uses: actions/cache@v4
      with:
        path: |
          ~/.cache/uv
          ~/.cache/pip
          ~/.cache/pre-commit
          node_modules
          .pytest_cache
        key: mega-cache-${{ runner.os }}-${{ hashFiles('**/*.lock', '**/*.toml', '**/*.json') }}
        restore-keys: |
          mega-cache-${{ runner.os }}-

-------------------------------------------
4. Self-Hosted Runners for Repetitive Tasks
-------------------------------------------

.. code-block:: yaml

    # For organizations with high CI volume
    jobs:
      test:
        runs-on: [self-hosted, linux, x64]
        # Runs on your own infrastructure
        # Cost: Your server costs only
        # vs GitHub hosted: $0.008/minute

---------------------
Cost Analysis Example
---------------------

.. code-block:: text

    Organization: 50 developers, 500 CI runs/day
    
    Before optimization:
    - 500 runs x 15 minutes x $0.008 = $60/day
    - Monthly cost: ~$1,800
    
    After optimization:
    - Conditional jobs: 50% reduction
    - Better caching: 30% faster builds
    - Right-sized runners: 25% cost reduction
    - Final cost: ~$675/month (62% savings)

=============================
External Service Integrations
=============================

----------------------------------------------
Slack Integration for Deployment Notifications
----------------------------------------------

.. code-block:: yaml

    - name: Notify Slack on deployment
      if: always()  # Run even if previous steps fail
      uses: 8398a7/action-slack@v3
      with:
        status: ${{ job.status }}
        channel: '#deployments'
        webhook_url: ${{ secrets.SLACK_WEBHOOK }}
        fields: repo,message,commit,author,action,eventName,ref,workflow
        custom_payload: |
          {
            "blocks": [
              {
                "type": "section",
                "text": {
                  "type": "mrkdwn", 
                  "text": "🚀 Deployment to production ${{ job.status == 'success' && 'succeeded' || 'failed' }}\n*Repository:* ${{ github.repository }}\n*Branch:* ${{ github.ref_name }}\n*Commit:* <${{ github.event.head_commit.url }}|${{ github.event.head_commit.message }}>\n*Author:* ${{ github.event.head_commit.author.name }}"
                }
              }
            ]
          }

-------------------------------------
Email Notifications with Rich Content
-------------------------------------

.. code-block:: yaml

    - name: Send deployment summary email
      uses: dawidd6/action-send-mail@v3
      if: github.ref == 'refs/heads/main'
      with:
        server_address: smtp.gmail.com
        server_port: 587
        username: ${{ secrets.EMAIL_USERNAME }}
        password: ${{ secrets.EMAIL_PASSWORD }}
        subject: "Production Deployment Successful - ${{ github.repository }}"
        to: devops-team@company.com
        from: GitHub Actions <noreply@company.com>
        html_body: |
          <h2>Deployment Summary</h2>
          <p><strong>Repository:</strong> ${{ github.repository }}</p>
          <p><strong>Branch:</strong> ${{ github.ref_name }}</p>
          <p><strong>Commit:</strong> <a href="${{ github.event.head_commit.url }}">${{ github.event.head_commit.message }}</a></p>
          <p><strong>Author:</strong> ${{ github.event.head_commit.author.name }}</p>
          <p><strong>Deployed at:</strong> ${{ github.event.head_commit.timestamp }}</p>
          
          <h3>Pipeline Results</h3>
          <ul>
            <li>Tests: Passed</li>
            <li>Security Scan: Clean</li>
            <li>Deployment: Successful</li>
          </ul>

----------------------
Multi-Cloud Deployment
----------------------

.. code-block:: yaml

    deploy:
      runs-on: ubuntu-latest
      if: github.ref == 'refs/heads/main'
      strategy:
        matrix:
          cloud:
            - name: aws
              region: us-east-1
            - name: azure
              region: eastus
            - name: gcp
              region: us-central1
      
      steps:
        - uses: actions/checkout@v4
        
        - name: Deploy to ${{ matrix.cloud.name }}
          run: |
            case "${{ matrix.cloud.name }}" in
              "aws")
                aws configure set aws_access_key_id ${{ secrets.AWS_ACCESS_KEY_ID }}
                aws configure set aws_secret_access_key ${{ secrets.AWS_SECRET_ACCESS_KEY }}
                aws ecs update-service --cluster prod --service myapp --force-new-deployment
                ;;
              "azure")
                az login --service-principal -u ${{ secrets.AZURE_CLIENT_ID }} -p ${{ secrets.AZURE_CLIENT_SECRET }} --tenant ${{ secrets.AZURE_TENANT_ID }}
                az container restart --name myapp --resource-group prod
                ;;
              "gcp")
                echo '${{ secrets.GCP_SERVICE_ACCOUNT_KEY }}' | base64 -d > gcp-key.json
                gcloud auth activate-service-account --key-file gcp-key.json
                gcloud run deploy myapp --image gcr.io/project/myapp:latest --region ${{ matrix.cloud.region }}
                ;;
            esac

======================================
Advanced Security & Secrets Management
======================================

-------------------------
Environment-Based Secrets
-------------------------

.. code-block:: yaml

    jobs:
      deploy:
        runs-on: ubuntu-latest
        environment: 
          name: ${{ github.ref_name == 'main' && 'production' || 'staging' }}
          url: ${{ steps.deploy.outputs.url }}
        
        steps:
          - name: Deploy to environment
            id: deploy
            run: |
              # Secrets are automatically scoped to the environment
              echo "Deploying with DATABASE_URL: ${{ secrets.DATABASE_URL }}"
              echo "API_KEY configured: ${{ secrets.API_KEY != '' }}"
              
              # Environment-specific logic
              if [[ "${{ github.ref_name }}" == "main" ]]; then
                DEPLOY_URL="https://myapp.com"
              else
                DEPLOY_URL="https://staging.myapp.com"
              fi
              
              echo "url=$DEPLOY_URL" >> $GITHUB_OUTPUT

====================================
Progress Checkpoint & Best Practices
====================================

-----------------------------
By now you should be able to:
-----------------------------

• Implement matrix strategies for efficient cross-platform testing
• Create reusable workflows and composite actions for code reuse
• Optimize CI/CD costs through smart runner selection and caching
• Integrate with external services for notifications and deployments
• Apply advanced security practices and secret management
• Debug complex workflow issues effectively

--------------------------------------
GitHub Actions Best Practices Summary:
--------------------------------------

1. **Start simple, optimize later**: Begin with basic workflows, add complexity as needed
2. **Cache aggressively**: Every second saved multiplied by thousands of runs
3. **Fail fast**: Put quick checks first to give developers rapid feedback
4. **Use matrix wisely**: Test what matters, skip redundant combinations
5. **Monitor costs**: Set up alerts for unexpected usage spikes
6. **Security first**: Use OIDC, rotate secrets, minimal permissions
7. **Make it observable**: Add logging, timing, and alerts

-----------
Next Steps:
-----------

In the final section, we'll cover best practices for production deployments, team collaboration patterns, and building a sustainable CI/CD culture.

.. note::

    **Practice Challenge**: Take your existing pipeline and apply three optimizations from this section. Measure the before/after performance and cost impact.

    #. Events: Events are triggers that start a workflow, such as a push to the repository, opening a pull request, or scheduling a cron job.

    #. Actions: Actions are individual tasks that make up the workflow, such as checking out code from the repository, building and testing code, or deploying code to a production environment.

A workflow is defined in a YAML file in the .github/workflows directory of a GitHub repository. The structure of a GitHub Actions workflow typically includes:

    #. Name: A unique name for the workflow that identifies it in the GitHub Actions interface.

    #. On: The event that triggers the workflow, such as a push to the repository or opening a pull request.

    #. Jobs: One or more jobs that make up the workflow, each with its own set of steps.

    #. Steps: The individual tasks, or steps, that make up a job. Steps can be individual shell commands or calls to predefined actions from the GitHub Actions marketplace or other sources.

    #. Conditionals: Optional logic that determines whether a step or job should be run, based on conditions such as the success or failure of previous steps or the value of environment variables.

This workflow runs whenever the code is pushed to the main branch of the repository. It consists of one job, "build," that runs on an Ubuntu virtual machine and performs four steps: checking out the code, setting up Node.js, installing dependencies, and building and testing the code.

====================
Workflows vs Actions
====================

A workflow is a configurable automated process made up of one or more jobs. Workflows are defined in YAML files, which are stored in the ``.github/workflows`` directory of a repository.

An action is a reusable unit of code that can be used in a workflow. Actions are the smallest portable building block of a workflow. Actions can be written in JavaScript, TypeScript, or any other language that can be packaged in a Docker container.

A workflow can use actions defined in the same repository, a public repository, or a published Docker container image.

===================
Directory structure 
===================

1. GitHub Actions workflow

    ::

        .github/workflows/
        ├── build.yml
        └── deploy.yml

2. GitHub Actions action

    ::

        .github/actions/actionName
        ├──action.yml
        ├── Dockerfile
        ├── index.js
        └── package.json

===============
Workflow syntax
===============

A workflow is defined in a YAML file in the ``.github/workflows`` directory of a GitHub repository.

The structure of a GitHub Actions workflow typically includes:

    #. **Name**: A unique name for the workflow that identifies it in the GitHub Actions interface.
    #. **On**: The event that triggers the workflow, such as a push to the repository or opening a pull request.
    #. **Jobs**: One or more jobs that make up the workflow, each with its own set of steps.
    #. **Steps**: The individual tasks, or steps, that make up a job. Steps can be individual shell commands or calls to predefined actions from the GitHub Actions marketplace or other sources.
    #. **Conditionals**: Optional logic that determines whether a step or job should be run, based on conditions such as the success or failure of previous steps or the value of environment variables.

.. code-block:: yaml

    name: Python package

    # runs on push and pull request to master (keep in mind that most of the default branches would be blocked for pushing directly to master)
    on:
    push:
        branches: [ "master" ]
    pull_request:
        branches: [ "master" ]

    jobs:
    build:

        runs-on: ubuntu-latest
        strategy:
        fail-fast: false
        matrix:
            python-version: ["3.9", "3.10", "3.11"]

        steps:
        - uses: actions/checkout@v3
    
        - name: Set up Python ${{ matrix.python-version }}
        uses: actions/setup-python@v3
        with:
            python-version: ${{ matrix.python-version }}

        - name: Install dependencies
        run: |
            python -m pip install --upgrade pip
            python -m pip install flake8 pytest
            if [ -f requirements.txt ]; then pip install -r requirements.txt; fi

        - name: Lint with flake8
        run: |
            # stop the build if there are Python syntax errors or undefined names
            flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
            # exit-zero treats all errors as warnings. The GitHub editor is 127 chars wide
            flake8 . --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics

        - name: Test with pytest
        run: |
            pytest

or an workflow that uses the next action as a step:

.. code-block:: yaml

    name: Python application with Action

    on:
    push:
        branches: [ "main" ]
    pull_request:
        branches: [ "main" ]
    workflow_dispatch:

    permissions:
    contents: read

    jobs:
    test_python:
        runs-on: ubuntu-latest
        strategy:
        matrix:
            python-version: ["3.8", "3.9", "3.10", "3.11"]
        steps:
        - uses: actions/checkout@v3
        
        - uses: ./.github/actions/testing
        with:
            python-version:${{ matrix.python-version }}
  

=============
Action syntax
=============

An action is defined in a YAML file in the ``.github/actions/actionName/action.yaml`` directory of a GitHub repository.

The structure of a GitHub Actions action typically includes:

    #. **Name**: A unique name for the action that identifies it in the GitHub Actions interface.
    #. **Inputs**: A list of inputs that can be passed to the action.
    #. **Outputs**: A list of outputs that can be returned from the action.
    #. **Runs**: The runtime environment for the action, such as a Docker container or JavaScript runtime.
    #. **Steps**: The individual tasks, or steps, that make up the action. Steps can be individual shell commands or calls to predefined actions from the GitHub Actions marketplace or other sources.

.. code-block:: yaml

        name: 'Python Test Action'
        description: 'Action to setup, lint, type-check and test a Python application'

        inputs:
        python_version:
            description: 'Python version'
            required: true
            default: '3.11'

        runs:
        using: "composite"
        steps:
            - uses: actions/checkout@v3

            - name: Set up Python 3.10
            uses: actions/setup-python@v2
            with:
                python-version: ${{ inputs.python_version }}

            - name: Install dependencies
            working-directory: source_code/pipelines
            shell: bash
            run: |
                python -m pip install --upgrade pip
                pip install -r requirements.txt
            
            - name: Lint with pylint
            working-directory: source_code/pipelines
            shell: bash
            run: pylint cli/

            - name: Check with mypy
            working-directory: source_code/pipelines
            shell: bash
            run: mypy cli/
            
            - name: Test with pytest
            working-directory: source_code/pipelines
            shell: bash
            run: pytest


==========
Triggering
==========

There are several ways to trigger a workflow run:

    #. **Push**: A workflow can be triggered by a push to the repository. This is the default trigger for a workflow.
    #. **Pull Request**: A workflow can be triggered by a pull request to the repository.
    #. **Schedule**: A workflow can be triggered on a schedule, using cron syntax.
    #. **Webhook**: A workflow can be triggered by a webhook, such as a GitHub App.
    #. **External**: A workflow can be triggered by an external event, such as a Docker image being pushed to a registry.
    #. **On Demand**: A workflow can be triggered manually from the GitHub Actions interface.


==================
Workflow templates
==================

GitHub provides a number of workflow templates that can be used to quickly create a workflow for common tasks, such as building and testing code, deploying code to a production environment, or publishing a Docker image.

Workflow templates can be accessed from the GitHub Actions interface or from the GitHub Actions Marketplace.

==============
Github Secrets
==============

Managing secrets (passwords, tokens, certificates, keys) is a challenging problem in software development. Secrets can be used to grant access to resources, such as databases, APIs, and cloud services, and should be kept secure at all times.

GitHub Actions provides a way to securely store and access secrets, using the GitHub Actions interface or the GitHub API.

.. note::

    In most companies this feature is avoided because most of the time there are requirements to use a third party tool like Hashicorp Vault or Kubernetes Secrets to manage secrets inside of company network.

==============
Github Runners
==============

There are 2 types of workers:
    
    #. **GitHub-hosted runners**: GitHub provides a set of virtual machines that are pre-configured with a variety of software environments. These runners are available to use for free, each account has certain amounts of minutes per month.
    #. **Self-hosted runners**: You can host your own runners on your own machines, using a variety of operating systems and architectures. Self-hosted runners can be used for free, but require more setup and maintenance.

=========================
Modern Workflow Structure
=========================

GitHub Actions workflows follow a hierarchical structure that's easy to understand:

.. code-block:: text

    Workflow (CI/CD Pipeline)
    ├── Event Triggers (push, PR, schedule)
    ├── Job 1 (e.g., test)
    │   ├── Step 1 (checkout code)
    │   ├── Step 2 (setup Python)
    │   └── Step 3 (run tests)
    ├── Job 2 (e.g., build)
    │   └── Steps...
    └── Job 3 (e.g., deploy)
        └── Steps...

**Key Components Explained:**

- **Workflow**: The entire automated process (like a recipe)
- **Jobs**: Groups of steps that run on the same runner (like cooking steps)
- **Steps**: Individual tasks within a job (like individual recipe instructions)
- **Actions**: Reusable code blocks (like pre-made ingredients)

=================================
Advanced Python Workflow Examples
=================================

**1. Multi-Environment Testing with Matrix:**

.. code-block:: yaml

    name: Comprehensive Python Testing
    on: [push, pull_request]

    jobs:
      test:
        runs-on: ${{ matrix.os }}
        strategy:
          fail-fast: false
          matrix:
            os: [ubuntu-latest, windows-latest, macos-latest]
            python-version: ["3.11", "3.12", "3.13"]
            exclude:
              - os: windows-latest
                python-version: "3.12"

        steps:
          - uses: actions/checkout@v4
          
          - name: Set up Python ${{ matrix.python-version }}
            uses: actions/setup-python@v4
            with:
              python-version: ${{ matrix.python-version }}
          
          - name: Install uv
            uses: astral-sh/setup-uv@v3
          
          - name: Run tests
            run: |
              uv sync --dev
              uv run pytest -v

**2. Complete CI/CD Pipeline with Deployment:**

.. code-block:: yaml

    name: Python Package CI/CD
    on:
      push:
        branches: [main]
        tags: ['v*']
      pull_request:
        branches: [main]

    jobs:
      # Quality checks
      quality:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          - uses: astral-sh/setup-uv@v3
          - run: uv sync --dev
          - name: Code quality
            run: |
              uv run ruff check .
              uv run ruff format --check .
              uv run mypy src/
              uv run bandit -r src/

      # Tests
      test:
        runs-on: ubuntu-latest
        strategy:
          matrix:
            python-version: ["3.11", "3.12", "3.13"]
        steps:
          - uses: actions/checkout@v4
          - uses: actions/setup-python@v4
            with:
              python-version: ${{ matrix.python-version }}
          - uses: astral-sh/setup-uv@v3
          - run: uv sync --dev
          - run: uv run pytest --cov --cov-report=xml
          - uses: codecov/codecov-action@v3

      # Build package
      build:
        needs: [quality, test]
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          - uses: astral-sh/setup-uv@v3
          - run: uv build
          - uses: actions/upload-artifact@v4
            with:
              name: packages
              path: dist/

      # Deploy to PyPI (only on tags)
      deploy:
        needs: build
        runs-on: ubuntu-latest
        if: startsWith(github.ref, 'refs/tags/v')
        environment: pypi
        permissions:
          id-token: write  # For trusted publishing
        steps:
          - uses: actions/download-artifact@v4
            with:
              name: packages
              path: dist/
          - uses: pypa/gh-action-pypi-publish@release/v1

**3. Custom Action for Python Setup:**

Create `.github/actions/setup-python-project/action.yml`:

.. code-block:: yaml

    name: 'Setup Python Project'
    description: 'Setup Python with uv and install dependencies'
    
    inputs:
      python-version:
        description: 'Python version'
        required: true
        default: '3.11'
      install-dev:
        description: 'Install dev dependencies'
        required: false
        default: 'true'

    runs:
      using: "composite"
      steps:
        - name: Set up Python ${{ inputs.python-version }}
          uses: actions/setup-python@v4
          with:
            python-version: ${{ inputs.python-version }}
        
        - name: Install uv
          uses: astral-sh/setup-uv@v3
          with:
            enable-cache: true
        
        - name: Install dependencies
          shell: bash
          run: |
            if [ "${{ inputs.install-dev }}" == "true" ]; then
              uv sync --dev
            else
              uv sync
            fi

**Using the custom action:**

.. code-block:: yaml

    name: Using Custom Action
    on: [push, pull_request]

    jobs:
      test:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          - uses: ./.github/actions/setup-python-project
            with:
              python-version: '3.11'
          - run: uv run pytest

=================
Workflow Triggers
=================

GitHub Actions supports various trigger events:

**Common Triggers:**

.. code-block:: yaml

    # Single event
    on: push
    
    # Multiple events
    on: [push, pull_request]
    
    # Detailed configuration
    on:
      push:
        branches: [main, develop]
        paths: ['src/**', 'tests/**']
      pull_request:
        branches: [main]
        types: [opened, synchronize, reopened]
      schedule:
        - cron: '0 2 * * 1'  # Every Monday at 2 AM
      workflow_dispatch:     # Manual trigger
        inputs:
          environment:
            description: 'Environment to deploy'
            required: true
            default: 'staging'
            type: choice
            options: ['staging', 'production']

**Advanced Trigger Examples:**

.. code-block:: yaml

    # Only run on changes to Python files
    on:
      push:
        paths: ['**.py', 'pyproject.toml', 'uv.lock']
    
    # Skip CI on documentation changes
    on:
      push:
        paths-ignore: ['docs/**', '**.md']
    
    # Different workflows for different branches
    on:
      push:
        branches:
          - main      # Production deployment
          - develop   # Staging deployment
          - 'feature/*'  # Feature testing

====================
Secrets and Security
====================

GitHub Actions provides secure ways to handle sensitive information:

**Repository Secrets:**

1. Go to repository Settings → Secrets and variables → Actions
2. Add secrets like `PYPI_TOKEN`, `DATABASE_URL`, etc.

**Using secrets in workflows:**

.. code-block:: yaml

    steps:
      - name: Deploy to PyPI
        env:
          PYPI_TOKEN: ${{ secrets.PYPI_TOKEN }}
        run: |
          uv run twine upload dist/* --username __token__ --password $PYPI_TOKEN
      
      - name: Deploy to staging
        env:
          DATABASE_URL: ${{ secrets.STAGING_DATABASE_URL }}
          API_KEY: ${{ secrets.API_KEY }}
        run: |
          echo "Deploying with secure credentials..."

**Environment-specific secrets:**

.. code-block:: yaml

    jobs:
      deploy:
        runs-on: ubuntu-latest
        environment: production  # Uses production environment secrets
        steps:
          - name: Deploy
            env:
              SECRET_KEY: ${{ secrets.SECRET_KEY }}  # From production environment
            run: echo "Deploying to production"

**Security best practices:**

.. code-block:: yaml

    # Limit permissions
    permissions:
      contents: read
      id-token: write  # For OIDC
    
    # Use trusted publishing for PyPI
    - uses: pypa/gh-action-pypi-publish@release/v1
      # No API token needed with trusted publishing

=====================
Artifacts and Caching
=====================

**Artifacts** store files between jobs:

.. code-block:: yaml

    jobs:
      build:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          - uses: astral-sh/setup-uv@v3
          - run: uv build
          - uses: actions/upload-artifact@v4
            with:
              name: python-package
              path: dist/
              retention-days: 30

      test-package:
        needs: build
        runs-on: ubuntu-latest
        steps:
          - uses: actions/download-artifact@v4
            with:
              name: python-package
              path: dist/
          - run: pip install dist/*.whl && python -c "import mypackage"

**Caching** speeds up workflows:

.. code-block:: yaml

    steps:
      - uses: actions/checkout@v4
      
      # Cache Python dependencies
      - uses: actions/cache@v3
        with:
          path: ~/.cache/uv
          key: ${{ runner.os }}-uv-${{ hashFiles('uv.lock') }}
          restore-keys: ${{ runner.os }}-uv-
      
      # Or use uv's built-in caching
      - uses: astral-sh/setup-uv@v3
        with:
          enable-cache: true
          cache-dependency-glob: "uv.lock"

==============
GitHub Runners
==============

**GitHub-hosted runners** (recommended for most use cases):

- **ubuntu-latest**: Most common, fastest startup
- **windows-latest**: For Windows-specific testing
- **macos-latest**: For macOS testing (slower, more expensive)

.. code-block:: yaml

    jobs:
      test:
        runs-on: ubuntu-latest  # Free tier: 2,000 minutes/month
        # runs-on: windows-latest  # Free tier: 2,000 minutes/month  
        # runs-on: macos-latest     # Free tier: 500 minutes/month

**Self-hosted runners** (for special requirements):

.. code-block:: yaml

    jobs:
      test:
        runs-on: [self-hosted, linux, x64, gpu]  # Custom labels
        steps:
          - uses: actions/checkout@v4
          - run: nvidia-smi  # Use GPU for ML workloads

**When to use self-hosted runners:**

- Need specific hardware (GPUs, large memory)
- Require access to internal networks
- Want faster builds with persistent caching
- Have compliance requirements

=================
Advanced Features
=================

**Conditional execution:**

.. code-block:: yaml

    steps:
      - name: Deploy to production
        if: github.ref == 'refs/heads/main' && github.event_name == 'push'
        run: echo "Deploying to production"
      
      - name: Run only on Python changes
        if: contains(github.event.head_commit.modified, '.py')
        run: echo "Python files changed"

**Dynamic matrix from file:**

.. code-block:: yaml

    jobs:
      setup:
        runs-on: ubuntu-latest
        outputs:
          matrix: ${{ steps.set-matrix.outputs.matrix }}
        steps:
          - uses: actions/checkout@v4
          - id: set-matrix
            run: echo "matrix=$(cat .github/test-matrix.json)" >> $GITHUB_OUTPUT
      
      test:
        needs: setup
        strategy:
          matrix: ${{ fromJson(needs.setup.outputs.matrix) }}

**Reusable workflows:**

.. code-block:: yaml

    # .github/workflows/reusable-python-ci.yml
    name: Reusable Python CI
    on:
      workflow_call:
        inputs:
          python-version:
            required: true
            type: string

    jobs:
      test:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          - uses: actions/setup-python@v4
            with:
              python-version: ${{ inputs.python-version }}

    # .github/workflows/main.yml
    jobs:
      call-reusable:
        uses: ./.github/workflows/reusable-python-ci.yml
        with:
          python-version: '3.11'

==============
Best Practices
==============

1. **Use specific action versions**: `uses: actions/checkout@v4` not `@main`
2. **Pin Python versions**: Test against specific versions you support
3. **Cache dependencies**: Use `uv` caching or `actions/cache`
4. **Fail fast**: Use `fail-fast: false` in matrix when debugging
5. **Secure secrets**: Use environments for sensitive deployments
6. **Monitor usage**: Track Action minutes usage in billing settings
7. **Use job dependencies**: `needs:` to control execution order
8. **Meaningful names**: Clear job and step names for easier debugging

.. note::
  
    **Debugging workflows:**
    
    - Use `workflow_dispatch` for manual testing
    - Add `run: env` step to see all environment variables
    - Use `actions/upload-artifact` to inspect generated files
    - Enable debug logging with `ACTIONS_STEP_DEBUG: true`

====================================
Integration with Modern Python Tools
====================================

GitHub Actions works excellently with the modern Python ecosystem:

.. code-block:: yaml

    name: Modern Python Stack
    on: [push, pull_request]

    jobs:
      ci:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          
          # Modern package management
          - uses: astral-sh/setup-uv@v3
            with:
              enable-cache: true
          
          # Install and run modern tools
          - run: |
              uv sync --dev
              uv run ruff check .           # Linting
              uv run ruff format --check .  # Formatting
              uv run mypy .                 # Type checking
              uv run bandit -r src/         # Security
              uv run pytest --cov           # Testing
              uv build                      # Building

This modern approach is faster, more reliable, and easier to maintain than traditional Python CI setups!

########################
7.4 CI/CD Best Practices
########################

=============================
Fast Feedback & Error Clarity
=============================

**Optimal Job Ordering:**

.. code-block:: yaml

    # Fast validation first (1-2 min)
    - name: Lint & format check
      run: |
        uv run ruff check .
        uv run ruff format --check .
        
    # Core tests next (3-5 min) 
    - name: Unit tests
      run: uv run pytest tests/unit/ -v --tb=short
      
    # Expensive tests last (10+ min)
    - name: Integration tests  
      run: uv run pytest tests/integration/

================================
Security Integration (DevSecOps)
================================

**Essential Security Checks:**

.. code-block:: yaml

    security:
      steps:
        - uses: actions/checkout@v4
        
        # Vulnerability scanning
        - name: Scan dependencies
          run: |
            uv run safety check
            uv run pip-audit
        
        # Static security analysis  
        - name: Security linting
          run: uv run bandit -r src/ -f json -o security.json
        
        # Secret detection
        - name: Scan for secrets
          uses: trufflesecurity/trufflehog@main
          with:
            path: ./
            base: main
            head: HEAD
          with:
            path: ./
            base: main
            head: HEAD

*Business value:* Finding security issues in development costs $100. Finding them in production costs $10,000+.

**4. Make Pipelines Observable**

*What you can't measure, you can't improve.* Successful teams track pipeline metrics as carefully as application metrics.

*Key metrics to monitor:*

.. code-block:: yaml

    - name: Record pipeline metrics
      run: |
        echo "PIPELINE_START_TIME=$(date +%s)" >> $GITHUB_ENV
        echo "COMMIT_SHA=${GITHUB_SHA}" >> $GITHUB_ENV
        echo "BUILD_NUMBER=${GITHUB_RUN_NUMBER}" >> $GITHUB_ENV
    
    # At the end of your pipeline
    - name: Report pipeline success
      if: success()
      run: |
        DURATION=$(($(date +%s) - $PIPELINE_START_TIME))
        curl -X POST "$METRICS_ENDPOINT" \
          -d "pipeline_duration_seconds=$DURATION" \
          -d "pipeline_result=success" \
          -d "commit_sha=$COMMIT_SHA"

*Metrics that matter:*

- **Pipeline duration:** How long builds take (optimize the slowest stages first)
- **Success rate:** What percentage of builds pass (target >95%)
- **Flaky test rate:** Tests that sometimes fail (fix these immediately)
- **Queue time:** How long builds wait to start (indicates resource constraints)

.. code-block:: yaml

        steps:
          - run: uv run pytest

**3. Make Pipelines Self-Contained**

- Each pipeline run should be completely independent
- Don't rely on previous build artifacts
- Use fresh environments for each run

==============================
Python-Specific Best Practices
==============================

**Modern Dependency Management:**

.. code-block:: yaml

    - uses: astral-sh/setup-uv@v3
      with:
        enable-cache: true
        cache-dependency-glob: "uv.lock"
    - run: uv sync --dev

**Multi-Version Testing:**

.. code-block:: yaml

    strategy:
      matrix:
        python-version: ["3.11", "3.12", "3.13"]
        exclude:
          - python-version: "3.12"
            os: windows-latest

**Quality Gates:**

.. code-block:: yaml

    - name: Quality checks
      run: |
        uv run ruff check .           # Linting
        uv run ruff format --check .  # Formatting  
        uv run mypy src/              # Type checking
        uv run bandit -r src/         # Security

=======================
Security Best Practices  
=======================

**Secret Management:**

.. code-block:: yaml

    - name: Deploy to production
      env:
        API_KEY: ${{ secrets.PRODUCTION_API_KEY }}
      run: deploy.sh

**Dependency Security:**

.. code-block:: yaml

    - name: Security audit
      run: |
        uv run bandit -r src/
        uv run safety check
        uv run pip-audit

**Container Security:**

.. code-block:: dockerfile

    FROM python:3.12-slim
    RUN adduser --disabled-password --gecos '' appuser
    USER appuser  # Don't run as root
    COPY --chown=appuser:appuser . /app

======================
Testing Best Practices
======================

**Test Pyramid Structure:**

.. code-block:: yaml

    # Fast unit tests (70% of tests)
    - name: Unit tests
      run: uv run pytest tests/unit/ --maxfail=1
      
    # Medium integration tests (20% of tests)  
    - name: Integration tests
      run: uv run pytest tests/integration/ -v
      
    # Slow E2E tests (10% of tests)
    - name: End-to-end tests
      run: uv run pytest tests/e2e/ --timeout=300

.. code-block:: yaml

    # Good: Layered testing approach
    - name: Unit tests
      run: uv run pytest tests/unit/ -v
    
    - name: Integration tests
      run: uv run pytest tests/integration/ -v
    
    - name: E2E tests
      if: github.ref == 'refs/heads/main'
      run: uv run pytest tests/e2e/ -v

**Test Coverage:**

.. code-block:: yaml

    - name: Test with coverage
      run: |
        uv run pytest --cov=src --cov-report=xml --cov-fail-under=80
        uv run coverage report

======================
Environment Management
======================

**Container-Based Consistency:**

.. code-block:: yaml

    jobs:
      test:
        runs-on: ubuntu-latest
        container:
          image: python:3.12-slim  # Match production
          env:
            DATABASE_URL: postgresql://test:test@postgres:5432/testdb
        
        services:
          postgres:
            image: postgres:15  # Same as production
            env:
              POSTGRES_PASSWORD: test
              POSTGRES_DB: testdb

**Environment Promotion:**

.. code-block:: yaml

    deploy:
      strategy:
        matrix:
          environment: [staging, production]
          include:
            - environment: staging
              url: https://staging.myapp.com
              requires_approval: false
            - environment: production  
              url: https://myapp.com
              requires_approval: true

=========================
Deployment Best Practices
=========================

**Environment Strategy:**

.. code-block:: yaml

    deploy-staging:
      if: github.ref == 'refs/heads/develop'
      environment: staging
      steps:
        - name: Deploy to staging
          run: kubectl apply -f k8s/staging/
      
    deploy-production:
      if: startsWith(github.ref, 'refs/tags/v')
      environment: production
      needs: [test, security-scan]

**2. Blue-Green and Canary Deployments**

- Minimize downtime with blue-green deployments
- Reduce risk with canary releases
- Always have a rollback plan

**3. Database Migration Safety**

- Make migrations backward-compatible
- Test migrations on production-like data
- Have rollback procedures for schema changes

============================
Monitoring and Observability
============================

**1. Pipeline Monitoring**

- Track pipeline success rates
- Monitor pipeline duration trends
- Alert on failures

.. code-block:: yaml

    # Good: Failure notifications
    - name: Notify on failure
      if: failure()
      uses: actions/slack@v1
      with:
        webhook: ${{ secrets.SLACK_WEBHOOK }}
        message: "Pipeline failed on ${{ github.ref }}"

**2. Key Metrics to Track**

- **Lead Time**: Code commit to production
- **Deployment Frequency**: How often you deploy
- **Mean Time to Recovery**: How quickly you fix issues
- **Change Failure Rate**: Percentage of deployments causing issues

=====================
Workflow Organization
=====================

**1. Branching Strategy Alignment**

.. code-block:: yaml

    # Good: Strategy-aligned triggers
    on:
      push:
        branches: [main]        # Production deployments
      pull_request:
        branches: [main]        # PR validation
      push:
        branches: [develop]     # Staging deployments

**2. Job Dependencies and Parallelization**

.. code-block:: yaml

    # Good: Optimal job organization
    jobs:
      # Fast parallel checks
      lint:
        runs-on: ubuntu-latest
      test:
        runs-on: ubuntu-latest
      security:
        runs-on: ubuntu-latest
      
      # Build only after checks pass
      build:
        needs: [lint, test, security]
        runs-on: ubuntu-latest
      
      # Deploy only after build succeeds
      deploy:
        needs: build
        if: github.ref == 'refs/heads/main'
        runs-on: ubuntu-latest

=================
Cost Optimization
=================

**1. Runner Selection**

- Use ubuntu-latest for most jobs (cheapest)
- Use macOS/Windows only when necessary
- Consider self-hosted runners for heavy workloads

**2. Cache Strategy**

.. code-block:: yaml

    # Good: Effective caching
    - uses: actions/cache@v3
      with:
        path: ~/.cache/uv
        key: ${{ runner.os }}-uv-${{ hashFiles('uv.lock') }}
        restore-keys: ${{ runner.os }}-uv-

**3. Conditional Execution**

.. code-block:: yaml

    # Good: Skip unnecessary work
    - name: Deploy docs
      if: contains(github.event.head_commit.modified, 'docs/')
      run: deploy-docs.sh

========================
Performance Optimization
========================

**Advanced Caching Patterns:**

.. code-block:: yaml

    - name: Cache dependencies
      uses: actions/cache@v4
      with:
        path: |
          ~/.cache/uv
          .venv
        key: ${{ runner.os }}-uv-${{ hashFiles('uv.lock') }}
        restore-keys: |
          ${{ runner.os }}-uv-

**Conditional Execution:**

.. code-block:: yaml

    check-changes:
      outputs:
        backend-changed: ${{ steps.changes.outputs.backend }}
      steps:
        - uses: dorny/paths-filter@v2
          id: changes
          with:
            filters: |
              backend: ['src/**', 'requirements.txt']
              frontend: ['frontend/**', 'package.json']
    
    test-backend:
      needs: check-changes
      if: needs.check-changes.outputs.backend-changed == 'true'
      run: uv run pytest tests/

**Resource Right-Sizing:**

.. code-block:: yaml

    lint:  
      runs-on: ubuntu-latest      # Basic tasks
      
    integration-tests:  
      runs-on: ubuntu-latest-4-cores  # CPU intensive

===================
Pipeline Monitoring
===================

**Metrics Collection:**

.. code-block:: yaml

    - name: Record metrics
      run: |
        echo "START_TIME=$(date +%s)" >> $GITHUB_ENV
        curl -X POST "$METRICS_ENDPOINT" \
          -d "pipeline_start=$(date +%s)" \
          -d "repo=${{ github.repository }}"
    
    - name: Report completion
      if: always()
      run: |
        DURATION=$(($(date +%s) - $START_TIME))
        curl -X POST "$METRICS_ENDPOINT" \
          -d "duration=$DURATION" \
          -d "status=${{ job.status }}"

**Key Metrics:**
- Lead Time: Commit → production
- Deploy Frequency: Daily deployments
- Change Failure Rate: <5% rollbacks
- MTTR: <1 hour recovery

**Failure Alerts:**

.. code-block:: yaml

    - name: Failure notification
      if: failure()
      uses: 8398a7/action-slack@v3
      with:
        status: failure
        channel: '#dev-alerts'
        message: |
          🚨 Pipeline failed: ${{ github.repository }}
          
          📊 **Failure Context:**
          - **Commit**: ${{ github.sha }} by ${{ github.actor }}
          - **Branch**: ${{ github.ref_name }}
          - **Failed Job**: ${{ github.job }}
          - **Failure Rate**: Check if this is a pattern or one-off
          
          🔗 **Quick Actions:**
          - [View Logs](${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }})
          - [Compare Changes](${{ github.event.compare }})
          - [Rollback Procedure](https://wiki.company.com/rollback)

**Pipeline Health Dashboards**

*Essential Dashboard Widgets:*

- Pipeline success rate by repository (rolling 7 days)
- Average build duration trends
- Most frequent failure causes and remediation times  
- Developer productivity metrics (PRs merged per developer per week)
- Infrastructure costs by repository and team

*Implementation using GitHub APIs:*

.. code-block:: python

    # Pipeline metrics collection script
    import requests
    from datetime import datetime, timedelta

    def collect_pipeline_metrics(repo, token):
        """Collect pipeline metrics for dashboard."""
        headers = {'Authorization': f'token {token}'}
        url = f"https://api.github.com/repos/{repo}/actions/runs"
        
        # Get last 100 workflow runs
        response = requests.get(url, headers=headers, params={'per_page': 100})
        runs = response.json()['workflow_runs']
        
        # Calculate metrics
        total_runs = len(runs)
        successful_runs = len([r for r in runs if r['conclusion'] == 'success'])
        success_rate = (successful_runs / total_runs) * 100
        
        # Average duration for successful runs
        durations = [
            (datetime.fromisoformat(r['updated_at'].replace('Z', '+00:00')) - 
             datetime.fromisoformat(r['created_at'].replace('Z', '+00:00'))).total_seconds()
            for r in runs if r['conclusion'] == 'success'
        ]
        avg_duration = sum(durations) / len(durations) if durations else 0
        
        return {
            'success_rate': success_rate,
            'average_duration_minutes': avg_duration / 60,
            'total_runs': total_runs
        }

===================================
Infrastructure Pipeline Integration
===================================

**Treating Infrastructure as Code in Pipelines**

Modern applications don't deploy in isolation - they require databases, load balancers, monitoring systems, and cloud resources. Production-ready pipelines automate infrastructure changes alongside application deployments.

**Infrastructure-Aware Deployment Patterns**

*Terraform Integration Example:*

.. code-block:: yaml

    # Infrastructure deployment as part of application pipeline
    deploy-infrastructure:
      runs-on: ubuntu-latest
      environment: production
      steps:
        - uses: actions/checkout@v4
        
        - name: Setup Terraform
          uses: hashicorp/setup-terraform@v3
          with:
            terraform_version: 1.6.0
        
        - name: Terraform Plan
          working-directory: ./infrastructure
          env:
            TF_VAR_app_version: ${{ github.sha }}
          run: |
            terraform init
            terraform plan -out=tfplan
        
        - name: Terraform Apply
          if: github.ref == 'refs/heads/main'
          working-directory: ./infrastructure
          run: terraform apply -auto-approve tfplan
        
        - name: Output infrastructure details
          run: |
            echo "DATABASE_URL=$(terraform output -raw database_url)" >> $GITHUB_ENV
            echo "API_ENDPOINT=$(terraform output -raw api_endpoint)" >> $GITHUB_ENV

*Database Migration Integration:*

.. code-block:: yaml

    # Safe database migrations in pipelines
    database-migration:
      runs-on: ubuntu-latest
      environment: production
      steps:
        - uses: actions/checkout@v4
        
        # Always backup before migrations
        - name: Create database backup
          run: |
            pg_dump $DATABASE_URL > backup-$(date +%Y%m%d-%H%M%S).sql
            aws s3 cp backup-*.sql s3://backups-bucket/
        
        # Run migrations with rollback capability
        - name: Run database migrations
          run: |
            # Run migrations
            uv run python manage.py migrate
            
            # Verify migration success
            if uv run python manage.py showmigrations --plan | grep -q "UNAPPLIED"; then
              echo " Migrations failed - rolling back"
              uv run python manage.py migrate --fake-initial
              exit 1
            fi
            
            echo " Database migrations completed successfully"

**Container Orchestration Integration**

*Kubernetes Deployment with Health Checks:*

.. code-block:: yaml

    deploy-kubernetes:
      runs-on: ubuntu-latest
      environment: production
      steps:
        - uses: actions/checkout@v4
        
        - name: Configure kubectl
          uses: azure/k8s-set-context@v3
          with:
            kubeconfig: ${{ secrets.KUBE_CONFIG }}
        
        - name: Deploy to Kubernetes
          run: |
            # Apply configuration changes
            kubectl apply -f k8s/
            
            # Update deployment with new image
            kubectl set image deployment/myapp \
              myapp=myregistry/myapp:${{ github.sha }}
            
            # Wait for rollout to complete
            kubectl rollout status deployment/myapp --timeout=300s
        
        - name: Verify deployment health
          run: |
            # Check pod status
            kubectl get pods -l app=myapp
            
            # Verify health check endpoints
            API_URL=$(kubectl get service myapp -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
            curl -f http://$API_URL/health || exit 1
            
            echo " Deployment successful and healthy"

**Multi-Environment Infrastructure Management**

*Environment-Specific Infrastructure Patterns:*

.. code-block:: yaml

    # Environment promotion with infrastructure validation
    deploy:
      strategy:
        matrix:
          environment: [staging, production]
          include:
            - environment: staging
              tf_workspace: staging
              cluster_name: staging-cluster
              requires_approval: false
            - environment: production
              tf_workspace: production  
              cluster_name: prod-cluster
              requires_approval: true
              
      environment: ${{ matrix.environment }}
      runs-on: ubuntu-latest
      
      steps:
        # Infrastructure provisioning
        - name: Deploy infrastructure
          working-directory: ./terraform
          env:
            TF_WORKSPACE: ${{ matrix.tf_workspace }}
          run: |
            terraform init
            terraform plan -var="environment=${{ matrix.environment }}"
            terraform apply -auto-approve
        
        # Application deployment to infrastructure
        - name: Deploy application
          env:
            CLUSTER_NAME: ${{ matrix.cluster_name }}
          run: |
            aws eks update-kubeconfig --name $CLUSTER_NAME
            helm upgrade --install myapp ./helm-chart \
              --set image.tag=${{ github.sha }} \
              --set environment=${{ matrix.environment }}

==============================
Disaster Recovery & Compliance
==============================

**Pipeline Resilience Patterns**

Production pipelines must handle failures gracefully and provide audit trails for compliance requirements.

**Automated Rollback Strategies**

.. code-block:: yaml

    # Automated rollback on deployment failure
    deploy-with-rollback:
      runs-on: ubuntu-latest
      environment: production
      steps:
        - name: Record current version
          run: |
            CURRENT_VERSION=$(kubectl get deployment myapp -o jsonpath='{.spec.template.spec.containers[0].image}')
            echo "PREVIOUS_VERSION=$CURRENT_VERSION" >> $GITHUB_ENV
        
        - name: Deploy new version
          id: deploy
          run: |
            kubectl set image deployment/myapp myapp=myregistry/myapp:${{ github.sha }}
            kubectl rollout status deployment/myapp --timeout=300s
        
        - name: Health check post-deployment
          id: health_check
          run: |
            sleep 30  # Allow time for startup
            curl -f $API_ENDPOINT/health || exit 1
            
            # Check error rates in monitoring
            ERROR_RATE=$(curl -s "$METRICS_API/error_rate?minutes=5")
            if (( $(echo "$ERROR_RATE > 0.05" | bc -l) )); then
              echo " Error rate too high: $ERROR_RATE"
              exit 1
            fi
        
        - name: Automatic rollback on failure
          if: failure() && (steps.deploy.outcome == 'success' || steps.health_check.outcome == 'failure')
          run: |
            echo " Initiating automatic rollback to $PREVIOUS_VERSION"
            kubectl set image deployment/myapp myapp=$PREVIOUS_VERSION
            kubectl rollout status deployment/myapp --timeout=300s
            
            # Notify team of rollback
            curl -X POST $SLACK_WEBHOOK \
              -d "payload={'text': '🚨 Auto-rollback triggered for ${{ github.repository }}. Previous version restored.'}"

**Compliance and Audit Patterns**

*SOX/SOC2 Compliance Example:*

.. code-block:: yaml

    # Compliance-focused deployment with audit trail
    compliance-deployment:
      runs-on: ubuntu-latest
      environment: production
      steps:
        # Approval gate for production changes
        - name: Wait for deployment approval
          uses: trstringer/manual-approval@v1
          with:
            secret: ${{ secrets.GITHUB_TOKEN }}
            approvers: user1,user2,user3
            minimum-approvals: 2
            issue-title: "Production Deployment: ${{ github.ref_name }}"
        
        # Create audit record
        - name: Log deployment attempt
          run: |
            curl -X POST "$AUDIT_API/deployments" \
              -H "Authorization: Bearer ${{ secrets.AUDIT_TOKEN }}" \
              -d '{
                "timestamp": "'$(date -Iseconds)'",
                "repository": "${{ github.repository }}",
                "commit_sha": "${{ github.sha }}",
                "deployer": "${{ github.actor }}",
                "environment": "production",
                "status": "initiated"
              }'
        
        # Deployment with security validation
        - name: Security scan before deployment
          run: |
            # Container image security scan
            trivy image myregistry/myapp:${{ github.sha }} \
              --severity HIGH,CRITICAL \
              --exit-code 1
            
            # Dependency vulnerability check
            uv run safety check --audit-and-monitor
        
        - name: Deploy with verification
          run: |
            # Deploy with gradual rollout
            kubectl patch deployment myapp -p '{
              "spec": {
                "strategy": {
                  "rollingUpdate": {
                    "maxUnavailable": 1,
                    "maxSurge": 1
                  }
                },
                "template": {
                  "spec": {
                    "containers": [{
                      "name": "myapp",
                      "image": "myregistry/myapp:${{ github.sha }}"
                    }]
                  }
                }
              }
            }'
        
        # Record successful deployment
        - name: Log deployment success
          if: success()
          run: |
            curl -X POST "$AUDIT_API/deployments" \
              -H "Authorization: Bearer ${{ secrets.AUDIT_TOKEN }}" \
              -d '{
                "timestamp": "'$(date -Iseconds)'",
                "commit_sha": "${{ github.sha }}",
                "status": "completed",
                "deployment_id": "'$GITHUB_RUN_ID'"
              }'



- Optimize pipeline speed with caching
- Set up monitoring and alerts
- Document troubleshooting procedures
- Train team on CI/CD best practices

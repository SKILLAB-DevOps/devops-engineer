#####################
8.7 Container Testing
#####################

.. image:: ../diagrams/testing_pyramid.png
  :alt: A comprehensive diagram showing different layers of container testing from unit tests to production validation
  :width: 800 px

**Beyond "It Works on My Machine"**

Testing containers requires a different mindset than traditional application testing. You're not just testing your code - you're testing the entire packaged environment, its configuration, security posture, and behavior under various conditions. This section covers comprehensive testing strategies that ensure your containers work reliably from development to production.

Modern container testing spans multiple dimensions: functional correctness, security compliance, performance characteristics, and operational behavior.

===================
Learning Objectives
===================

By the end of this section, you will:

• **Design** comprehensive container testing strategies
• **Implement** automated security and vulnerability testing
• **Create** performance and load testing for containerized applications
• **Validate** container configurations and infrastructure
• **Build** testing pipelines that catch issues before production
• **Monitor** container behavior in production environments

**Prerequisites:** Understanding of containers, Docker/Podman, testing concepts, and CI/CD basics

=========================
Container Testing Pyramid
=========================

**Multi-Layer Testing Strategy**

Container testing follows a pyramid model with different types of tests at each level:

.. code-block:: text

    ┌─────────────────────────────┐
    │     Production Monitoring   │  ← Observability, alerting
    ├─────────────────────────────┤
    │     Integration Tests       │  ← Multi-container, end-to-end
    ├─────────────────────────────┤
    │     Container Tests         │  ← Image structure, security
    ├─────────────────────────────┤
    │     Unit Tests              │  ← Application logic
    └─────────────────────────────┘

**Testing Categories:**

1. **Unit Tests:** Test application logic in isolation
2. **Container Tests:** Validate image structure, security, and configuration
3. **Integration Tests:** Test multi-container applications and external dependencies
4. **Performance Tests:** Validate resource usage and scalability
5. **Security Tests:** Scan for vulnerabilities and compliance
6. **Production Monitoring:** Continuous validation in live environments

==========================
Unit Testing in Containers
==========================

**Testing Application Logic**

**1. Test-Driven Development with Containers**

.. code-block:: dockerfile

    # Multi-stage Dockerfile with testing
    FROM python:3.11-slim AS base
    WORKDIR /app
    COPY requirements.txt .
    RUN pip install -r requirements.txt
    
    # Test stage
    FROM base AS test
    COPY requirements-test.txt .
    RUN pip install -r requirements-test.txt
    COPY . .
    RUN pytest --cov=app --cov-report=xml --cov-report=term
    CMD ["pytest", "-v"]
    
    # Production stage
    FROM base AS production
    COPY . .
    CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app:app"]

**2. Running Tests in Containers**

.. code-block:: bash

    # Build and run tests
    docker build --target test -t myapp:test .
    docker run --rm myapp:test
    
    # Run tests with volume mount for development
    docker run --rm \
      -v $(pwd):/app \
      -w /app \
      python:3.11-slim \
      sh -c "pip install -r requirements-test.txt && pytest -v"
    
    # Generate test coverage reports
    docker run --rm \
      -v $(pwd):/app \
      -w /app \
      python:3.11-slim \
      sh -c "pip install -r requirements-test.txt && pytest --cov=app --cov-report=html"

**3. Database Testing with Test Containers**

.. code-block:: python

    # Python example using pytest and docker
    import pytest
    import docker
    import psycopg2
    import time
    
    @pytest.fixture(scope="session")
    def postgres_container():
        client = docker.from_env()
        
        # Start test database
        container = client.containers.run(
            "postgres:15-alpine",
            environment={
                "POSTGRES_DB": "testdb",
                "POSTGRES_USER": "testuser",
                "POSTGRES_PASSWORD": "testpass"
            },
            ports={"5432/tcp": None},  # Random port
            detach=True,
            remove=True
        )
        
        # Wait for database to be ready
        for _ in range(30):
            try:
                port = container.attrs["NetworkSettings"]["Ports"]["5432/tcp"][0]["HostPort"]
                conn = psycopg2.connect(
                    host="localhost",
                    port=port,
                    database="testdb",
                    user="testuser",
                    password="testpass"
                )
                conn.close()
                break
            except:
                time.sleep(1)
        
        yield f"postgresql://testuser:testpass@localhost:{port}/testdb"
        
        container.stop()
    
    def test_database_operations(postgres_container):
        # Your database tests here
        pass

===========================
Container Structure Testing
===========================

**Validating Image Configuration**

**1. Dockerfile Linting with hadolint**

.. code-block:: bash

    # Install hadolint
    docker pull hadolint/hadolint
    
    # Lint Dockerfile
    docker run --rm -i hadolint/hadolint < Dockerfile
    
    # Create hadolint configuration
    cat > .hadolint.yaml << EOF
    ignored:
      - DL3008  # Pin versions in apt get install
      - DL3009  # Delete the apt-get lists after installing something
    failure-threshold: error
    EOF
    
    # Run with configuration
    docker run --rm -i -v $(pwd)/.hadolint.yaml:/.config/hadolint.yaml \
      hadolint/hadolint < Dockerfile

**2. Image Layer Analysis with dive**

.. code-block:: bash

    # Install dive
    docker pull wagoodman/dive
    
    # Analyze image layers
    docker run --rm -it \
      -v /var/run/docker.sock:/var/run/docker.sock \
      wagoodman/dive:latest myapp:latest

**3. Container Structure Tests**

.. code-block:: yaml

    # container-structure-test.yaml
    schemaVersion: '2.0.0'
    
    commandTests:
      - name: "Python version check"
        command: "python"
        args: ["--version"]
        expectedOutput: ["Python 3.11.*"]
    
    fileExistenceTests:
      - name: "Application file exists"
        path: "/app/main.py"
        shouldExist: true
      - name: "No sensitive files"
        path: "/etc/passwd"
        shouldExist: false
    
    fileContentTests:
      - name: "Check user configuration"
        path: "/etc/passwd"
        expectedContents: ["appuser:x:1001:1001::/app:/bin/false"]
    
    metadataTest:
      exposedPorts: ["8080"]
      user: "1001"
      workdir: "/app"

.. code-block:: bash

    # Run structure tests
    docker run --rm \
      -v $(pwd)/container-structure-test.yaml:/tests.yaml \
      -v /var/run/docker.sock:/var/run/docker.sock \
      gcr.io/gcp-runtimes/container-structure-test:latest \
      test --image myapp:latest --config /tests.yaml

**4. Security Configuration Testing**

.. code-block:: python

    # Python script for security testing
    import docker
    import json
    
    def test_container_security(image_name):
        client = docker.from_env()
        image = client.images.get(image_name)
        
        # Check image configuration
        config = image.attrs['Config']
        
        # Test: Container should not run as root
        user = config.get('User', '')
        assert user != '' and user != 'root', "Container should not run as root"
        
        # Test: No exposed privileged ports
        exposed_ports = config.get('ExposedPorts', {})
        privileged_ports = [p for p in exposed_ports.keys() if int(p.split('/')[0]) < 1024]
        assert len(privileged_ports) == 0, f"Exposed privileged ports: {privileged_ports}"
        
        # Test: Health check should be defined
        healthcheck = config.get('Healthcheck')
        assert healthcheck is not None, "Health check should be defined"
        
        print("✅ Security tests passed")
    
    if __name__ == "__main__":
        test_container_security("myapp:latest")

================
Security Testing
================

**Comprehensive Vulnerability Assessment**

**1. Vulnerability Scanning with Trivy**

.. code-block:: bash

    # Basic vulnerability scan
    trivy image myapp:latest
    
    # Scan with specific severity
    trivy image --severity HIGH,CRITICAL myapp:latest
    
    # Output to JSON for processing
    trivy image --format json --output results.json myapp:latest
    
    # Scan filesystem (for local development)
    trivy fs --security-checks vuln,config .
    
    # Continuous scanning in CI/CD
    trivy image --exit-code 1 --severity CRITICAL myapp:latest

**2. Configuration Scanning**

.. code-block:: bash

    # Scan for misconfigurations
    trivy config .
    
    # Scan Kubernetes manifests
    trivy config --file-patterns "*.yaml" k8s-manifests/
    
    # Custom policy with OPA Rego
    trivy config --policy ./policies/ .

**3. Secret Detection**

.. code-block:: bash

    # Scan for secrets in image
    trivy image --scanners secret myapp:latest
    
    # Scan codebase for secrets
    docker run --rm -v $(pwd):/workspace \
      trufflesecurity/trufflehog:latest \
      filesystem /workspace

**4. Automated Security Testing Pipeline**

.. code-block:: yaml

    # .github/workflows/security.yml
    name: Security Testing
    on: [push, pull_request]
    
    jobs:
      security-scan:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v3
          
          - name: Build image
            run: docker build -t ${{ github.repository }}:${{ github.sha }} .
          
          - name: Run Trivy vulnerability scanner
            uses: aquasecurity/trivy-action@master
            with:
              image-ref: ${{ github.repository }}:${{ github.sha }}
              format: 'sarif'
              output: 'trivy-results.sarif'
          
          - name: Upload Trivy scan results
            uses: github/codeql-action/upload-sarif@v2
            with:
              sarif_file: 'trivy-results.sarif'
          
          - name: Secret detection
            uses: trufflesecurity/trufflehog@main
            with:
              path: ./
              base: main
              head: HEAD

===================
Integration Testing
===================

**Testing Multi-Container Applications**

**1. Docker Compose Testing**

.. code-block:: yaml

    # docker-compose.test.yml
    version: '3.8'
    services:
      web:
        build: .
        environment:
          - DATABASE_URL=postgresql://testuser:testpass@db:5432/testdb
          - REDIS_URL=redis://cache:6379
        depends_on:
          db:
            condition: service_healthy
          cache:
            condition: service_started
      
      db:
        image: postgres:15-alpine
        environment:
          - POSTGRES_DB=testdb
          - POSTGRES_USER=testuser
          - POSTGRES_PASSWORD=testpass
        healthcheck:
          test: ["CMD-SHELL", "pg_isready -U testuser -d testdb"]
          interval: 10s
          timeout: 5s
          retries: 5
      
      cache:
        image: redis:alpine
      
      # Test runner service
      test:
        build: .
        environment:
          - TEST_DATABASE_URL=postgresql://testuser:testpass@db:5432/testdb
          - TEST_REDIS_URL=redis://cache:6379
        command: pytest tests/integration/ -v
        depends_on:
          - web
          - db
          - cache

.. code-block:: bash

    # Run integration tests
    docker-compose -f docker-compose.test.yml up --build --abort-on-container-exit
    docker-compose -f docker-compose.test.yml down -v

**2. End-to-End Testing with Newman**

.. code-block:: json

    // postman-collection.json
    {
      "info": {
        "name": "API Integration Tests"
      },
      "item": [
        {
          "name": "Health Check",
          "request": {
            "method": "GET",
            "url": "{{baseUrl}}/health"
          },
          "event": [
            {
              "listen": "test",
              "script": {
                "exec": [
                  "pm.test('Status code is 200', function () {",
                  "    pm.response.to.have.status(200);",
                  "});"
                ]
              }
            }
          ]
        }
      ]
    }

.. code-block:: bash

    # Run API tests with Newman
    docker run --rm \
      --network container-network \
      -v $(pwd)/tests:/etc/newman \
      postman/newman:latest \
      run /etc/newman/postman-collection.json \
      --environment /etc/newman/environment.json \
      --reporters cli,htmlextra \
      --reporter-htmlextra-export /etc/newman/report.html

**3. Browser-Based E2E Testing**

.. code-block:: javascript

    // cypress/integration/app.spec.js
    describe('Application E2E Tests', () => {
      beforeEach(() => {
        cy.visit('/')
      })
      
      it('should load the homepage', () => {
        cy.contains('Welcome')
        cy.get('[data-testid="user-count"]').should('be.visible')
      })
      
      it('should create a new user', () => {
        cy.get('[data-testid="create-user-btn"]').click()
        cy.get('[data-testid="username-input"]').type('testuser')
        cy.get('[data-testid="email-input"]').type('test@example.com')
        cy.get('[data-testid="submit-btn"]').click()
        cy.contains('User created successfully')
      })
    })

.. code-block:: yaml

    # E2E testing with Cypress
    version: '3.8'
    services:
      app:
        build: .
        ports:
          - "3000:3000"
        environment:
          - NODE_ENV=test
      
      cypress:
        image: cypress/included:latest
        depends_on:
          - app
        environment:
          - CYPRESS_baseUrl=http://app:3000
        volumes:
          - ./cypress:/e2e
        working_dir: /e2e
        command: cypress run

===================
Performance Testing
===================

**Load Testing and Performance Validation**

**1. Load Testing with k6**

.. code-block:: javascript

    // load-test.js
    import http from 'k6/http';
    import { check, sleep } from 'k6';
    
    export let options = {
      stages: [
        { duration: '2m', target: 100 }, // Ramp up
        { duration: '5m', target: 100 }, // Stay at 100 users
        { duration: '2m', target: 200 }, // Ramp up to 200
        { duration: '5m', target: 200 }, // Stay at 200
        { duration: '2m', target: 0 },   // Ramp down
      ],
      thresholds: {
        'http_req_duration': ['p(95)<500'], // 95% of requests under 500ms
        'http_req_failed': ['rate<0.1'],    // Error rate under 10%
      },
    };
    
    export default function () {
      let response = http.get('http://localhost:8080/api/users');
      check(response, {
        'status is 200': (r) => r.status === 200,
        'response time < 500ms': (r) => r.timings.duration < 500,
      });
      sleep(1);
    }

.. code-block:: bash

    # Run load tests against containerized app
    docker-compose up -d
    docker run --rm \
      --network host \
      -v $(pwd):/scripts \
      grafana/k6:latest \
      run /scripts/load-test.js

**2. Resource Usage Testing**

.. code-block:: bash

    # Monitor resource usage during tests
    #!/bin/bash
    
    # Start application
    docker-compose up -d
    
    # Monitor resources
    docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" > resource-usage.log &
    STATS_PID=$!
    
    # Run load test
    k6 run load-test.js
    
    # Stop monitoring
    kill $STATS_PID
    
    # Check if containers stayed within limits
    docker inspect app-container | jq '.[0].HostConfig.Memory'

=============
Chaos Testing
=============

**Testing Resilience and Failure Scenarios**

**1. Container Failure Testing**

.. code-block:: bash

    #!/bin/bash
    # chaos-test.sh
    
    echo "Starting chaos testing..."
    
    # Kill random container
    CONTAINERS=$(docker ps --format "{{.Names}}" | grep -v postgres)
    RANDOM_CONTAINER=$(echo $CONTAINERS | tr ' ' '\n' | shuf -n 1)
    
    echo "Killing container: $RANDOM_CONTAINER"
    docker kill $RANDOM_CONTAINER
    
    # Wait and check if service recovers
    sleep 30
    
    # Test if application is still responsive
    if curl -f http://localhost:8080/health; then
        echo " Service recovered successfully"
    else
        echo " Service failed to recover"
        exit 1
    fi

**2. Network Chaos with Pumba**

.. code-block:: bash

    # Install Pumba for chaos testing
    docker pull gaiaadm/pumba
    
    # Add 100ms delay to network
    docker run --rm \
      -v /var/run/docker.sock:/var/run/docker.sock \
      gaiaadm/pumba netem \
      --duration 1m \
      --interface eth0 \
      delay \
      --time 100 \
      app-container
    
    # Simulate packet loss
    docker run --rm \
      -v /var/run/docker.sock:/var/run/docker.sock \
      gaiaadm/pumba netem \
      --duration 1m \
      loss \
      --percent 10 \
      app-container

**3. Resource Exhaustion Testing**

.. code-block:: bash

    # Test memory limits
    docker run --rm \
      --memory=128m \
      --name memory-test \
      alpine:latest \
      sh -c "
      while true; do
        dd if=/dev/zero of=/tmp/test bs=1M count=10
        sleep 1
      done
      "
    
    # Monitor behavior when limits are exceeded
    docker stats memory-test

==================
Compliance Testing
==================

**Regulatory and Security Compliance**

**1. CIS Benchmark Testing**

.. code-block:: bash

    # Run CIS Docker Benchmark
    docker run --rm --net host --pid host --userns host --cap-add audit_control \
      -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
      -v /etc:/etc:ro \
      -v /usr/bin/containerd:/usr/bin/containerd:ro \
      -v /usr/bin/runc:/usr/bin/runc:ro \
      -v /usr/lib/systemd:/usr/lib/systemd:ro \
      -v /var/lib:/var/lib:ro \
      -v /var/run/docker.sock:/var/run/docker.sock:ro \
      --label docker_bench_security \
      docker/docker-bench-security

**2. NIST Compliance Checking**

.. code-block:: python

    # compliance_check.py
    import docker
    import json
    
    def check_nist_compliance(container_name):
        client = docker.from_env()
        container = client.containers.get(container_name)
        
        compliance_results = {
            "compliant": True,
            "findings": []
        }
        
        # Check if running as non-root
        config = container.attrs['Config']
        user = config.get('User', 'root')
        if user == 'root' or user == '':
            compliance_results["compliant"] = False
            compliance_results["findings"].append("Container running as root user")
        
        # Check resource limits
        host_config = container.attrs['HostConfig']
        if not host_config.get('Memory'):
            compliance_results["compliant"] = False
            compliance_results["findings"].append("No memory limit set")
        
        if not host_config.get('CpuShares'):
            compliance_results["compliant"] = False
            compliance_results["findings"].append("No CPU limit set")
        
        return compliance_results

==================
Testing Automation
==================

**CI/CD Pipeline Integration**

**1. Complete Testing Pipeline**

.. code-block:: yaml

    # .github/workflows/test.yml
    name: Container Testing Pipeline
    
    on: [push, pull_request]
    
    jobs:
      unit-tests:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v3
          - name: Run unit tests
            run: |
              docker build --target test -t myapp:test .
              docker run --rm myapp:test
      
      security-scan:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v3
          - name: Build image
            run: docker build -t myapp:${{ github.sha }} .
          - name: Security scan
            run: |
              trivy image --exit-code 1 --severity HIGH,CRITICAL myapp:${{ github.sha }}
      
      integration-tests:
        runs-on: ubuntu-latest
        needs: [unit-tests, security-scan]
        steps:
          - uses: actions/checkout@v3
          - name: Run integration tests
            run: |
              docker-compose -f docker-compose.test.yml up --build --abort-on-container-exit
      
      performance-tests:
        runs-on: ubuntu-latest
        needs: integration-tests
        steps:
          - uses: actions/checkout@v3
          - name: Performance testing
            run: |
              docker-compose up -d
              docker run --rm --network host -v $(pwd):/scripts grafana/k6:latest run /scripts/load-test.js

**2. Test Results Reporting**

.. code-block:: python

    # test_reporter.py
    import json
    import xml.etree.ElementTree as ET
    
    def generate_test_report(test_results):
        report = {
            "timestamp": datetime.utcnow().isoformat(),
            "summary": {
                "total_tests": 0,
                "passed": 0,
                "failed": 0,
                "skipped": 0
            },
            "suites": []
        }
        
        # Process JUnit XML results
        tree = ET.parse('test-results.xml')
        root = tree.getroot()
        
        for testsuite in root.findall('testsuite'):
            suite = {
                "name": testsuite.get('name'),
                "tests": int(testsuite.get('tests', 0)),
                "failures": int(testsuite.get('failures', 0)),
                "errors": int(testsuite.get('errors', 0)),
                "time": float(testsuite.get('time', 0))
            }
            report["suites"].append(suite)
            
            report["summary"]["total_tests"] += suite["tests"]
            report["summary"]["failed"] += suite["failures"] + suite["errors"]
            report["summary"]["passed"] += suite["tests"] - suite["failures"] - suite["errors"]
        
        return report

============
What's Next?
============

You now have comprehensive knowledge of container testing strategies and tools. The next section covers production deployment best practices, bringing together everything you've learned about containers, security, and operations.

**Key takeaways:**

- Container testing spans multiple layers from unit tests to production monitoring
- Security testing must be automated and integrated into CI/CD pipelines
- Performance testing validates both application and infrastructure behavior
- Integration testing ensures multi-container applications work correctly
- Compliance testing is essential for regulated environments
- Automated testing pipelines catch issues before they reach production

.. note::

    **Testing Culture:** Great container testing requires a shift in mindset - you're testing not just code, but entire environments. Invest in automation early and test often.

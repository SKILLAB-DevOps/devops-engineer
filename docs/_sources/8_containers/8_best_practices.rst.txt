############################
8.8 Container Best Practices
############################

.. image:: ../diagrams/containers.png
  :alt: A diagram showing container security layers and best practices
  :width: 800 px

**From Working to World-Class**

You can run containers. You can build images. You can orchestrate applications. Now comes the crucial transformation: turning your container knowledge into production-ready expertise that enterprises depend on. This section distills hard-won lessons from thousands of production deployments, security incidents, and performance optimizations.

These aren't theoretical guidelines - they're battle-tested practices that prevent outages, security breaches, and operational headaches.

===================
Learning Objectives
===================

By the end of this section, you will:

• **Implement** container security hardening that passes enterprise audits
• **Optimize** images for size, performance, and reliability
• **Design** production-ready container architectures
• **Monitor** container performance and troubleshoot issues effectively
• **Automate** security scanning and compliance checking
• **Apply** operational best practices for day-2 container management

**Prerequisites:** Solid understanding of containers, Dockerfiles, and orchestration concepts

==========================
Security Best Practices
==========================

**The Container Security Model**

Container security operates on multiple layers, often called "defense in depth":

.. code-block:: text

    ┌─────────────────────────────────────┐
    │         Application Layer           │  ← Code vulnerabilities, secrets
    ├─────────────────────────────────────┤
    │         Container Layer             │  ← Image vulnerabilities, runtime config
    ├─────────────────────────────────────┤
    │         Host OS Layer               │  ← Kernel, system services
    ├─────────────────────────────────────┤
    │       Infrastructure Layer          │  ← Network, storage, compute
    └─────────────────────────────────────┘

**1. Secure Base Images**

**Use Minimal Base Images:**

.. code-block:: dockerfile

    # EXCELLENT: Distroless (no shell, minimal attack surface)
    FROM gcr.io/distroless/python3
    
    # GOOD: Alpine Linux (minimal, security-focused)
    FROM python:3.11-alpine
    
    # ACCEPTABLE: Slim images (smaller than full images)
    FROM python:3.11-slim
    
    # AVOID: Full images (unnecessary packages, larger attack surface)
    FROM python:3.11  # Contains compilers, debuggers, etc.

**Pin Specific Versions:**

.. code-block:: dockerfile

    # GOOD: Specific version with SHA256 hash
    FROM python:3.11.6-alpine@sha256:a5b78f3e2a63ce3b...
    
    # ACCEPTABLE: Specific semantic version
    FROM python:3.11.6-alpine
    
    # BAD: Moving tags
    FROM python:3.11-alpine  # Could change
    FROM python:latest       # Definitely will change

**Scan Images for Vulnerabilities:**

.. code-block:: bash

    # Using Trivy (free, comprehensive)
    trivy image python:3.11-alpine
    
    # Using Docker Scout (integrated with Docker)
    docker scout cves python:3.11-alpine
    
    # Using Snyk (commercial, detailed reporting)
    snyk test --docker python:3.11-alpine
    
    # Automate in CI/CD
    # Fail builds if critical vulnerabilities found
    trivy image --exit-code 1 --severity HIGH,CRITICAL myapp:latest

**2. Non-Root User Security**

**Why Root is Dangerous:**

.. code-block:: bash

    # If container escapes with root user:
    docker run --rm -it -v /:/host ubuntu:latest chroot /host
    # ^ This gives full host access if running as root

**Secure User Implementation:**

.. code-block:: dockerfile

    # Create dedicated user with specific UID/GID
    RUN groupadd -r appuser -g 1001 && \
        useradd -r -g appuser -u 1001 -s /bin/false appuser
    
    # Create application directory and set ownership
    WORKDIR /app
    COPY --chown=appuser:appuser . .
    
    # Install dependencies as root, then switch
    RUN pip install -r requirements.txt
    
    # Switch to non-root user for runtime
    USER appuser
    
    # Verify (for debugging)
    RUN whoami  # Should output: appuser

**Advanced Security Hardening:**

.. code-block:: dockerfile

    # Drop all capabilities, add only what's needed
    # Use with: docker run --cap-drop=ALL --cap-add=NET_BIND_SERVICE
    
    # Read-only root filesystem
    # Use with: docker run --read-only --tmpfs /tmp
    
    # No new privileges
    # Use with: docker run --security-opt=no-new-privileges
    
    # Use security profiles
    # Use with: docker run --security-opt=seccomp:seccomp-profile.json

**3. Secrets Management**

**Never Do This:**

.. code-block:: dockerfile

    # NEVER: Secrets in images
    ENV API_KEY=sk-1234567890abcdef
    ENV DATABASE_PASSWORD=super_secret_password
    COPY api_keys.txt /app/

**Proper Secrets Handling:**

.. code-block:: yaml

    # Docker Compose with external secrets
    version: '3.8'
    services:
      app:
        image: myapp:latest
        environment:
          - API_KEY_FILE=/run/secrets/api_key
        secrets:
          - api_key
    
    secrets:
      api_key:
        external: true  # Managed outside compose

.. code-block:: bash

    # Runtime secret injection
    docker run -e API_KEY="$(cat /secure/api_key)" myapp
    
    # Using init containers to fetch secrets
    # Kubernetes secret mounting
    # HashiCorp Vault integration

==================
Image Optimization
==================

**Size Optimization Strategies**

**1. Multi-Stage Builds for Minimal Images:**

.. code-block:: dockerfile

    # Build stage
    FROM node:18-alpine AS builder
    WORKDIR /app
    COPY package*.json ./
    RUN npm ci --only=production
    COPY . .
    RUN npm run build && npm prune --production
    
    # Runtime stage - significantly smaller
    FROM node:18-alpine AS runtime
    RUN addgroup -g 1001 -S nodejs && \
        adduser -S nextjs -u 1001
    WORKDIR /app
    
    # Copy only necessary files
    COPY --from=builder --chown=nextjs:nodejs /app/dist ./dist
    COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules
    COPY --from=builder --chown=nextjs:nodejs /app/package.json ./package.json
    
    USER nextjs
    CMD ["npm", "start"]

**2. Layer Optimization:**

.. code-block:: dockerfile

    # BAD: Creates multiple layers, poor caching
    RUN apt-get update
    RUN apt-get install -y curl
    RUN apt-get install -y wget
    RUN apt-get clean
    
    # GOOD: Single layer, better caching
    RUN apt-get update && \
        apt-get install -y \
            curl \
            wget \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

**3. Dependency Management:**

.. code-block:: dockerfile

    # Python: Use wheels and no-cache
    RUN pip install --no-cache-dir --find-links wheels -r requirements.txt
    
    # Node.js: Clean npm cache
    RUN npm ci --only=production && npm cache clean --force
    
    # Go: Use modules and static linking
    RUN go mod download && \
        CGO_ENABLED=0 go build -ldflags="-w -s" -o app

**4. Use .dockerignore:**

.. code-block:: text

    # .dockerignore
    .git
    .gitignore
    README.md
    Dockerfile
    .dockerignore
    node_modules
    .env
    .env.local
    coverage/
    .nyc_output
    target/
    .pytest_cache
    __pycache__

**Image Size Comparison:**

.. code-block:: bash

    # Analyze image layers
    docker history myapp:latest
    
    # Compare sizes
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
    
    # Dive tool for detailed analysis
    dive myapp:latest

==========================
Performance Best Practices
==========================

**Resource Management**

**Memory and CPU Limits:**

.. code-block:: yaml

    # Docker Compose
    services:
      web:
        image: myapp:latest
        deploy:
          resources:
            limits:
              memory: 512M
              cpus: '1.0'
            reservations:
              memory: 256M
              cpus: '0.5'

.. code-block:: bash

    # Docker run
    docker run -m 512m --cpus="1.0" myapp:latest

**JVM Applications:**

.. code-block:: dockerfile

    # Set heap size relative to container memory
    ENV JAVA_OPTS="-Xmx400m -Xms400m"
    # For 512MB container, leave ~100MB for non-heap

**Health Checks for Reliability:**

.. code-block:: dockerfile

    # Comprehensive health check
    HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
        CMD curl -f http://localhost:8080/health || exit 1

.. code-block:: python

    # Health check endpoint implementation
    @app.route('/health')
    def health_check():
        try:
            # Check database connection
            db.session.execute('SELECT 1')
            
            # Check external dependencies
            response = requests.get('http://api.service.com/ping', timeout=5)
            
            # Check resource usage
            memory_usage = psutil.virtual_memory().percent
            if memory_usage > 90:
                return {'status': 'unhealthy', 'reason': 'high_memory'}, 503
            
            return {'status': 'healthy', 'timestamp': datetime.utcnow().isoformat()}
        except Exception as e:
            return {'status': 'unhealthy', 'error': str(e)}, 503

**Startup and Graceful Shutdown:**

.. code-block:: dockerfile

    # Use exec form for proper signal handling
    CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app:app"]

.. code-block:: python

    # Graceful shutdown handling
    import signal
    import sys
    
    def signal_handler(sig, frame):
        print('Gracefully shutting down...')
        # Close database connections
        # Finish processing current requests
        # Clean up resources
        sys.exit(0)
    
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

======================
Monitoring and Logging
======================

**Structured Logging**

.. code-block:: python

    import logging
    import json
    from datetime import datetime
    
    class StructuredLogger:
        def __init__(self):
            self.logger = logging.getLogger(__name__)
            handler = logging.StreamHandler()
            handler.setFormatter(self.JSONFormatter())
            self.logger.addHandler(handler)
            self.logger.setLevel(logging.INFO)
        
        class JSONFormatter(logging.Formatter):
            def format(self, record):
                log_data = {
                    'timestamp': datetime.utcnow().isoformat(),
                    'level': record.levelname,
                    'service': 'my-app',
                    'message': record.getMessage(),
                    'container_id': os.environ.get('HOSTNAME', 'unknown')
                }
                if hasattr(record, 'request_id'):
                    log_data['request_id'] = record.request_id
                return json.dumps(log_data)

**Container Metrics Collection:**

.. code-block:: yaml

    # Docker Compose with monitoring
    version: '3.8'
    services:
      app:
        image: myapp:latest
        logging:
          driver: "json-file"
          options:
            max-size: "10m"
            max-file: "3"
      
      # Prometheus metrics collection
      prometheus:
        image: prom/prometheus:latest
        ports:
          - "9090:9090"
        volumes:
          - ./prometheus.yml:/etc/prometheus/prometheus.yml
      
      # Grafana for visualization
      grafana:
        image: grafana/grafana:latest
        ports:
          - "3000:3000"
        environment:
          - GF_SECURITY_ADMIN_PASSWORD=admin

**Application Metrics:**

.. code-block:: python

    from prometheus_client import Counter, Histogram, generate_latest
    
    REQUEST_COUNT = Counter('app_requests_total', 'Total requests', ['method', 'endpoint'])
    REQUEST_DURATION = Histogram('app_request_duration_seconds', 'Request duration')
    
    @REQUEST_DURATION.time()
    def process_request():
        REQUEST_COUNT.labels(method='GET', endpoint='/api/users').inc()
        # Your application logic here

====================
Development Workflow
====================

**Efficient Development Setup**

**Hot Reloading Configuration:**

.. code-block:: yaml

    # docker-compose.dev.yml
    version: '3.8'
    services:
      web:
        build:
          context: .
          target: development
        volumes:
          - .:/app
          - /app/node_modules  # Prevent overwriting
        environment:
          - NODE_ENV=development
          - CHOKIDAR_USEPOLLING=true  # For file watching in containers

**Testing in Containers:**

.. code-block:: dockerfile

    # Multi-stage with test stage
    FROM python:3.11-slim AS base
    WORKDIR /app
    COPY requirements.txt .
    RUN pip install -r requirements.txt
    
    FROM base AS test
    COPY requirements-test.txt .
    RUN pip install -r requirements-test.txt
    COPY . .
    CMD ["pytest", "-v"]
    
    FROM base AS production
    COPY . .
    CMD ["gunicorn", "app:app"]

.. code-block:: bash

    # Run tests in container
    docker build --target test -t myapp:test .
    docker run --rm myapp:test

**CI/CD Integration:**

.. code-block:: yaml

    # .github/workflows/container.yml
    name: Container CI/CD
    on: [push, pull_request]
    
    jobs:
      security-scan:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v3
          - name: Build image
            run: docker build -t myapp:${{ github.sha }} .
          - name: Security scan
            run: |
              docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
                aquasec/trivy:latest image --exit-code 1 --severity HIGH,CRITICAL \
                myapp:${{ github.sha }}
      
      test:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v3
          - name: Run tests
            run: |
              docker build --target test -t myapp:test .
              docker run --rm myapp:test

=====================
Production Deployment
=====================

**Zero-Downtime Deployments**

**Rolling Updates with Health Checks:**

.. code-block:: yaml

    # Kubernetes deployment example
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: myapp
    spec:
      replicas: 3
      strategy:
        type: RollingUpdate
        rollingUpdate:
          maxUnavailable: 1
          maxSurge: 1
      template:
        spec:
          containers:
          - name: app
            image: myapp:v1.2.3
            livenessProbe:
              httpGet:
                path: /health
                port: 8080
              initialDelaySeconds: 30
              periodSeconds: 10
            readinessProbe:
              httpGet:
                path: /ready
                port: 8080
              initialDelaySeconds: 5
              periodSeconds: 5

**Blue-Green Deployments:**

.. code-block:: bash

    # Blue-green deployment script
    #!/bin/bash
    NEW_VERSION=$1
    
    # Deploy new version to green environment
    docker service create --name myapp-green --replicas 3 myapp:$NEW_VERSION
    
    # Wait for health checks
    while ! curl -f http://green.example.com/health; do
        sleep 5
    done
    
    # Switch traffic (update load balancer)
    update_load_balancer_to_green
    
    # Remove old blue environment
    docker service rm myapp-blue
    
    # Rename green to blue for next deployment
    docker service update --name myapp-blue myapp-green

**Backup and Recovery:**

.. code-block:: yaml

    # Backup strategy for stateful services
    services:
      postgres:
        image: postgres:15
        volumes:
          - postgres_data:/var/lib/postgresql/data
          - ./backups:/backups
        environment:
          - POSTGRES_DB=myapp
      
      backup:
        image: postgres:15
        volumes:
          - postgres_data:/var/lib/postgresql/data:ro
          - ./backups:/backups
        command: |
          sh -c "
          while true; do
            pg_dump -h postgres -U postgres myapp > /backups/backup_$(date +%Y%m%d_%H%M%S).sql
            sleep 3600
          done
          "

============================
Security Scanning Automation
============================

**Implementing Security Gates**

.. code-block:: bash

    #!/bin/bash
    # security-scan.sh
    IMAGE_NAME=$1
    
    echo "Running security scan on $IMAGE_NAME..."
    
    # Vulnerability scan
    trivy image --format json --output scan-results.json $IMAGE_NAME
    
    # Check for critical vulnerabilities
    CRITICAL_VULN=$(jq '.Results[]?.Vulnerabilities[]? | select(.Severity == "CRITICAL") | length' scan-results.json | wc -l)
    
    if [ "$CRITICAL_VULN" -gt 0 ]; then
        echo " Critical vulnerabilities found. Deployment blocked."
        exit 1
    fi
    
    # License compliance check
    docker run --rm -v $(pwd):/workspace fossa/fossa analyze
    
    # Secret detection
    docker run --rm -v $(pwd):/workspace trufflesecurity/trufflehog:latest filesystem /workspace
    
    echo " Security scan passed."

**Policy as Code:**

.. code-block:: yaml

    # Open Policy Agent (OPA) policy
    package docker.security
    
    deny[msg] {
        input.User == "root"
        msg := "Container cannot run as root user"
    }
    
    deny[msg] {
        input.Image.tag == "latest"
        msg := "Image must use specific version tags, not 'latest'"
    }
    
    deny[msg] {
        not input.HealthCheck
        msg := "Container must define a health check"
    }

=====================
Troubleshooting Guide
=====================

**Common Production Issues**

**Container Won't Start:**

.. code-block:: bash

    # Check container logs
    docker logs container_name
    
    # Run interactively to debug
    docker run -it --entrypoint /bin/sh image_name
    
    # Check resource constraints
    docker stats
    docker system df

**Performance Issues:**

.. code-block:: bash

    # Monitor resource usage
    docker stats --no-stream
    
    # Check container processes
    docker exec container_name ps aux
    
    # Memory analysis
    docker exec container_name cat /proc/meminfo
    
    # Check for memory leaks
    docker exec container_name pmap -x 1

**Network Issues:**

.. code-block:: bash

    # Test connectivity between containers
    docker exec container1 ping container2
    
    # Check DNS resolution
    docker exec container_name nslookup service_name
    
    # Inspect network configuration
    docker network inspect network_name

**Storage Issues:**

.. code-block:: bash

    # Check disk usage
    docker system df
    
    # Clean up unused resources
    docker system prune -a
    
    # Check volume mounts
    docker inspect container_name | jq '.[].Mounts'

======================
Operational Excellence
======================

**Day-2 Operations Checklist**

**Daily Tasks:**

- Monitor container health and resource usage
- Review security scan results
- Check backup completion
- Monitor application metrics and alerts

**Weekly Tasks:**

- Update base images for security patches
- Review and clean up unused images/containers
- Performance baseline comparison
- Security policy compliance audit

**Monthly Tasks:**

- Disaster recovery testing
- Capacity planning review
- Security training and awareness
- Tool and process optimization

**Automated Monitoring:**

.. code-block:: yaml

    # Comprehensive monitoring stack
    version: '3.8'
    services:
      # Log aggregation
      loki:
        image: grafana/loki:latest
        ports:
          - "3100:3100"
      
      # Metrics collection
      prometheus:
        image: prom/prometheus:latest
        ports:
          - "9090:9090"
      
      # Alerting
      alertmanager:
        image: prom/alertmanager:latest
        ports:
          - "9093:9093"
      
      # Visualization
      grafana:
        image: grafana/grafana:latest
        ports:
          - "3000:3000"

===============
Future-Proofing
===============

**Container Technology Evolution**

**WebAssembly (WASM) Containers:**

- Smaller, faster, more secure than traditional containers
- Language-agnostic runtime
- Better isolation and portability

**Confidential Computing:**

- Hardware-encrypted container execution
- Protection against privileged access attacks
- Secure multi-party computation

**GitOps and Infrastructure as Code:**

- Declarative container configuration
- Version-controlled infrastructure
- Automated drift detection and correction

============
What's Next?
============

You now have the knowledge to run containers securely and efficiently in production. These practices form the foundation for scaling to Kubernetes, implementing microservices architectures, and building robust cloud-native applications.

**Key takeaways:**

- Security is multi-layered and must be built in from the start
- Image optimization reduces costs and improves performance
- Monitoring and logging are essential for production operations
- Automation prevents human error and improves reliability
- Best practices evolve - stay current with the container ecosystem

.. warning::

    **Continuous Learning:** Container technology evolves rapidly. Join the community, follow security advisories, and regularly update your practices. What's secure today may be vulnerable tomorrow.


##########################
9.3 Production Deployments
##########################

**Integrating with Your DevOps Pipeline**

With a solid understanding of Kubernetes core concepts, you're ready to connect the dots between your CI/CD pipelines from Chapter 7 and Kubernetes deployments. This section shows you how to automate the entire flow from code commit to production deployment with zero downtime and automatic rollbacks.

You'll transform your existing GitHub Actions workflows to deploy directly to Kubernetes, implementing the production-grade practices that modern DevOps teams rely on.

==================
CI/CD + Kubernetes
==================

**Complete Automation Pipeline**

Extend your existing GitHub Actions workflow to deploy directly to Kubernetes:

.. code-block:: yaml

    # .github/workflows/deploy.yml
    name: Build and Deploy
    
    on:
      push:
        branches: [main]
    
    env:
      REGISTRY: ghcr.io
      IMAGE_NAME: ${{ github.repository }}
    
    jobs:
      test:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          - name: Run tests
            run: |
              pip install -r requirements.txt
              pytest
      
      build:
        needs: test
        runs-on: ubuntu-latest
        outputs:
          image: ${{ steps.image.outputs.image }}
        steps:
          - uses: actions/checkout@v4
          
          - name: Build and push
            uses: docker/build-push-action@v5
            with:
              push: true
              tags: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
          
          - name: Output image
            id: image
            run: echo "image=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}" >> $GITHUB_OUTPUT
      
      deploy:
        needs: build
        runs-on: ubuntu-latest
        environment: production
        steps:
          - uses: actions/checkout@v4
          
          - name: Setup kubectl
            uses: azure/setup-kubectl@v3
          
          - name: Deploy to Kubernetes
            run: |
              # Configure kubectl
              echo "${{ secrets.KUBECONFIG }}" | base64 -d > ~/.kube/config
              
              # Update deployment with new image
              kubectl set image deployment/webapp webapp=${{ needs.build.outputs.image }}
              
              # Wait for rollout
              kubectl rollout status deployment/webapp --timeout=300s
              
              # Verify deployment
              kubectl get pods -l app=webapp

**Required Secrets:**
- `KUBECONFIG`: Base64-encoded kubeconfig file
- GitHub token (automatic) for container registry access

=========================
Zero-Downtime Deployments
=========================

**Rolling Updates (Default)**

Kubernetes replaces pods gradually, ensuring service availability:

.. code-block:: yaml

    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: webapp
    spec:
      replicas: 3
      strategy:
        type: RollingUpdate
        rollingUpdate:
          maxSurge: 1        # 1 extra pod during update
          maxUnavailable: 1  # 1 pod can be down
      selector:
        matchLabels:
          app: webapp
      template:
        metadata:
          labels:
            app: webapp
        spec:
          containers:
          - name: webapp
            image: myapp:latest
            ports:
            - containerPort: 8080
            livenessProbe:
              httpGet:
                path: /health
                port: 8080
              initialDelaySeconds: 30
            readinessProbe:
              httpGet:
                path: /ready
                port: 8080
              initialDelaySeconds: 5
            resources:
              requests:
                memory: "256Mi"
                cpu: "250m"
              limits:
                memory: "512Mi"
                cpu: "500m"

**Blue-Green Deployment (Instant Rollback)**

For critical applications requiring instant rollback:

.. code-block:: yaml

    # Deploy new version (green)
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: webapp-green
    spec:
      replicas: 3
      selector:
        matchLabels:
          app: webapp
          version: green
      template:
        metadata:
          labels:
            app: webapp
            version: green
        spec:
          containers:
          - name: webapp
            image: myapp:v2.0.0
    
    ---
    # Switch traffic by updating service
    apiVersion: v1
    kind: Service
    metadata:
      name: webapp
    spec:
      selector:
        app: webapp
        version: green  # Change from 'blue' to 'green'
      ports:
      - port: 80
        targetPort: 8080

**Blue-Green Deployment Script:**

.. code-block:: bash

    #!/bin/bash
    # Switch between blue/green deployments
    
    NEW_VERSION=$1
    CURRENT=$(kubectl get service webapp -o jsonpath='{.spec.selector.version}')
    NEW_COLOR=$([ "$CURRENT" = "blue" ] && echo "green" || echo "blue")
    
    echo "Deploying to $NEW_COLOR environment"
    
    # Update deployment
    kubectl set image deployment/webapp-$NEW_COLOR webapp=myapp:$NEW_VERSION
    kubectl rollout status deployment/webapp-$NEW_COLOR
    
    # Switch traffic
    kubectl patch service webapp -p '{"spec":{"selector":{"version":"'$NEW_COLOR'"}}}'
    
    echo "Traffic switched to $NEW_COLOR"

**Canary Deployment (Gradual Rollout)**

Test new versions with small traffic percentage:

.. code-block:: yaml

    # Main deployment (90% traffic)
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: webapp-stable
    spec:
      replicas: 3
      selector:
        matchLabels:
          app: webapp
          version: stable
      template:
        metadata:
          labels:
            app: webapp
            version: stable
        spec:
          containers:
          - name: webapp
            image: myapp:v1.0.0
    
    ---
    # Canary deployment (10% traffic)
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: webapp-canary
    spec:
      replicas: 1  # 1 pod = ~25% traffic with 3 stable pods
      selector:
        matchLabels:
          app: webapp
          version: canary
      template:
        metadata:
          labels:
            app: webapp
            version: canary
        spec:
          containers:
          - name: webapp
            image: myapp:v2.0.0

========================
Production Health Checks
========================

**Comprehensive Health Monitoring**

Your application needs proper health endpoints:

.. code-block:: python

    from flask import Flask, jsonify
    import psycopg2
    import redis
    
    app = Flask(__name__)
    
    @app.route('/health')
    def health():
        """Basic health check - is app running?"""
        return jsonify({"status": "healthy"})
    
    @app.route('/ready')
    def ready():
        """Detailed readiness - can handle traffic?"""
        checks = {}
        
        # Check database
        try:
            conn = psycopg2.connect(DATABASE_URL)
            conn.close()
            checks["database"] = "ok"
        except:
            checks["database"] = "failed"
            return jsonify({"status": "not ready", "checks": checks}), 503
        
        # Check Redis
        try:
            r = redis.from_url(REDIS_URL)
            r.ping()
            checks["redis"] = "ok"
        except:
            checks["redis"] = "failed"
            return jsonify({"status": "not ready", "checks": checks}), 503
        
        return jsonify({"status": "ready", "checks": checks})

**Kubernetes Health Configuration:**

.. code-block:: yaml

    spec:
      containers:
      - name: webapp
        image: myapp:latest
        
        # Startup probe - for slow starting apps
        startupProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 10
          failureThreshold: 30  # 5 minutes to start
        
        # Liveness probe - restart if failed
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
          failureThreshold: 3
        
        # Readiness probe - remove from service if not ready
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
          failureThreshold: 2

=======================
Multi-Environment Setup
=======================

**Organizing Environments**

Use directories to organize different environments:

.. code-block:: text

    k8s/
    ├── base/
    │   ├── deployment.yaml
    │   ├── service.yaml
    │   └── configmap.yaml
    ├── dev/
    │   ├── deployment.yaml
    │   └── configmap.yaml
    ├── staging/
    │   ├── deployment.yaml
    │   └── configmap.yaml
    └── production/
        ├── deployment.yaml
        ├── configmap.yaml
        └── secrets.yaml

**Environment-Specific Deployment:**

.. code-block:: yaml

    # k8s/production/deployment.yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: webapp
      namespace: production
    spec:
      replicas: 5  # More replicas for production
      template:
        spec:
          containers:
          - name: webapp
            image: myapp:latest
            resources:
              requests:
                memory: "512Mi"
                cpu: "500m"
              limits:
                memory: "1Gi"
                cpu: "1000m"
            env:
            - name: ENVIRONMENT
              value: "production"
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: webapp-secrets
                  key: database-url

**Deploy to Different Environments:**

.. code-block:: bash

    # Deploy to development
    kubectl apply -f k8s/dev/ -n development
    
    # Deploy to staging
    kubectl apply -f k8s/staging/ -n staging
    
    # Deploy to production
    kubectl apply -f k8s/production/ -n production

======================
Rollbacks and Recovery
======================

**When Deployments Fail**

Kubernetes provides automatic rollback capabilities:

.. code-block:: bash

    # Check deployment status
    kubectl rollout status deployment/webapp
    
    # View rollout history
    kubectl rollout history deployment/webapp
    
    # Rollback to previous version
    kubectl rollout undo deployment/webapp
    
    # Rollback to specific version
    kubectl rollout undo deployment/webapp --to-revision=2
    
    # Pause a rollout
    kubectl rollout pause deployment/webapp
    
    # Resume a rollout
    kubectl rollout resume deployment/webapp

**Automatic Rollback on Health Check Failure:**

.. code-block:: yaml

    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: webapp
    spec:
      replicas: 3
      revisionHistoryLimit: 5  # Keep 5 previous versions
      strategy:
        type: RollingUpdate
        rollingUpdate:
          maxUnavailable: 0  # Never go below desired replicas
      template:
        spec:
          containers:
          - name: webapp
            image: myapp:latest
            readinessProbe:
              httpGet:
                path: /ready
                port: 8080
              failureThreshold: 3  # Rollback after 3 failures

=======================
Security Best Practices
=======================

**Production Security**

Secure your deployments with these configurations:

.. code-block:: yaml

    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: webapp
    spec:
      template:
        spec:
          serviceAccountName: webapp-sa  # Dedicated service account
          securityContext:
            runAsNonRoot: true
            runAsUser: 1000
            fsGroup: 1000
          containers:
          - name: webapp
            image: myapp:latest@sha256:abc123...  # Use image digest
            securityContext:
              allowPrivilegeEscalation: false
              readOnlyRootFilesystem: true
              capabilities:
                drop: ["ALL"]
            resources:
              requests:
                memory: "256Mi"
                cpu: "250m"
              limits:
                memory: "512Mi"
                cpu: "500m"
            env:
            - name: DATABASE_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: webapp-secrets
                  key: password
            volumeMounts:
            - name: tmp
              mountPath: /tmp
          volumes:
          - name: tmp
            emptyDir: {}

======================
Monitoring Integration
======================

**Observability Setup**

Add monitoring to your deployments:

.. code-block:: yaml

    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: webapp
    spec:
      template:
        metadata:
          annotations:
            prometheus.io/scrape: "true"
            prometheus.io/port: "8080"
            prometheus.io/path: "/metrics"
        spec:
          containers:
          - name: webapp
            image: myapp:latest
            ports:
            - containerPort: 8080
              name: http
            env:
            - name: LOG_LEVEL
              value: "INFO"
            - name: LOG_FORMAT
              value: "json"

**Application Metrics:**

.. code-block:: python

    from prometheus_client import Counter, Histogram, generate_latest
    
    REQUEST_COUNT = Counter('app_requests_total', 'Total requests')
    REQUEST_LATENCY = Histogram('app_request_duration_seconds', 'Request latency')
    
    @app.route('/metrics')
    def metrics():
        return generate_latest()

===========================
Complete Production Example
===========================

**Full Production Deployment**

Here's a complete production-ready deployment:

.. code-block:: yaml

    # Complete production deployment
    apiVersion: v1
    kind: Secret
    metadata:
      name: webapp-secrets
      namespace: production
    type: Opaque
    data:
      database-password: <base64-encoded>
      api-key: <base64-encoded>
    
    ---
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: webapp-config
      namespace: production
    data:
      database_host: "postgres.production.local"
      log_level: "INFO"
      environment: "production"
    
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: webapp
      namespace: production
      labels:
        app: webapp
        version: v1.0.0
    spec:
      replicas: 5
      revisionHistoryLimit: 5
      strategy:
        type: RollingUpdate
        rollingUpdate:
          maxSurge: 1
          maxUnavailable: 0
      selector:
        matchLabels:
          app: webapp
      template:
        metadata:
          labels:
            app: webapp
          annotations:
            prometheus.io/scrape: "true"
            prometheus.io/port: "8080"
        spec:
          serviceAccountName: webapp-sa
          securityContext:
            runAsNonRoot: true
            runAsUser: 1000
          containers:
          - name: webapp
            image: myapp:v1.0.0
            ports:
            - containerPort: 8080
            env:
            - name: DATABASE_HOST
              valueFrom:
                configMapKeyRef:
                  name: webapp-config
                  key: database_host
            - name: DATABASE_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: webapp-secrets
                  key: database-password
            - name: LOG_LEVEL
              valueFrom:
                configMapKeyRef:
                  name: webapp-config
                  key: log_level
            startupProbe:
              httpGet:
                path: /health
                port: 8080
              initialDelaySeconds: 10
              failureThreshold: 30
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
            resources:
              requests:
                memory: "512Mi"
                cpu: "500m"
              limits:
                memory: "1Gi"
                cpu: "1000m"
            securityContext:
              allowPrivilegeEscalation: false
              readOnlyRootFilesystem: true
              capabilities:
                drop: ["ALL"]
            volumeMounts:
            - name: tmp
              mountPath: /tmp
          volumes:
          - name: tmp
            emptyDir: {}
    
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: webapp
      namespace: production
    spec:
      selector:
        app: webapp
      ports:
      - port: 80
        targetPort: 8080
      type: LoadBalancer

**Deploy and Verify:**

.. code-block:: bash

    # Deploy to production
    kubectl apply -f production-deployment.yaml
    
    # Monitor rollout
    kubectl rollout status deployment/webapp -n production
    
    # Check health
    kubectl get pods -l app=webapp -n production
    kubectl logs -l app=webapp -n production
    
    # Test application
    kubectl port-forward service/webapp 8080:80 -n production
    curl http://localhost:8080/health

==================
Essential Commands
==================

**Daily Operations:**

.. code-block:: bash

    # Deployment management
    kubectl get deployments
    kubectl describe deployment webapp
    kubectl rollout status deployment/webapp
    
    # Updates and rollbacks
    kubectl set image deployment/webapp webapp=myapp:v2.0.0
    kubectl rollout undo deployment/webapp
    kubectl rollout history deployment/webapp
    
    # Scaling
    kubectl scale deployment webapp --replicas=10
    
    # Troubleshooting
    kubectl logs deployment/webapp
    kubectl get events --sort-by=.metadata.creationTimestamp
    kubectl exec -it deployment/webapp -- bash

============
What's Next?
============

**Advanced Deployment Tools**

You now understand production Kubernetes deployments:

- **CI/CD Integration** - Automated deployments from GitHub Actions
- **Zero-Downtime Strategies** - Rolling, blue-green, and canary deployments
- **Health Monitoring** - Comprehensive health checks and probes
- **Multi-Environment Management** - Dev, staging, and production setups
- **Security Best Practices** - Secure container and pod configurations
- **Monitoring Integration** - Observability and metrics collection

Next: **Helm** for packaging applications and **ArgoCD** for GitOps workflows that make deployment management even more powerful.

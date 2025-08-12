#######
ANSWERS
#######

**Complete Answer Key for Chapter Assignments**

This document provides comprehensive answers to all theoretical questions and implementation guides for practical deployments. Use these answers to verify your understanding and implementation approaches.

===================
Theoretical Answers
===================

**Q1. Control Loop Pattern**

Kubernetes uses a continuous control loop that follows the pattern: Observe → Compare → Act → Repeat.

**Scenario: Pod Crash Recovery**

1. **Observe**: Controller Manager detects that only 2 of 3 desired pods are running
2. **Compare**: Current state (2 pods) doesn't match desired state (3 pods)  
3. **Act**: Controller creates a new pod specification and submits to API server
4. **Scheduler**: Selects appropriate node based on resources and constraints
5. **kubelet**: Receives pod assignment, pulls image, starts container
6. **Result**: Desired state restored automatically (usually within 30-60 seconds)

This happens without human intervention, ensuring application resilience and meeting SLA requirements.

**Q2. Pods vs Containers**

Pods exist because containers often need to work together as a cohesive unit. A Pod provides shared networking (IP address, ports) and storage volumes to multiple containers.

**Example 1: Web Server + Log Aggregator**

.. code-block:: yaml

  # Main web container + logging sidecar
  containers:
  - name: web-app
    image: nginx:latest
  - name: log-forwarder  
    image: fluent/fluent-bit
    # Shares /var/log volume with web-app

**Example 2: Python App + Configuration Reloader**

.. code-block:: yaml

  # Python Flask app + config watcher that reloads app when config changes
  containers:
  - name: python-api
    image: python:3.12-slim
  - name: config-reloader
    image: python:3.9-alpine
    # Both share config volume and communicate via localhost

**Q3. Service Discovery**

Kubernetes service discovery works through multiple mechanisms:

**DNS Resolution**: Every Service gets a DNS entry (`<service-name>.<namespace>.svc.cluster.local`)

.. code-block:: yaml

  # From any pod, this resolves to the database service IP
  curl http://postgres.default.svc.cluster.local:5432

**Environment Variables**: Kubernetes injects service information as environment variables

.. code-block:: yaml

  POSTGRES_SERVICE_HOST=10.96.0.50
  POSTGRES_SERVICE_PORT=5432

**Service Object**: Acts as a stable endpoint that load balances to healthy pods

.. code-block:: yaml

  apiVersion: v1
  kind: Service
  spec:
    selector:
      app: postgres  # Routes to pods with this label
    ports:
    - port: 5432

**Q4. Declarative vs Imperative**

**Imperative** (step-by-step commands):

.. code-block:: yaml

  kubectl run python-app --image=python:3.12-slim
  kubectl scale deployment python-app --replicas=3
  kubectl expose deployment python-app --port=8080

**Declarative** (desired state specification):

.. code-block:: yaml
  
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: python-app
  spec:
    replicas: 3
    template:
      spec:
        containers:
        - name: python-app
          image: python:3.12-slim


**Why Declarative is Preferred:**

- **Reproducible**: Same result every time
- **Version controlled**: YAML files can be stored in Git
- **Self-healing**: Kubernetes maintains desired state automatically
- **Collaborative**: Multiple team members can work with same configurations

**Q5. Rolling Updates**

Kubernetes rolling updates replace pods gradually to ensure zero downtime:

**Process:**

1. Create new ReplicaSet with updated image
2. Start new pods one by one
3. Wait for new pods to pass readiness checks
4. Terminate old pods gradually
5. Continue until all pods are updated

**Rollback Process:**

.. code-block:: yaml

  # Automatic rollback if deployment fails
  kubectl rollout undo deployment/web-app

  # Manual rollback to specific revision
  kubectl rollout history deployment/web-app
  kubectl rollout undo deployment/web-app --to-revision=2


**Q6. Resource Management**

"OOMKilled" means the pod exceeded memory limits and was terminated by the Linux kernel.

**Solution with resource specifications:**

.. code-block:: yaml

  apiVersion: apps/v1
  kind: Deployment
  spec:
    template:
      spec:
        containers:
        - name: python-app
          image: python:3.12-slim
          resources:
            requests:  # Guaranteed resources
              memory: "512Mi"
              cpu: "250m"
            limits:     # Maximum allowed
              memory: "1Gi"  
              cpu: "500m"

**Best Practices:**

- Set requests based on typical usage
- Set limits 20-50% higher than requests
- Monitor actual usage to optimize values

**Q7. ConfigMaps vs Secrets**

**ConfigMaps** for non-sensitive configuration:

.. code-block:: yaml

  apiVersion: v1
  kind: ConfigMap
  data:
    database_host: "postgres.example.com"
    cache_timeout: "300"
    log_level: "info"

**Secrets** for sensitive data:

.. code-block:: yaml

  apiVersion: v1
  kind: Secret
  type: Opaque
  data:
    password: cGFzc3dvcmQxMjM=  # base64 encoded
    api_key: YWJjZGVmZ2hpams=

**Security Implications:**

- ConfigMaps are stored in plain text in etcd
- Secrets are base64 encoded (not encrypted) by default
- Use encryption at rest and RBAC to protect Secrets
- Consider external secret management systems for production

**Q8. Horizontal Pod Autoscaler**

HPA automatically scales pod replicas based on observed metrics:

**How it works:**

1. HPA controller queries metrics API every 30 seconds
2. Compares current metric values to target values
3. Calculates desired replica count using formula: `desiredReplicas = ceil[currentReplicas * (currentMetricValue / targetMetricValue)]`
4. Updates Deployment replica count if change is significant

**Example HPA:**

.. code-block:: yaml

  apiVersion: autoscaling/v2
  kind: HorizontalPodAutoscaler
  spec:
    scaleTargetRef:
      apiVersion: apps/v1
      kind: Deployment
      name: web-app
    minReplicas: 2
    maxReplicas: 10
    metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70

**Q9. Kubernetes Architecture**

The statement is **incorrect**. Applications continue running if control plane nodes fail because:

**Control Plane Role:**

- Makes scheduling decisions for new pods
- Handles API requests (kubectl commands)
- Stores cluster state in etcd

**Worker Node Independence:**

- kubelet runs pods independently once scheduled
- Existing pods continue running without control plane
- kube-proxy maintains networking rules locally

**High Availability Setup:**

- Multiple control plane nodes with load balancer
- etcd cluster with odd number of nodes (3 or 5)
- External etcd cluster for increased resilience

**Q10. GitOps Workflow**

**Complete GitOps pipeline:**

1. **Code Commit**: Developer pushes to main branch
2. **CI Pipeline**: GitHub Actions triggers automatically
3. **Build & Test**: Run tests, build Docker image
4. **Image Push**: Push to container registry with Git SHA tag
5. **Manifest Update**: Update Kubernetes manifests with new image tag
6. **GitOps Tool**: ArgoCD detects manifest changes
7. **Deployment**: ArgoCD applies changes to Kubernetes cluster
8. **Validation**: Health checks confirm successful deployment

**Image Tagging Strategy:**

.. code-block:: yaml

  # Use Git SHA for immutable tags
  IMAGE_TAG=${GITHUB_SHA::8}
  docker build -t myapp-python:${IMAGE_TAG} .
  docker tag myapp-python:${IMAGE_TAG} myapp-python:latest

**Deployment Validation:**

.. code-block:: bash

  kubectl rollout status deployment/python-web-app
  kubectl get pods -l app=python-web-app
  curl -f http://python-web-app-service/health

===============================
Practical Deployment Solutions
===============================

================
Easy Deployments
================

**Deploy 1: Static Web Application**

**deployment.yaml**

.. code-block:: yaml

  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: static-web
    labels:
      app: static-web
  spec:
    replicas: 3
    selector:
      matchLabels:
        app: static-web
    template:
      metadata:
        labels:
          app: static-web
      spec:
        containers:
        - name: nginx
          image: nginx:1.21
          ports:
          - containerPort: 80
          volumeMounts:
          - name: html-content
            mountPath: /usr/share/nginx/html
        volumes:
        - name: html-content
          configMap:
            name: web-content

**configmap.yaml**

.. code-block:: yaml

  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: web-content
  data:
    index.html: |
      <!DOCTYPE html>
      <html>
      <head>
          <title>My Kubernetes App</title>
          <style>
              body { font-family: Arial; text-align: center; padding: 50px; }
              .container { max-width: 800px; margin: 0 auto; }
              h1 { color: #326ce5; }
          </style>
      </head>
      <body>
          <div class="container">
              <h1>Welcome to My Kubernetes Application!</h1>
              <p>This page is served by nginx running in a Kubernetes cluster.</p>
              <p>Pod hostname: <span id="hostname"></span></p>
          </div>
          <script>
              fetch('/api/hostname')
                  .then(response => response.text())
                  .then(data => document.getElementById('hostname').textContent = data)
                  .catch(() => document.getElementById('hostname').textContent = 'Unknown');
          </script>
      </body>
      </html>

**service.yaml**

.. code-block:: yaml

  apiVersion: v1
  kind: Service
  metadata:
    name: static-web-service
  spec:
    type: LoadBalancer
    selector:
      app: static-web
    ports:
    - port: 80
      targetPort: 80
      protocol: TCP

**Deploy 2: Database with Persistent Storage**

**postgres-pvc.yaml**

.. code-block:: yaml

  apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    name: postgres-pvc
  spec:
    accessModes:
      - ReadWriteOnce
    resources:
      requests:
        storage: 5Gi

**postgres-secret.yaml**

.. code-block:: yaml

  apiVersion: v1
  kind: Secret
  metadata:
    name: postgres-secret
  type: Opaque
  data:
    username: cG9zdGdyZXM=        # postgres
    password: cGFzc3dvcmQxMjM=    # password123
    database: bXlkYXRhYmFzZQ==    # mydatabase


**postgres-deployment.yaml**

.. code-block:: yaml

  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: postgres
  spec:
    replicas: 1
    selector:
      matchLabels:
        app: postgres
    template:
      metadata:
        labels:
          app: postgres
      spec:
        containers:
        - name: postgres
          image: postgres:13
          env:
          - name: POSTGRES_USER
            valueFrom:
              secretKeyRef:
                name: postgres-secret
                key: username
          - name: POSTGRES_PASSWORD
            valueFrom:
              secretKeyRef:
                name: postgres-secret
                key: password
          - name: POSTGRES_DB
            valueFrom:
              secretKeyRef:
                name: postgres-secret
                key: database
          ports:
          - containerPort: 5432
          volumeMounts:
          - name: postgres-storage
            mountPath: /var/lib/postgresql/data
          livenessProbe:
            exec:
              command:
                - pg_isready
                - -U
                - postgres
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            exec:
              command:
                - pg_isready
                - -U
                - postgres
            initialDelaySeconds: 5
            periodSeconds: 5
        volumes:
        - name: postgres-storage
          persistentVolumeClaim:
            claimName: postgres-pvc


**postgres-service.yaml**

.. code-block:: yaml

  apiVersion: v1
  kind: Service
  metadata:
    name: postgres-service
  spec:
    selector:
      app: postgres
    ports:
    - port: 5432
      targetPort: 5432
    type: ClusterIP


**Deploy 3: Multi-Tier Application**

**backend-deployment.yaml**

.. code-block:: yaml

  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: backend-api
  spec:
    replicas: 2
    selector:
      matchLabels:
        app: backend-api
    template:
      metadata:
        labels:
          app: backend-api
      spec:
        containers:
        - name: python-api
          image: python:3.12-slim
          command: 
            - sh
            - -c
            - |
              cat > app.py << 'EOF'
              from flask import Flask, jsonify
              import os
              import socket
              from datetime import datetime
              
              app = Flask(__name__)
              
              @app.route('/api/status')
              def status():
                  return jsonify({
                      'status': 'ok',
                      'timestamp': datetime.now().isoformat(),
                      'hostname': socket.gethostname(),
                      'pod_name': os.environ.get('HOSTNAME', 'unknown')
                  })
              
              @app.route('/health')
              def health():
                  return jsonify({'status': 'healthy'})
              
              if __name__ == '__main__':
                  app.run(host='0.0.0.0', port=3000)
              EOF
              pip install flask
              python app.py
          ports:
          - containerPort: 3000
          env:
          - name: HOSTNAME
            valueFrom:
              fieldRef:
                fieldPath: metadata.name


**frontend-deployment.yaml**

.. code-block:: yaml

  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: frontend-web
  spec:
    replicas: 3
    selector:
      matchLabels:
        app: frontend-web
    template:
      metadata:
        labels:
          app: frontend-web
      spec:
        containers:
        - name: python-frontend
          image: python:3.12-slim
          command:
            - sh
            - -c
            - |
              cat > frontend.py << 'EOF'
              from flask import Flask, render_template_string
              import requests
              import os
              
              app = Flask(__name__)
              
              @app.route('/')
              def index():
                  try:
                      backend_url = os.environ.get('BACKEND_SERVICE_URL', 'http://backend-api-service:3000')
                      response = requests.get(f'{backend_url}/api/status', timeout=5)
                      backend_data = response.json()
                  except Exception as e:
                      backend_data = {'error': str(e)}
                  
                  template = '''
                  <!DOCTYPE html>
                  <html>
                  <head>
                      <title>Python Multi-Tier App</title>
                      <style>
                          body { font-family: Arial; text-align: center; padding: 50px; }
                          .container { max-width: 800px; margin: 0 auto; }
                          h1 { color: #326ce5; }
                          .backend-info { background: #f0f0f0; padding: 20px; margin: 20px 0; }
                      </style>
                  </head>
                  <body>
                      <div class="container">
                          <h1>Python Frontend Application</h1>
                          <p>This is a Python Flask frontend communicating with a Python backend.</p>
                          <div class="backend-info">
                              <h3>Backend API Response:</h3>
                              <pre>{{ backend_data }}</pre>
                          </div>
                      </div>
                  </body>
                  </html>
                  '''
                  return render_template_string(template, backend_data=backend_data)
              
              if __name__ == '__main__':
                  app.run(host='0.0.0.0', port=80)
              EOF
              pip install flask requests
              python frontend.py
          ports:
          - containerPort: 80
          env:
          - name: BACKEND_SERVICE_URL
            value: "http://backend-api-service:3000"


**Deploy 4: Application Health Monitoring**

**app-deployment.yaml**

.. code-block:: yaml

  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: health-monitored-app
  spec:
    replicas: 2
    selector:
      matchLabels:
        app: health-monitored-app
    template:
      metadata:
        labels:
          app: health-monitored-app
      spec:
        containers:
        - name: python-web-app
          image: python:3.12-slim
          command:
            - sh
            - -c
            - |
              cat > health_app.py << 'EOF'
              from flask import Flask, jsonify
              import time
              import os
              from datetime import datetime
              
              app = Flask(__name__)
              start_time = time.time()
              
              @app.route('/')
              def index():
                  return jsonify({
                      'message': 'Python Health Monitoring Demo',
                      'uptime': time.time() - start_time,
                      'pod': os.environ.get('HOSTNAME', 'unknown')
                  })
              
              @app.route('/health')
              def health():
                  # Simulate slow startup
                  if time.time() - start_time < 30:
                      return jsonify({'status': 'starting'}), 503
                  return jsonify({'status': 'healthy'})
              
              @app.route('/ready')
              def ready():
                  # Simulate readiness check
                  if time.time() - start_time < 10:
                      return jsonify({'status': 'not ready'}), 503
                  return jsonify({'status': 'ready'})
              
              if __name__ == '__main__':
                  app.run(host='0.0.0.0', port=80)
              EOF
              pip install flask
              python health_app.py
          ports:
          - containerPort: 80
          # Startup probe - for slow starting applications
          startupProbe:
            httpGet:
              path: /health
              port: 80
            initialDelaySeconds: 10
            periodSeconds: 5
            timeoutSeconds: 3
            failureThreshold: 12  # 60 seconds total
          # Liveness probe - restart unhealthy containers
          livenessProbe:
            httpGet:
              path: /health
              port: 80
            initialDelaySeconds: 30
            periodSeconds: 10
            timeoutSeconds: 5
            failureThreshold: 3
          # Readiness probe - control traffic routing
          readinessProbe:
            httpGet:
              path: /ready
              port: 80
            initialDelaySeconds: 5
            periodSeconds: 5
            timeoutSeconds: 3
            successThreshold: 1
            failureThreshold: 3
          resources:
            requests:
              memory: "64Mi"
              cpu: "50m"
            limits:
              memory: "128Mi"
              cpu: "100m"


**Deploy 5: Resource-Constrained Environment**

**namespace.yaml**

.. code-block:: yaml
    
  apiVersion: v1
  kind: Namespace
  metadata:
    name: resource-limited


**resource-quota.yaml**

.. code-block:: yaml

  apiVersion: v1
  kind: ResourceQuota
  metadata:
    name: compute-quota
    namespace: resource-limited
  spec:
    hard:
      requests.cpu: "2"
      requests.memory: 4Gi
      limits.cpu: "4"
      limits.memory: 8Gi
      pods: "10"


**app-deployment.yaml**

.. code-block:: yaml

  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: resource-managed-app
    namespace: resource-limited
  spec:
    replicas: 3
    selector:
      matchLabels:
        app: resource-managed-app
    template:
      metadata:
        labels:
          app: resource-managed-app
      spec:
        containers:
        - name: python-app
          image: python:3.9-alpine
          command:
            - sh
            - -c
            - |
              cat > simple_app.py << 'EOF'
              from flask import Flask, jsonify
              import psutil
              import os
              
              app = Flask(__name__)
              
              @app.route('/')
              def index():
                  return jsonify({
                      'message': 'Resource-managed Python app',
                      'memory_usage': f"{psutil.virtual_memory().percent}%",
                      'cpu_count': psutil.cpu_count(),
                      'pod': os.environ.get('HOSTNAME', 'unknown')
                  })
              
              if __name__ == '__main__':
                  app.run(host='0.0.0.0', port=80)
              EOF
              pip install flask psutil
              python simple_app.py
          ports:
          - containerPort: 80
          resources:
            requests:
              memory: "128Mi"
              cpu: "100m"
            limits:
              memory: "256Mi"
              cpu: "200m"

====================
Advanced Deployments
====================

**Advanced Deploy 1: Blue-Green Deployment**

**blue-deployment.yaml**

.. code-block:: yaml

  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: app-blue
    labels:
      version: blue
  spec:
    replicas: 3
    selector:
      matchLabels:
        app: myapp
        version: blue
    template:
      metadata:
        labels:
          app: myapp
          version: blue
      spec:
        containers:
        - name: python-app
          image: python:3.12-slim
          command:
            - sh
            - -c
            - |
              cat > blue_app.py << 'EOF'
              from flask import Flask, jsonify
              import os
              
              app = Flask(__name__)
              
              @app.route('/')
              def index():
                  return jsonify({
                      'version': 'BLUE v1.0',
                      'message': 'This is the BLUE version',
                      'pod': os.environ.get('HOSTNAME', 'unknown'),
                      'color': '#0066cc'
                  })
              
              @app.route('/health')
              def health():
                  return jsonify({'status': 'healthy', 'version': 'blue'})
              
              if __name__ == '__main__':
                  app.run(host='0.0.0.0', port=80)
              EOF
              pip install flask
              python blue_app.py
          ports:
          - containerPort: 80


**green-deployment.yaml**

.. code-block:: yaml

  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: app-green
    labels:
      version: green
  spec:
    replicas: 3
    selector:
      matchLabels:
        app: myapp
        version: green
    template:
      metadata:
        labels:
          app: myapp
          version: green
      spec:
        containers:
        - name: python-app
          image: python:3.12-slim
          command:
            - sh
            - -c
            - |
              cat > green_app.py << 'EOF'
              from flask import Flask, jsonify
              import os
              
              app = Flask(__name__)
              
              @app.route('/')
              def index():
                  return jsonify({
                      'version': 'GREEN v2.0',
                      'message': 'This is the GREEN version with new features!',
                      'pod': os.environ.get('HOSTNAME', 'unknown'),
                      'color': '#009900',
                      'features': ['Enhanced API', 'Better performance', 'New endpoints']
                  })
              
              @app.route('/health')
              def health():
                  return jsonify({'status': 'healthy', 'version': 'green'})
              
              @app.route('/api/new-feature')
              def new_feature():
                  return jsonify({'feature': 'This is only available in GREEN version'})
              
              if __name__ == '__main__':
                  app.run(host='0.0.0.0', port=80)
              EOF
              pip install flask
              python green_app.py
          ports:
          - containerPort: 80


**service.yaml**

.. code-block:: yaml

  apiVersion: v1
  kind: Service
  metadata:
    name: app-service
  spec:
    selector:
      app: myapp
      version: blue  # Switch between blue/green
    ports:
    - port: 80
      targetPort: 80
    type: LoadBalancer


**deploy-script.sh**

.. code-block:: bash

  #!/bin/bash
  set -e

  CURRENT_VERSION=$(kubectl get service app-service -o jsonpath='{.spec.selector.version}')
  NEW_VERSION=""

  if [ "$CURRENT_VERSION" = "blue" ]; then
      NEW_VERSION="green"
  else
      NEW_VERSION="blue"
  fi

  echo "Current version: $CURRENT_VERSION"
  echo "Deploying to: $NEW_VERSION"

  # Deploy new version
  kubectl apply -f ${NEW_VERSION}-deployment.yaml

  # Wait for rollout
  kubectl rollout status deployment/app-${NEW_VERSION}

  # Switch traffic
  kubectl patch service app-service -p '{"spec":{"selector":{"version":"'${NEW_VERSION}'"}}}'

  echo "Traffic switched to $NEW_VERSION"
  echo "To rollback, run: kubectl patch service app-service -p '{\"spec\":{\"selector\":{\"version\":\"'${CURRENT_VERSION}'\"}}}''"

**Advanced Deploy 2: Microservices with Service Mesh**

**network-policy.yaml**

.. code-block:: yaml

  apiVersion: networking.k8s.io/v1
  kind: NetworkPolicy
  metadata:
    name: microservices-network-policy
  spec:
    podSelector:
      matchLabels:
        tier: backend
    policyTypes:
    - Ingress
    - Egress
    ingress:
    - from:
      - podSelector:
          matchLabels:
            tier: frontend
      ports:
      - protocol: TCP
        port: 8080
    egress:
    - to:
      - podSelector:
          matchLabels:
            tier: database
      ports:
      - protocol: TCP
        port: 5432

**Advanced Deploy 3: GitOps Pipeline Integration**

**.github/workflows/deploy.yaml**

.. code-block:: yaml

  name: Build and Deploy
  on:
    push:
      branches: [main]

  env:
    REGISTRY: ghcr.io
    IMAGE_NAME: ${{ github.repository }}

  jobs:
    build-and-deploy:
      runs-on: ubuntu-latest
      permissions:
        contents: read
        packages: write

      steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Docker buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=sha,prefix={{branch}}-

      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}

      - name: Setup kubectl
        uses: azure/setup-kubectl@v3
        with:
          version: 'v1.24.0'

      - name: Deploy to Kubernetes
        run: |
          # Update deployment with new image
          kubectl set image deployment/python-web-app web=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }} --record
          
          # Wait for rollout to complete
          kubectl rollout status deployment/python-web-app --timeout=300s
          
          # Verify deployment
          kubectl get pods -l app=python-web-app
          kubectl get services

**validation-script.sh**

.. code-block:: bash

  #!/bin/bash
  set -e

  DEPLOYMENT_NAME="python-web-app"
  TIMEOUT=300

  echo "Validating deployment: $DEPLOYMENT_NAME"

  # Check rollout status
  kubectl rollout status deployment/$DEPLOYMENT_NAME --timeout=${TIMEOUT}s

  # Verify pods are running
  READY_REPLICAS=$(kubectl get deployment $DEPLOYMENT_NAME -o jsonpath='{.status.readyReplicas}')
  DESIRED_REPLICAS=$(kubectl get deployment $DEPLOYMENT_NAME -o jsonpath='{.spec.replicas}')

  if [ "$READY_REPLICAS" != "$DESIRED_REPLICAS" ]; then
      echo "Deployment validation failed: $READY_REPLICAS/$DESIRED_REPLICAS pods ready"
      exit 1
  fi

  # Health check
  SERVICE_URL=$(kubectl get service python-web-app-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  if [ ! -z "$SERVICE_URL" ]; then
      curl -f http://$SERVICE_URL/health || exit 1
  fi

  echo "Deployment validation successful!"


==============
Common Gotchas
==============

**1. ImagePullBackOff Errors**

- Check image name and tag spelling
- Verify registry credentials for private images
- Ensure image exists in the specified registry

**2. CrashLoopBackOff**

- Check application logs: `kubectl logs <pod-name>`
- Verify resource limits aren't too restrictive
- Check liveness probe configuration

**3. Service Discovery Issues**

- Verify Service selector matches Pod labels exactly
- Check that target ports match container ports
- Use `kubectl get endpoints` to verify service backing

**4. Persistent Volume Claims**

- Ensure storage class is available
- Check access modes compatibility
- Verify sufficient storage capacity

**5. Resource Quotas**

- Use `kubectl describe quota` to check current usage
- Ensure resource requests don't exceed quota limits
- Consider using LimitRanges for default values

=========================
Production Considerations
=========================

**Security Best Practices:**

- Use non-root containers when possible
- Implement Pod Security Standards
- Regularly update base images for security patches
- Use Secrets for sensitive data, not ConfigMaps

**Monitoring and Observability:**

- Implement structured logging
- Use Prometheus metrics for monitoring
- Set up alerting for critical failures
- Implement distributed tracing for microservices

**Performance Optimization:**

- Right-size resource requests and limits
- Use horizontal and vertical pod autoscaling
- Implement caching strategies
- Optimize container images for size and startup time

**Disaster Recovery:**

- Backup etcd regularly
- Test restore procedures
- Implement multi-region clusters for critical workloads
- Document runbooks for common failure scenarios
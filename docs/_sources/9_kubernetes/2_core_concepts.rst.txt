#################
9.2 Core Concepts
#################

**Building Production-Ready Applications**

You've successfully deployed your first application to Kubernetes and experienced the basic workflow. Now let's dive deeper into the fundamental building blocks that make Kubernetes powerful: Pods, Deployments, Services, and configuration management.

Understanding these core concepts will enable you to design resilient, scalable applications and prepare you for production deployment strategies in the next chapter.

==================
Pods: Containers++ 
==================

**The Atomic Unit**

A Pod wraps one or more containers that share storage and network. Think of it as a "logical host" for your application.

**Simple Pod:**

.. code-block:: yaml

    apiVersion: v1
    kind: Pod
    metadata:
      name: web-pod
    spec:
      containers:
      - name: web
        image: nginx:latest
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"

.. code-block:: bash

    kubectl apply -f pod.yaml
    kubectl get pods
    kubectl port-forward pod/web-pod 8080:80

**Multi-Container Pod (Sidecar Pattern):**

.. code-block:: yaml

    apiVersion: v1
    kind: Pod
    metadata:
      name: app-with-logging
    spec:
      containers:
      - name: app
        image: my-app:latest
        volumeMounts:
        - name: logs
          mountPath: /app/logs
      - name: log-shipper
        image: fluentd:latest
        volumeMounts:
        - name: logs
          mountPath: /var/log/app
      volumes:
      - name: logs
        emptyDir: {}

**Key Points:**
- Containers in a Pod share IP and storage
- Pods are ephemeral - they come and go
- Usually one container per Pod
- Use multi-container for helper services (logging, monitoring)

==========================
Deployments: Managing Apps
==========================

**Beyond Individual Pods**

Deployments manage multiple Pod replicas, handle updates, and provide self-healing. This is what you'll use 99% of the time.

**Basic Deployment:**

.. code-block:: yaml

    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: web-app
    spec:
      replicas: 3
      selector:
        matchLabels:
          app: web-app
      template:
        metadata:
          labels:
            app: web-app
        spec:
          containers:
          - name: web
            image: nginx:latest
            ports:
            - containerPort: 80
            livenessProbe:
              httpGet:
                path: /
                port: 80
              initialDelaySeconds: 30
            readinessProbe:
              httpGet:
                path: /
                port: 80
              initialDelaySeconds: 5
            resources:
              requests:
                memory: "128Mi"
                cpu: "100m"
              limits:
                memory: "256Mi"
                cpu: "200m"

**Deployment Operations:**

.. code-block:: bash

    # Deploy
    kubectl apply -f deployment.yaml
    
    # Scale
    kubectl scale deployment web-app --replicas=5
    
    # Update
    kubectl set image deployment web-app web=nginx:1.21
    
    # Check rollout
    kubectl rollout status deployment web-app
    
    # Rollback
    kubectl rollout undo deployment web-app

**What Deployments Give You:**
- Multiple replicas for reliability
- Rolling updates with zero downtime
- Automatic restart of failed pods
- Easy scaling up and down
- Rollback to previous versions

===========================
Services: Stable Networking
===========================

**Connecting to Your Apps**

Pods get random IP addresses. Services provide stable endpoints and load balancing across Pod replicas.

**ClusterIP Service (Internal):**

.. code-block:: yaml

    apiVersion: v1
    kind: Service
    metadata:
      name: web-service
    spec:
      selector:
        app: web-app
      ports:
      - port: 80
        targetPort: 80
      type: ClusterIP

**LoadBalancer Service (External):**

.. code-block:: yaml

    apiVersion: v1
    kind: Service
    metadata:
      name: web-service-external
    spec:
      selector:
        app: web-app
      ports:
      - port: 80
        targetPort: 80
      type: LoadBalancer

**Service Discovery:**

.. code-block:: bash

    # Services are accessible by name
    curl http://web-service
    curl http://web-service.default.svc.cluster.local

**Service Types:**
- **ClusterIP**: Internal access only (default)
- **NodePort**: Access via node IP:port
- **LoadBalancer**: Cloud provider load balancer
- **ExternalName**: DNS alias to external service

=========================
ConfigMaps: Configuration
=========================

**Separate Config from Code**

ConfigMaps store configuration data that your apps can consume as environment variables or files.

**Create ConfigMap:**

.. code-block:: yaml

    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: app-config
    data:
      database_host: "postgres.example.com"
      log_level: "info"
      app.properties: |
        server.port=8080
        debug.enabled=false

**Use in Deployment:**

.. code-block:: yaml

    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: web-app
    spec:
      template:
        spec:
          containers:
          - name: web
            image: my-app:latest
            env:
            - name: DATABASE_HOST
              valueFrom:
                configMapKeyRef:
                  name: app-config
                  key: database_host
            - name: LOG_LEVEL
              valueFrom:
                configMapKeyRef:
                  name: app-config
                  key: log_level
            volumeMounts:
            - name: config
              mountPath: /etc/config
          volumes:
          - name: config
            configMap:
              name: app-config

=======================
Secrets: Sensitive Data
=======================

**Passwords, Tokens, Keys**

Secrets are like ConfigMaps but for sensitive data. They're base64 encoded and can be encrypted at rest.

**Create Secret:**

.. code-block:: bash

    # From command line
    kubectl create secret generic app-secrets \
      --from-literal=db_password=supersecret \
      --from-literal=api_key=abc123

**Or from YAML:**

.. code-block:: yaml

    apiVersion: v1
    kind: Secret
    metadata:
      name: app-secrets
    type: Opaque
    data:
      db_password: c3VwZXJzZWNyZXQ=  # base64 encoded
      api_key: YWJjMTIz              # base64 encoded

**Use in Deployment:**

.. code-block:: yaml

    spec:
      containers:
      - name: web
        image: my-app:latest
        env:
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: db_password

===========================
Persistent Volumes: Storage
===========================

**Data That Survives**

For databases and file storage, you need persistent volumes that survive Pod restarts.

**Persistent Volume Claim:**

.. code-block:: yaml

    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: postgres-storage
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 5Gi

**Use in Deployment:**

.. code-block:: yaml

    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: postgres
    spec:
      template:
        spec:
          containers:
          - name: postgres
            image: postgres:13
            env:
            - name: POSTGRES_DB
              value: myapp
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: app-secrets
                  key: db_password
            volumeMounts:
            - name: data
              mountPath: /var/lib/postgresql/data
          volumes:
          - name: data
            persistentVolumeClaim:
              claimName: postgres-storage

================
Complete Example
================

**Web App + Database**

Here's a complete application showing all concepts working together:

.. code-block:: yaml

    # Secret
    apiVersion: v1
    kind: Secret
    metadata:
      name: db-secret
    data:
      password: cGFzc3dvcmQxMjM=
    
    ---
    # ConfigMap
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: app-config
    data:
      database_url: "postgres://user:password@postgres:5432/myapp"
      log_level: "info"
    
    ---
    # Database PVC
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: postgres-pvc
    spec:
      accessModes: [ReadWriteOnce]
      resources:
        requests:
          storage: 1Gi
    
    ---
    # Database Deployment
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
            - name: POSTGRES_DB
              value: myapp
            - name: POSTGRES_USER
              value: user
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: db-secret
                  key: password
            volumeMounts:
            - name: data
              mountPath: /var/lib/postgresql/data
          volumes:
          - name: data
            persistentVolumeClaim:
              claimName: postgres-pvc
    
    ---
    # Database Service
    apiVersion: v1
    kind: Service
    metadata:
      name: postgres
    spec:
      selector:
        app: postgres
      ports:
      - port: 5432
    
    ---
    # Web App Deployment
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: webapp
    spec:
      replicas: 3
      selector:
        matchLabels:
          app: webapp
      template:
        metadata:
          labels:
            app: webapp
        spec:
          containers:
          - name: web
            image: my-webapp:latest
            ports:
            - containerPort: 8080
            env:
            - name: DATABASE_URL
              valueFrom:
                configMapKeyRef:
                  name: app-config
                  key: database_url
            - name: LOG_LEVEL
              valueFrom:
                configMapKeyRef:
                  name: app-config
                  key: log_level
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
    
    ---
    # Web App Service
    apiVersion: v1
    kind: Service
    metadata:
      name: webapp
    spec:
      selector:
        app: webapp
      ports:
      - port: 80
        targetPort: 8080
      type: LoadBalancer

**Deploy Everything:**

.. code-block:: bash

    # Deploy complete stack
    kubectl apply -f complete-app.yaml
    
    # Check status
    kubectl get all
    
    # View logs
    kubectl logs -l app=webapp
    
    # Access the app
    kubectl port-forward service/webapp 8080:80

==================
Essential Commands
==================

**Daily Operations:**

.. code-block:: bash

    # View resources
    kubectl get pods,services,deployments
    kubectl describe deployment webapp
    kubectl logs deployment/webapp
    
    # Manage apps
    kubectl apply -f app.yaml
    kubectl scale deployment webapp --replicas=5
    kubectl set image deployment webapp web=myapp:v2
    
    # Troubleshoot
    kubectl exec -it pod-name -- bash
    kubectl port-forward service/webapp 8080:80
    kubectl get events --sort-by=.metadata.creationTimestamp

============
What's Next?
============

**You're Ready for Production**

You now understand:

- **Pods** - Container groups with shared networking
- **Deployments** - Manage app lifecycle and scaling  
- **Services** - Stable networking and load balancing
- **ConfigMaps** - Configuration management
- **Secrets** - Secure data handling
- **Persistent Volumes** - Stateful storage

Next: Connect these concepts to your CI/CD pipelines for automated production deployments with rolling updates and monitoring.

    **Design Pattern**: Pods enable the sidecar pattern, where auxiliary containers (logging, monitoring, proxies) enhance your main application without modifying its code. This separation of concerns is fundamental to microservices architecture.

===========================================
Deployments: Managing Application Lifecycle
===========================================

**From Docker Compose Services to Kubernetes Deployments**

Docker Compose services manage single instances with basic restart policies. Kubernetes Deployments manage multiple replicas with sophisticated rollout strategies, health monitoring, and automatic recovery.

**Basic Deployment Pattern:**

.. code-block:: yaml

    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: web-app
      labels:
        app: web-app
    spec:
      replicas: 3
      strategy:
        type: RollingUpdate
        rollingUpdate:
          maxSurge: 1
          maxUnavailable: 1
      selector:
        matchLabels:
          app: web-app
      template:
        metadata:
          labels:
            app: web-app
        spec:
          containers:
          - name: web
            image: myapp:v1.2.0
            ports:
            - containerPort: 8080
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
                memory: "256Mi"
                cpu: "250m"
              limits:
                memory: "512Mi"
                cpu: "500m"

**Zero-Downtime Deployments:**

.. code-block:: bash

    # Update deployment with new image version
    kubectl set image deployment/web-app web=myapp:v1.3.0
    
    # Monitor rollout progress
    kubectl rollout status deployment/web-app
    
    # View rollout history
    kubectl rollout history deployment/web-app
    
    # Rollback if needed
    kubectl rollout undo deployment/web-app

**Deployment vs Docker Compose:**

.. list-table::
   :header-rows: 1
   :widths: 30 35 35

   * - Feature
     - Docker Compose
     - Kubernetes Deployment
   * - **Scaling**
     - Manual replica count
     - Declarative with auto-scaling
   * - **Updates**
     - Replace entire stack
     - Rolling updates with rollback
   * - **Health Monitoring**
     - Basic restart policies
     - Liveness & readiness probes
   * - **Resource Management**
     - Limited controls
     - Requests, limits, and quotas
   * - **Self-Healing**
     - Container-level only
     - Pod and node-level recovery

=======================================
Services: Networking and Load Balancing
=======================================

**Beyond Docker Compose Networking**

Docker Compose creates simple networks where services find each other by name. Kubernetes Services provide sophisticated traffic management, load balancing, and service discovery that works across multiple nodes and availability zones.

**Service Types Explained:**

.. code-block:: yaml

    # ClusterIP - Internal cluster access only
    apiVersion: v1
    kind: Service
    metadata:
      name: web-app-internal
    spec:
      type: ClusterIP
      selector:
        app: web-app
      ports:
      - port: 80
        targetPort: 8080

    ---
    # LoadBalancer - External access with cloud integration
    apiVersion: v1
    kind: Service
    metadata:
      name: web-app-external
    spec:
      type: LoadBalancer
      selector:
        app: web-app
      ports:
      - port: 80
        targetPort: 8080

    ---
    # NodePort - Access via any node's IP
    apiVersion: v1
    kind: Service
    metadata:
      name: web-app-nodeport
    spec:
      type: NodePort
      selector:
        app: web-app
      ports:
      - port: 80
        targetPort: 8080
        nodePort: 30080

**Advanced Service Configuration:**

.. code-block:: yaml

    apiVersion: v1
    kind: Service
    metadata:
      name: web-app-advanced
      annotations:
        service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
        service.beta.kubernetes.io/aws-load-balancer-ssl-cert: "arn:aws:acm:..."
    spec:
      type: LoadBalancer
      selector:
        app: web-app
      ports:
      - name: http
        port: 80
        targetPort: 8080
      - name: https
        port: 443
        targetPort: 8080
      sessionAffinity: ClientIP
      sessionAffinityConfig:
        clientIP:
          timeoutSeconds: 10800

**Service Discovery in Action:**

.. code-block:: yaml

    # Frontend deployment accessing backend service
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: frontend
    spec:
      replicas: 2
      selector:
        matchLabels:
          app: frontend
      template:
        metadata:
          labels:
            app: frontend
        spec:
          containers:
          - name: frontend
            image: frontend:latest
            env:
            - name: BACKEND_URL
              value: "http://backend:80/api"  # Service discovery by name
            - name: DATABASE_URL
              value: "postgresql://database:5432/myapp"

======================
ConfigMaps and Secrets
======================

**Configuration Management Done Right**

Docker Compose uses environment files and bind mounts for configuration. Kubernetes provides ConfigMaps for non-sensitive data and Secrets for passwords, tokens, and certificates - with encryption, rotation, and fine-grained access control.

**ConfigMap Examples:**

.. code-block:: yaml

    # Application configuration
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: app-config
    data:
      app.properties: |
        server.port=8080
        logging.level=INFO
        feature.enabled=true
      nginx.conf: |
        server {
          listen 80;
          location / {
            proxy_pass http://backend:8080;
          }
        }

    ---
    # Using ConfigMap in deployment
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: web-app
    spec:
      template:
        spec:
          containers:
          - name: web
            image: myapp:latest
            env:
            - name: SERVER_PORT
              valueFrom:
                configMapKeyRef:
                  name: app-config
                  key: server.port
            volumeMounts:
            - name: config-volume
              mountPath: /etc/config
          volumes:
          - name: config-volume
            configMap:
              name: app-config

**Secrets Management:**

.. code-block:: yaml

    # Create secret for database credentials
    apiVersion: v1
    kind: Secret
    metadata:
      name: db-credentials
    type: Opaque
    data:
      username: bXl1c2Vy  # base64 encoded 'myuser'
      password: bXlwYXNz  # base64 encoded 'mypass'

    ---
    # Use secret in deployment
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: web-app
    spec:
      template:
        spec:
          containers:
          - name: web
            image: myapp:latest
            env:
            - name: DB_USERNAME
              valueFrom:
                secretKeyRef:
                  name: db-credentials
                  key: username
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: db-credentials
                  key: password

**Creating Secrets from Command Line:**

.. code-block:: bash

    # Create secret from literal values
    kubectl create secret generic api-keys \
      --from-literal=github-token=ghp_xxxxxxxxxxxx \
      --from-literal=stripe-key=sk_test_xxxxxxxxxxxx

    # Create secret from files
    kubectl create secret generic tls-certs \
      --from-file=tls.crt=./server.crt \
      --from-file=tls.key=./server.key

    # Create docker registry secret for private images
    kubectl create secret docker-registry my-registry \
      --docker-server=myregistry.io \
      --docker-username=myuser \
      --docker-password=mypassword \
      --docker-email=email@example.com

==============================
Persistent Volumes and Storage
==============================

**Stateful Applications in Kubernetes**

Docker Compose handles volumes simply - bind mounts and named volumes work locally. Kubernetes storage spans multiple nodes and cloud providers, requiring understanding of Persistent Volumes, Storage Classes, and StatefulSets.

**Storage Concepts:**

.. list-table::
   :header-rows: 1
   :widths: 25 35 40

   * - Concept
     - Purpose
     - Use Case
   * - **Volume**
     - Pod-level storage
     - Temporary data, configuration files
   * - **Persistent Volume**
     - Cluster-level storage resource
     - Databases, file uploads, logs
   * - **Storage Class**
     - Dynamic volume provisioning
     - Different performance tiers
   * - **StatefulSet**
     - Ordered, stable deployments
     - Databases, messaging systems

**Persistent Volume Claim Example:**

.. code-block:: yaml

    # Storage class for SSD volumes
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: fast-ssd
    provisioner: kubernetes.io/aws-ebs
    parameters:
      type: gp3
      iops: "3000"
      encrypted: "true"

    ---
    # Persistent volume claim
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: database-storage
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 20Gi
      storageClassName: fast-ssd

    ---
    # StatefulSet using persistent storage
    apiVersion: apps/v1
    kind: StatefulSet
    metadata:
      name: postgresql
    spec:
      serviceName: postgresql
      replicas: 1
      selector:
        matchLabels:
          app: postgresql
      template:
        metadata:
          labels:
            app: postgresql
        spec:
          containers:
          - name: postgresql
            image: postgres:15
            env:
            - name: POSTGRES_DB
              value: myapp
            - name: POSTGRES_USER
              valueFrom:
                secretKeyRef:
                  name: db-credentials
                  key: username
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: db-credentials
                  key: password
            volumeMounts:
            - name: postgresql-storage
              mountPath: /var/lib/postgresql/data
          volumes:
          - name: postgresql-storage
            persistentVolumeClaim:
              claimName: database-storage

==================================
Namespaces and Resource Management
==================================

**Multi-Tenancy and Environment Separation**

Docker Compose projects are isolated by directory. Kubernetes namespaces provide true multi-tenancy with resource quotas, network policies, and RBAC - essential for teams, environments, and cost management.

**Namespace Strategy:**

.. code-block:: yaml

    # Development environment namespace
    apiVersion: v1
    kind: Namespace
    metadata:
      name: development
      labels:
        environment: dev
        team: backend

    ---
    # Resource quota for development
    apiVersion: v1
    kind: ResourceQuota
    metadata:
      name: dev-quota
      namespace: development
    spec:
      hard:
        requests.cpu: "4"
        requests.memory: 8Gi
        limits.cpu: "8"
        limits.memory: 16Gi
        persistentvolumeclaims: "10"
        services.loadbalancers: "2"

    ---
    # Network policy for namespace isolation
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: deny-all
      namespace: development
    spec:
      podSelector: {}
      policyTypes:
      - Ingress
      - Egress

**Best Practices for Resource Management:**

.. code-block:: yaml

    # Production deployment with proper resource management
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: web-app
      namespace: production
    spec:
      replicas: 5
      template:
        spec:
          containers:
          - name: web
            image: myapp:v1.2.0
            resources:
              requests:
                memory: "512Mi"
                cpu: "500m"
              limits:
                memory: "1Gi"
                cpu: "1000m"
            livenessProbe:
              httpGet:
                path: /health
                port: 8080
              initialDelaySeconds: 30
              timeoutSeconds: 10
              failureThreshold: 3
            readinessProbe:
              httpGet:
                path: /ready
                port: 8080
              initialDelaySeconds: 10
              timeoutSeconds: 5
              failureThreshold: 3

**Environment-Based Deployment Patterns:**

.. code-block:: bash

    # Deploy to different environments
    kubectl apply -f manifests/ -n development
    kubectl apply -f manifests/ -n staging
    kubectl apply -f manifests/ -n production
    
    # Different configurations per environment
    kubectl create configmap app-config \
      --from-file=config/development/ \
      -n development
    
    kubectl create configmap app-config \
      --from-file=config/production/ \
      -n production

=============================================
Putting It All Together: Complete Application
=============================================

**Real-World Application Deployment**

Let's deploy a complete application stack that demonstrates all the concepts we've covered, showing how they work together in a production-like scenario.

.. code-block:: yaml

    # Complete application manifest
    # Namespace
    apiVersion: v1
    kind: Namespace
    metadata:
      name: webapp-prod

    ---
    # ConfigMap
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: app-config
      namespace: webapp-prod
    data:
      redis.conf: |
        maxmemory 256mb
        maxmemory-policy allkeys-lru
      app.properties: |
        server.port=8080
        redis.host=redis
        database.host=postgres

    ---
    # Secret
    apiVersion: v1
    kind: Secret
    metadata:
      name: app-secrets
      namespace: webapp-prod
    type: Opaque
    data:
      db-password: c3VwZXJzZWNyZXQ=
      api-key: YWJjZGVmZ2hpams=

    ---
    # PostgreSQL StatefulSet
    apiVersion: apps/v1
    kind: StatefulSet
    metadata:
      name: postgres
      namespace: webapp-prod
    spec:
      serviceName: postgres
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
            image: postgres:15
            env:
            - name: POSTGRES_DB
              value: webapp
            - name: POSTGRES_USER
              value: webapp
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: app-secrets
                  key: db-password
            volumeMounts:
            - name: postgres-data
              mountPath: /var/lib/postgresql/data
      volumeClaimTemplates:
      - metadata:
          name: postgres-data
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 10Gi

    ---
    # Redis Deployment
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: redis
      namespace: webapp-prod
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: redis
      template:
        metadata:
          labels:
            app: redis
        spec:
          containers:
          - name: redis
            image: redis:7-alpine
            command: ["redis-server", "/etc/redis/redis.conf"]
            volumeMounts:
            - name: redis-config
              mountPath: /etc/redis
          volumes:
          - name: redis-config
            configMap:
              name: app-config

    ---
    # Web Application Deployment
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: webapp
      namespace: webapp-prod
    spec:
      replicas: 3
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
        spec:
          containers:
          - name: webapp
            image: mywebapp:v1.2.0
            ports:
            - containerPort: 8080
            env:
            - name: DATABASE_URL
              value: "postgresql://webapp:$(DB_PASSWORD)@postgres:5432/webapp"
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: app-secrets
                  key: db-password
            - name: API_KEY
              valueFrom:
                secretKeyRef:
                  name: app-secrets
                  key: api-key
            volumeMounts:
            - name: app-config
              mountPath: /etc/webapp
            resources:
              requests:
                memory: "256Mi"
                cpu: "250m"
              limits:
                memory: "512Mi"
                cpu: "500m"
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
              initialDelaySeconds: 10
              periodSeconds: 5
          volumes:
          - name: app-config
            configMap:
              name: app-config

    ---
    # Services
    apiVersion: v1
    kind: Service
    metadata:
      name: postgres
      namespace: webapp-prod
    spec:
      selector:
        app: postgres
      ports:
      - port: 5432

    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: redis
      namespace: webapp-prod
    spec:
      selector:
        app: redis
      ports:
      - port: 6379

    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: webapp
      namespace: webapp-prod
    spec:
      type: LoadBalancer
      selector:
        app: webapp
      ports:
      - port: 80
        targetPort: 8080

**Deploy and Manage:**

.. code-block:: bash

    # Deploy the complete application
    kubectl apply -f webapp-complete.yaml
    
    # Monitor deployment progress
    kubectl get all -n webapp-prod
    kubectl rollout status deployment/webapp -n webapp-prod
    
    # Check application health
    kubectl logs -f deployment/webapp -n webapp-prod
    kubectl get events -n webapp-prod --sort-by=.metadata.creationTimestamp
    
    # Scale the application
    kubectl scale deployment webapp --replicas=5 -n webapp-prod
    
    # Update the application
    kubectl set image deployment/webapp webapp=mywebapp:v1.3.0 -n webapp-prod

#####################################
11.7 Google Kubernetes Engine (GKE)
#####################################

.. note::

    Google Kubernetes Engine (GKE) is a managed Kubernetes service that makes it easy to deploy, manage, and scale containerized applications using Google's infrastructure. GKE provides a production-ready environment for deploying containerized applications with automatic upgrades, auto-repair, and built-in monitoring.

============
GKE Overview
============

**Why GKE?**

- **Fully Managed**: Google manages the control plane
- **Auto-Upgrade**: Automatic Kubernetes version upgrades
- **Auto-Repair**: Automatic node health monitoring and repair
- **Auto-Scaling**: Cluster and pod autoscaling
- **Integrated Logging**: Cloud Logging and Monitoring integration
- **Security**: Built-in security features and compliance
- **Multi-Zone**: High availability across zones
- **Workload Identity**: Secure access to Google Cloud services

**GKE vs Self-Managed Kubernetes:**

+----------------------------+------------------+-------------------------+
| Feature                    | GKE              | Self-Managed            |
+============================+==================+=========================+
| Control Plane Management   | Fully managed    | Manual                  |
+----------------------------+------------------+-------------------------+
| Upgrades                   | Automatic        | Manual                  |
+----------------------------+------------------+-------------------------+
| Node Repair                | Automatic        | Manual                  |
+----------------------------+------------------+-------------------------+
| Monitoring                 | Built-in         | Setup required          |
+----------------------------+------------------+-------------------------+
| Cost                       | Pay for nodes    | Pay for all             |
+----------------------------+------------------+-------------------------+

**GKE Modes:**

- **Standard Mode**: Full control over cluster configuration
- **Autopilot Mode**: Google manages entire infrastructure (recommended for most users)

=============
Prerequisites
=============

**Enable Required APIs:**

.. code-block:: bash

    # Enable GKE API
    gcloud services enable container.googleapis.com
    
    # Enable Artifact Registry (for container images)
    gcloud services enable artifactregistry.googleapis.com
    
    # Set default region and zone
    gcloud config set compute/region us-central1
    gcloud config set compute/zone us-central1-a

**Install kubectl:**

.. code-block:: bash

    # Install kubectl with gcloud
    gcloud components install kubectl
    
    # Verify installation
    kubectl version --client
    
    # Or install standalone (Linux)
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

=====================
Creating GKE Clusters
=====================

**Create Standard Cluster (Quick Start):**

.. code-block:: bash

    # Create a basic cluster
    gcloud container clusters create my-cluster \
        --zone us-central1-a \
        --num-nodes 3
    
    # Get cluster credentials
    gcloud container clusters get-credentials my-cluster \
        --zone us-central1-a
    
    # Verify connection
    kubectl get nodes

**Create Autopilot Cluster (Recommended):**

.. code-block:: bash

    # Create Autopilot cluster
    gcloud container clusters create-auto my-autopilot-cluster \
        --region us-central1
    
    # Get credentials
    gcloud container clusters get-credentials my-autopilot-cluster \
        --region us-central1
    
    # Verify
    kubectl get nodes

**Create Production-Ready Cluster:**

.. code-block:: bash

    # Create cluster with best practices
    gcloud container clusters create production-cluster \
        --zone us-central1-a \
        --num-nodes 3 \
        --machine-type n1-standard-4 \
        --disk-size 50 \
        --disk-type pd-standard \
        --enable-autoscaling \
        --min-nodes 3 \
        --max-nodes 10 \
        --enable-autorepair \
        --enable-autoupgrade \
        --enable-ip-alias \
        --network "default" \
        --subnetwork "default" \
        --enable-stackdriver-kubernetes \
        --addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver \
        --workload-pool=PROJECT_ID.svc.id.goog \
        --enable-shielded-nodes \
        --release-channel regular

**Cluster Configuration Options:**

- **--machine-type**: Node machine type (n1-standard-2, e2-medium, etc.)
- **--num-nodes**: Initial number of nodes per zone
- **--enable-autoscaling**: Enable cluster autoscaler
- **--min-nodes / --max-nodes**: Autoscaling limits
- **--enable-autorepair**: Automatic node repair
- **--enable-autoupgrade**: Automatic Kubernetes upgrades
- **--release-channel**: Update channel (rapid, regular, stable)

======================
Deploying Applications
======================

**Deploy Simple Application:**

.. code-block:: bash

    # Create deployment
    kubectl create deployment hello-web \
        --image=gcr.io/google-samples/hello-app:1.0
    
    # Verify deployment
    kubectl get deployments
    kubectl get pods
    
    # Expose deployment as a service
    kubectl expose deployment hello-web \
        --type LoadBalancer \
        --port 80 \
        --target-port 8080
    
    # Get external IP (may take a few minutes)
    kubectl get service hello-web --watch
    
    # Once EXTERNAL-IP is assigned, test the application
    curl http://EXTERNAL_IP

**Deploy with YAML Manifest:**

.. code-block:: yaml

    # deployment.yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: nginx-deployment
      labels:
        app: nginx
    spec:
      replicas: 3
      selector:
        matchLabels:
          app: nginx
      template:
        metadata:
          labels:
            app: nginx
        spec:
          containers:
          - name: nginx
            image: nginx:1.25
            ports:
            - containerPort: 80
            resources:
              requests:
                memory: "64Mi"
                cpu: "250m"
              limits:
                memory: "128Mi"
                cpu: "500m"
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: nginx-service
    spec:
      type: LoadBalancer
      selector:
        app: nginx
      ports:
      - protocol: TCP
        port: 80
        targetPort: 80

.. code-block:: bash

    # Apply manifest
    kubectl apply -f deployment.yaml
    
    # Check status
    kubectl get deployments
    kubectl get pods
    kubectl get services
    
    # View logs
    kubectl logs -l app=nginx
    
    # Describe resources
    kubectl describe deployment nginx-deployment
    kubectl describe service nginx-service

==========================
Working with Custom Images
==========================

**Build and Deploy Custom Application:**

.. code-block:: bash

    # Create application directory
    mkdir my-gke-app
    cd my-gke-app
    
    # Create simple Node.js app
    cat > server.js << 'EOF'
    const express = require('express');
    const app = express();
    const PORT = process.env.PORT || 8080;
    
    app.get('/', (req, res) => {
      res.json({
        message: 'Hello from GKE!',
        hostname: require('os').hostname(),
        version: process.env.APP_VERSION || '1.0.0'
      });
    });
    
    app.get('/health', (req, res) => {
      res.json({ status: 'healthy' });
    });
    
    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
    EOF
    
    # Create package.json
    cat > package.json << 'EOF'
    {
      "name": "my-gke-app",
      "version": "1.0.0",
      "main": "server.js",
      "scripts": {
        "start": "node server.js"
      },
      "dependencies": {
        "express": "^4.18.2"
      }
    }
    EOF
    
    # Create Dockerfile
    cat > Dockerfile << 'EOF'
    FROM node:18-slim
    WORKDIR /app
    COPY package*.json ./
    RUN npm install --production
    COPY . .
    EXPOSE 8080
    CMD ["npm", "start"]
    EOF

**Build and Push to Artifact Registry:**

.. code-block:: bash

    # Create Artifact Registry repository
    gcloud artifacts repositories create my-repo \
        --repository-format=docker \
        --location=us-central1 \
        --description="Docker repository"
    
    # Configure Docker authentication
    gcloud auth configure-docker us-central1-docker.pkg.dev
    
    # Build and push image
    IMAGE=us-central1-docker.pkg.dev/PROJECT_ID/my-repo/my-gke-app:v1
    
    docker build -t $IMAGE .
    docker push $IMAGE

**Deploy Custom Image:**

.. code-block:: yaml

    # deployment-custom.yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: my-gke-app
    spec:
      replicas: 3
      selector:
        matchLabels:
          app: my-gke-app
      template:
        metadata:
          labels:
            app: my-gke-app
        spec:
          containers:
          - name: my-gke-app
            image: us-central1-docker.pkg.dev/PROJECT_ID/my-repo/my-gke-app:v1
            ports:
            - containerPort: 8080
            env:
            - name: APP_VERSION
              value: "1.0.0"
            resources:
              requests:
                memory: "128Mi"
                cpu: "100m"
              limits:
                memory: "256Mi"
                cpu: "200m"
            livenessProbe:
              httpGet:
                path: /health
                port: 8080
              initialDelaySeconds: 10
              periodSeconds: 10
            readinessProbe:
              httpGet:
                path: /health
                port: 8080
              initialDelaySeconds: 5
              periodSeconds: 5
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: my-gke-app-service
    spec:
      type: LoadBalancer
      selector:
        app: my-gke-app
      ports:
      - protocol: TCP
        port: 80
        targetPort: 8080

.. code-block:: bash

    # Deploy application
    kubectl apply -f deployment-custom.yaml
    
    # Watch deployment progress
    kubectl rollout status deployment/my-gke-app
    
    # Get service URL
    kubectl get service my-gke-app-service

======================
ConfigMaps and Secrets
======================

**Create ConfigMap:**

.. code-block:: bash

    # Create ConfigMap from literals
    kubectl create configmap app-config \
        --from-literal=APP_NAME=MyApp \
        --from-literal=ENVIRONMENT=production
    
    # Create ConfigMap from file
    echo "log_level=info" > config.properties
    kubectl create configmap app-config-file \
        --from-file=config.properties
    
    # View ConfigMap
    kubectl get configmap app-config -o yaml

**Use ConfigMap in Deployment:**

.. code-block:: yaml

    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: app-config
    data:
      APP_NAME: "MyApp"
      ENVIRONMENT: "production"
      LOG_LEVEL: "info"
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: app-with-config
    spec:
      replicas: 2
      selector:
        matchLabels:
          app: myapp
      template:
        metadata:
          labels:
            app: myapp
        spec:
          containers:
          - name: myapp
            image: nginx:1.25
            envFrom:
            - configMapRef:
                name: app-config
            # Or mount as volume
            volumeMounts:
            - name: config-volume
              mountPath: /etc/config
          volumes:
          - name: config-volume
            configMap:
              name: app-config

**Create and Use Secrets:**

.. code-block:: bash

    # Create secret from literals
    kubectl create secret generic db-credentials \
        --from-literal=username=admin \
        --from-literal=password=secretpassword123
    
    # Create secret from file
    echo -n 'my-secret-key' > api-key.txt
    kubectl create secret generic api-secret \
        --from-file=api-key.txt
    
    # View secret (encoded)
    kubectl get secret db-credentials -o yaml

**Use Secret in Deployment:**

.. code-block:: yaml

    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: app-with-secrets
    spec:
      replicas: 2
      selector:
        matchLabels:
          app: myapp
      template:
        metadata:
          labels:
            app: myapp
        spec:
          containers:
          - name: myapp
            image: myapp:1.0
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
            # Or mount as volume
            volumeMounts:
            - name: secret-volume
              mountPath: /etc/secrets
              readOnly: true
          volumes:
          - name: secret-volume
            secret:
              secretName: db-credentials

====================
Scaling Applications
====================

**Manual Scaling:**

.. code-block:: bash

    # Scale deployment
    kubectl scale deployment nginx-deployment --replicas=5
    
    # Verify scaling
    kubectl get deployments
    kubectl get pods

**Horizontal Pod Autoscaler (HPA):**

.. code-block:: bash

    # Create HPA based on CPU usage
    kubectl autoscale deployment nginx-deployment \
        --cpu-percent=50 \
        --min=3 \
        --max=10
    
    # View HPA status
    kubectl get hpa
    kubectl describe hpa nginx-deployment

**HPA with YAML:**

.. code-block:: yaml

    apiVersion: autoscaling/v2
    kind: HorizontalPodAutoscaler
    metadata:
      name: nginx-hpa
    spec:
      scaleTargetRef:
        apiVersion: apps/v1
        kind: Deployment
        name: nginx-deployment
      minReplicas: 3
      maxReplicas: 10
      metrics:
      - type: Resource
        resource:
          name: cpu
          target:
            type: Utilization
            averageUtilization: 50
      - type: Resource
        resource:
          name: memory
          target:
            type: Utilization
            averageUtilization: 80

**Cluster Autoscaler:**

.. code-block:: bash

    # Enable cluster autoscaler (if not already enabled)
    gcloud container clusters update my-cluster \
        --enable-autoscaling \
        --min-nodes 3 \
        --max-nodes 10 \
        --zone us-central1-a
    
    # Update node pool autoscaling
    gcloud container node-pools update default-pool \
        --cluster=my-cluster \
        --enable-autoscaling \
        --min-nodes=3 \
        --max-nodes=10 \
        --zone=us-central1-a

==================
Persistent Storage
==================

**Create Persistent Volume Claim:**

.. code-block:: yaml

    # pvc.yaml
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: my-pvc
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 10Gi
      storageClassName: standard-rwo

**Use PVC in Deployment:**

.. code-block:: yaml

    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: app-with-storage
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: myapp
      template:
        metadata:
          labels:
            app: myapp
        spec:
          containers:
          - name: myapp
            image: nginx:1.25
            volumeMounts:
            - name: data-volume
              mountPath: /data
          volumes:
          - name: data-volume
            persistentVolumeClaim:
              claimName: my-pvc

.. code-block:: bash

    # Apply PVC and deployment
    kubectl apply -f pvc.yaml
    kubectl apply -f deployment-with-storage.yaml
    
    # Verify PVC
    kubectl get pvc
    kubectl describe pvc my-pvc

==========================
Ingress and Load Balancing
==========================

**Create Ingress:**

.. code-block:: yaml

    # ingress.yaml
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: my-ingress
      annotations:
        kubernetes.io/ingress.class: "gce"
        kubernetes.io/ingress.global-static-ip-name: "web-static-ip"
    spec:
      rules:
      - host: myapp.example.com
        http:
          paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-gke-app-service
                port:
                  number: 80
      - host: api.example.com
        http:
          paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: api-service
                port:
                  number: 80

**Setup with TLS:**

.. code-block:: bash

    # Create TLS secret
    kubectl create secret tls my-tls-secret \
        --cert=path/to/cert.crt \
        --key=path/to/cert.key

.. code-block:: yaml

    # ingress-tls.yaml
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: my-ingress-tls
    spec:
      tls:
      - hosts:
        - myapp.example.com
        secretName: my-tls-secret
      rules:
      - host: myapp.example.com
        http:
          paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-gke-app-service
                port:
                  number: 80

==========
Namespaces
==========

**Create and Use Namespaces:**

.. code-block:: bash

    # Create namespace
    kubectl create namespace development
    kubectl create namespace staging
    kubectl create namespace production
    
    # List namespaces
    kubectl get namespaces
    
    # Deploy to specific namespace
    kubectl apply -f deployment.yaml -n development
    
    # Set default namespace
    kubectl config set-context --current --namespace=development
    
    # View resources in namespace
    kubectl get all -n development
    
    # Delete namespace (deletes all resources)
    kubectl delete namespace development

======================
Monitoring and Logging
======================

**View Logs:**

.. code-block:: bash

    # View pod logs
    kubectl logs pod-name
    
    # View logs from specific container
    kubectl logs pod-name -c container-name
    
    # Stream logs
    kubectl logs -f pod-name
    
    # View logs from all pods with label
    kubectl logs -l app=nginx
    
    # View previous container logs
    kubectl logs pod-name --previous

**Monitoring with Cloud Console:**

- Navigate to Kubernetes Engine → Workloads
- Click on a workload to view details
- View CPU, Memory, and Network metrics
- Access Cloud Monitoring for advanced metrics

**Check Resource Usage:**

.. code-block:: bash

    # View node resource usage
    kubectl top nodes
    
    # View pod resource usage
    kubectl top pods
    
    # View pod resource usage in specific namespace
    kubectl top pods -n development

==================
Cluster Management
==================

**List Clusters:**

.. code-block:: bash

    # List all clusters
    gcloud container clusters list
    
    # Describe cluster
    gcloud container clusters describe my-cluster \
        --zone us-central1-a

**Update Cluster:**

.. code-block:: bash

    # Update cluster to specific Kubernetes version
    gcloud container clusters upgrade my-cluster \
        --zone us-central1-a \
        --cluster-version 1.28.3-gke.1203000
    
    # Update node pool
    gcloud container node-pools upgrade default-pool \
        --cluster my-cluster \
        --zone us-central1-a

**Resize Cluster:**

.. code-block:: bash

    # Resize node pool
    gcloud container clusters resize my-cluster \
        --num-nodes 5 \
        --zone us-central1-a

**Add Node Pool:**

.. code-block:: bash

    # Create new node pool
    gcloud container node-pools create high-mem-pool \
        --cluster my-cluster \
        --zone us-central1-a \
        --machine-type n1-highmem-4 \
        --num-nodes 2 \
        --enable-autoscaling \
        --min-nodes 2 \
        --max-nodes 8

**Delete Cluster:**

.. code-block:: bash

    # Delete cluster
    gcloud container clusters delete my-cluster \
        --zone us-central1-a

===============
Rolling Updates
===============

**Update Deployment Image:**

.. code-block:: bash

    # Update image
    kubectl set image deployment/nginx-deployment \
        nginx=nginx:1.26
    
    # Watch rollout status
    kubectl rollout status deployment/nginx-deployment
    
    # View rollout history
    kubectl rollout history deployment/nginx-deployment
    
    # Rollback to previous version
    kubectl rollout undo deployment/nginx-deployment
    
    # Rollback to specific revision
    kubectl rollout undo deployment/nginx-deployment --to-revision=2

**Rolling Update Strategy:**

.. code-block:: yaml

    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: nginx-deployment
    spec:
      replicas: 5
      strategy:
        type: RollingUpdate
        rollingUpdate:
          maxSurge: 1        # Max pods above desired count
          maxUnavailable: 1  # Max pods unavailable during update
      selector:
        matchLabels:
          app: nginx
      template:
        metadata:
          labels:
            app: nginx
        spec:
          containers:
          - name: nginx
            image: nginx:1.25

==============
Best Practices
==============

**1. Cluster Design:**

- Use Autopilot mode for simplified management
- Enable auto-upgrade and auto-repair
- Use regional clusters for high availability
- Implement proper node pool sizing
- Use preemptible nodes for cost savings on non-critical workloads

**2. Application Design:**

- Use health checks (liveness and readiness probes)
- Set resource requests and limits
- Design stateless applications when possible
- Use init containers for initialization tasks
- Implement graceful shutdown

**3. Security:**

- Enable Workload Identity for service authentication
- Use namespaces to isolate workloads
- Implement Network Policies
- Use private clusters when possible
- Regularly update Kubernetes versions
- Use Binary Authorization for image validation

**4. Resource Management:**

- Define resource requests and limits
- Use Horizontal Pod Autoscaler
- Enable cluster autoscaling
- Use node affinity and taints/tolerations
- Implement pod disruption budgets

**5. Monitoring and Logging:**

- Use Cloud Monitoring and Logging
- Set up alerts for critical metrics
- Use structured logging
- Monitor resource usage regularly
- Implement distributed tracing

===============
Troubleshooting
===============

**Common Issues:**

**1. Pods Not Starting:**

.. code-block:: bash

    # Check pod status
    kubectl get pods
    kubectl describe pod POD_NAME
    
    # Check events
    kubectl get events --sort-by=.metadata.creationTimestamp
    
    # Check logs
    kubectl logs POD_NAME

**2. Service Not Accessible:**

.. code-block:: bash

    # Check service
    kubectl get services
    kubectl describe service SERVICE_NAME
    
    # Check endpoints
    kubectl get endpoints SERVICE_NAME
    
    # Verify pod labels match service selector
    kubectl get pods --show-labels

**3. Node Issues:**

.. code-block:: bash

    # Check node status
    kubectl get nodes
    kubectl describe node NODE_NAME
    
    # Check node conditions
    kubectl get nodes -o json | jq '.items[].status.conditions'

**4. Resource Issues:**

.. code-block:: bash

    # Check resource usage
    kubectl top nodes
    kubectl top pods
    
    # Check resource requests and limits
    kubectl describe node NODE_NAME

=======
Cleanup
=======

.. code-block:: bash

    # Delete all resources in namespace
    kubectl delete all --all -n my-namespace
    
    # Delete specific resources
    kubectl delete deployment nginx-deployment
    kubectl delete service nginx-service
    kubectl delete ingress my-ingress
    
    # Delete namespace
    kubectl delete namespace my-namespace
    
    # Delete cluster
    gcloud container clusters delete my-cluster --zone us-central1-a

====================
Additional Resources
====================

- GKE Documentation: https://cloud.google.com/kubernetes-engine/docs
- Kubernetes Documentation: https://kubernetes.io/docs/
- GKE Best Practices: https://cloud.google.com/kubernetes-engine/docs/best-practices
- Kubectl Cheat Sheet: https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- GKE Samples: https://github.com/GoogleCloudPlatform/kubernetes-engine-samples

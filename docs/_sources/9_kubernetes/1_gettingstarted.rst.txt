###################
9.1 Getting Started
###################

**From Theory to Practice**

Now that you understand what Kubernetes is and why it matters for production applications, let's get hands-on. In this section, you'll set up a local cluster and deploy your first application, experiencing the power of container orchestration firsthand.

By the end of this section, you'll have Kubernetes running locally and understand the basic workflow for deploying applications - setting the foundation for the more advanced concepts in subsequent chapters.

===========
Quick Setup
===========

**Install the Tools**

We'll use Docker Desktop's built-in Kubernetes for the simplest setup:

*Enable Kubernetes in Docker Desktop:*

1. Open Docker Desktop Settings
2. Go to Kubernetes tab  
3. Check "Enable Kubernetes"
4. Click "Apply & Restart"

*Verify Installation:*

.. code-block:: bash

    kubectl cluster-info
    kubectl get nodes

You should see your cluster running with one node.

=====================
Deploy Your First App
=====================

**From docker run to kubectl**

Remember running containers with Docker? Kubernetes is similar but more powerful:

.. code-block:: bash

    # Instead of: docker run -p 8080:80 nginx
    # Use Kubernetes:
    
    # 1. Create a deployment
    kubectl create deployment web --image=nginx
    
    # 2. Expose it as a service
    kubectl expose deployment web --port=80 --type=NodePort
    
    # 3. Access your app
    kubectl port-forward service/web 8080:80

Open http://localhost:8080 - you're running nginx on Kubernetes!

======================
Infrastructure as Code
======================

**YAML Manifests**

Instead of commands, use YAML files to define your applications:

**Create web-app.yaml:**

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
    
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: web-app-service
    spec:
      selector:
        app: web-app
      ports:
      - port: 80
        targetPort: 80
      type: LoadBalancer

**Deploy it:**

.. code-block:: bash

    kubectl apply -f web-app.yaml
    kubectl get all

==================
Essential Commands
==================

**Your Daily Kubernetes Toolkit**

.. code-block:: bash

    # View everything
    kubectl get all
    
    # Check pod details
    kubectl describe pod <pod-name>
    
    # See logs
    kubectl logs <pod-name>
    
    # Get inside a container
    kubectl exec -it <pod-name> -- bash
    
    # Scale your app
    kubectl scale deployment web-app --replicas=5
    
    # Update image
    kubectl set image deployment web-app web=nginx:1.21

===================
From Docker Compose
===================

**Migrating Your Applications**

If you have a Docker Compose app, here's how it translates:

**Docker Compose:**

.. code-block:: yaml

    services:
      web:
        image: myapp:latest
        ports:
          - "8080:8080"
      db:
        image: postgres:13
        environment:
          POSTGRES_DB: myapp

**Kubernetes:**

.. code-block:: yaml

    # Web deployment
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: web
    spec:
      replicas: 2
      selector:
        matchLabels:
          app: web
      template:
        metadata:
          labels:
            app: web
        spec:
          containers:
          - name: web
            image: myapp:latest
            ports:
            - containerPort: 8080
    
    ---
    # Web service
    apiVersion: v1
    kind: Service
    metadata:
      name: web
    spec:
      selector:
        app: web
      ports:
      - port: 80
        targetPort: 8080
    
    ---
    # Database deployment
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: db
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: db
      template:
        metadata:
          labels:
            app: db
        spec:
          containers:
          - name: postgres
            image: postgres:13
            env:
            - name: POSTGRES_DB
              value: myapp

============
What's Next?
============

**You're Ready to Build**

You now know how to:
- Deploy applications to Kubernetes
- Use YAML manifests for infrastructure as code
- Scale and manage applications
- Migrate from Docker Compose

Next, we'll explore Kubernetes core concepts: Pods, Services, ConfigMaps, and Secrets. You'll learn to build production-ready applications with proper configuration management and health checks.

**Try This:**
Deploy one of your containerized applications from Chapter 8 using the patterns you just learned!
- May not support all Kubernetes features
- Performance can be impacted on resource-constrained machines

.. note::

    **Migration Path:** Docker Desktop Kubernetes is perfect for learning and development. When you're ready for production-like environments, you can use the same kubectl commands and YAML manifests with managed Kubernetes services like EKS, GKE, or AKS.

===============
Rancher Desktop
===============

**Container Management with Kubernetes First**

Rancher Desktop takes a different approach - it's designed around Kubernetes rather than Docker, while still supporting Docker workflows. This makes it excellent for teams transitioning from Docker-focused to Kubernetes-focused development.

**Installation:**

Download from: https://rancherdesktop.io/
    

**Key Advantages:**

- **Container runtime choice** - Switch between containerd and dockerd
- **Kubernetes distributions** - Choose from different K8s versions
- **Resource management** - Better control over CPU and memory allocation
- **Volume mounting** - Improved file sharing between host and containers

===============================
Essential kubectl Configuration
===============================

**Your Command Center for Kubernetes**

``kubectl`` is to Kubernetes what ``docker`` is to containers - your primary interface for all cluster operations. Understanding kubectl is essential for effective Kubernetes development and operations.

**Initial Setup and Context Management:**

.. code-block:: bash

    # View all available contexts
    kubectl config get-contexts
    
    # Switch between different clusters
    kubectl config use-context docker-desktop
    kubectl config use-context kind-development
    
    # Set default namespace to avoid repetitive -n flags
    kubectl config set-context --current --namespace=development

**Essential kubectl Commands for DevOps:**

.. code-block:: bash

    # Cluster information and health
    kubectl cluster-info
    kubectl get nodes
    kubectl top nodes  # Requires metrics-server
    
    # Application deployment and management
    kubectl apply -f manifests/
    kubectl get deployments,services,pods
    kubectl describe deployment web-app
    kubectl logs -f deployment/web-app
    
    # Troubleshooting and debugging
    kubectl get events --sort-by=.metadata.creationTimestamp
    kubectl exec -it pod/web-app-xxx -- /bin/bash
    kubectl port-forward service/web-app 8080:80

**Creating kubectl Aliases for Productivity:**

.. code-block:: bash

    # Add to ~/.bashrc or ~/.zshrc
    alias k=kubectl
    alias kgp='kubectl get pods'
    alias kgs='kubectl get services'
    alias kgd='kubectl get deployments'
    alias kdp='kubectl describe pod'
    alias kaf='kubectl apply -f'
    alias kdel='kubectl delete'

===========================================
From Docker Compose to Kubernetes Manifests
===========================================

**Translating Your Container Knowledge**

Your Docker Compose skills translate directly to Kubernetes, but with additional capabilities for production environments. Let's take a real application from the containers chapter and deploy it to Kubernetes.

**Docker Compose Recap (from Chapter 8):**

.. code-block:: yaml

    # docker-compose.yml
    version: '3.8'
    services:
      web:
        image: webapp:latest
        ports:
          - "8080:8080"
        environment:
          - DATABASE_URL=postgresql://user:pass@db:5432/myapp
        depends_on:
          - db
          - redis
      
      db:
        image: postgres:15
        environment:
          - POSTGRES_DB=myapp
          - POSTGRES_USER=user
          - POSTGRES_PASSWORD=pass
        volumes:
          - db_data:/var/lib/postgresql/data
      
      redis:
        image: redis:7-alpine
        ports:
          - "6379:6379"

**Kubernetes Equivalent:**

.. code-block:: yaml

    # web-deployment.yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: web-app
      labels:
        app: web-app
    spec:
      replicas: 3  # Scale beyond single container
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
            image: webapp:latest
            ports:
            - containerPort: 8080
            env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: db-secret
                  key: database-url
            - name: REDIS_URL
              value: "redis://redis:6379"
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

    ---
    # web-service.yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: web-app
    spec:
      selector:
        app: web-app
      ports:
      - port: 80
        targetPort: 8080
      type: LoadBalancer

**Key Differences from Docker Compose:**

- **Explicit resource management** - Define CPU and memory requirements
- **Health checks** - Built-in liveness and readiness probes
- **Scaling** - Multiple replicas distribute load and provide redundancy
- **Secret management** - Secure handling of sensitive configuration
- **Service discovery** - Automatic DNS resolution between services

================================
Integrating with CI/CD Pipelines
================================

**Connecting Your Pipeline to Kubernetes**

Your CI/CD pipelines from Chapter 7 can deploy directly to Kubernetes, creating a complete automation workflow from code commit to production deployment.

**GitHub Actions Kubernetes Deployment:**

.. code-block:: yaml

    # .github/workflows/deploy-k8s.yml
    name: Deploy to Kubernetes
    on:
      push:
        branches: [main]
    
    jobs:
      deploy:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          
          - name: Build and push container
            run: |
              docker build -t webapp:${{ github.sha }} .
              echo ${{ secrets.DOCKER_PASSWORD }} | docker login -u ${{ secrets.DOCKER_USERNAME }} --password-stdin
              docker push webapp:${{ github.sha }}
          
          - name: Set up kubectl
            uses: azure/setup-kubectl@v3
            with:
              version: 'v1.29.0'
          
          - name: Configure kubectl
            run: |
              echo "${{ secrets.KUBE_CONFIG }}" | base64 -d > ~/.kube/config
          
          - name: Update deployment image
            run: |
              kubectl set image deployment/web-app web=webapp:${{ github.sha }}
              kubectl rollout status deployment/web-app
          
          - name: Verify deployment
            run: |
              kubectl get services
              kubectl get pods

**Development Workflow Integration:**

.. code-block:: bash

    # Local development script
    #!/bin/bash
    # deploy-local.sh
    
    # Build container from current code
    docker build -t webapp:dev .
    
    # Load into KIND cluster
    kind load docker-image webapp:dev --name development
    
    # Update Kubernetes deployment
    kubectl set image deployment/web-app web=webapp:dev
    
    # Follow deployment progress
    kubectl rollout status deployment/web-app
    
    # Show application logs
    kubectl logs -f deployment/web-app

=============================
Troubleshooting and Debugging
=============================

**Essential Skills for Kubernetes Operations**

Kubernetes troubleshooting requires different approaches than traditional debugging. The distributed nature means issues can occur at multiple layers: infrastructure, cluster, node, or application level.

**Common Issues and Solutions:**

.. code-block:: bash

    # Pod won't start - check events and logs
    kubectl describe pod <pod-name>
    kubectl logs <pod-name> --previous  # Previous container logs
    
    # Service not accessible - verify endpoints
    kubectl get endpoints
    kubectl describe service <service-name>
    
    # Image pull problems - check secrets and registries
    kubectl get secrets
    kubectl describe pod <pod-name> | grep -A 10 Events
    
    # Resource constraints - check node capacity
    kubectl top nodes
    kubectl describe node <node-name>

**Health Check Setup:**

.. code-block:: yaml

    # Add to deployment spec
    livenessProbe:
      httpGet:
        path: /health
        port: 8080
      initialDelaySeconds: 30
      periodSeconds: 10
      timeoutSeconds: 5
      failureThreshold: 3
    
    readinessProbe:
      httpGet:
        path: /ready
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 5

This foundation prepares you for the advanced Kubernetes concepts covered in the following sections, including production deployments, GitOps workflows, and cluster management.
    kubectl [flags] [options]

    Use "kubectl <command> --help" for more information about a given command.
    Use "kubectl options" for a list of global command-line options (applies to all commands).


Verify the cluster with the following command.

.. code-block:: bash

    kubectl get nodes
    NAME             STATUS   ROLES           AGE    VERSION
    docker-desktop   Ready    control-plane   6m2s   v1.25.4

The ``kubectl`` configuration file is called config and lives in a hidden directory called ``kube`` in your home directory ``$HOME/.kube/config``. We normally call it the ``kubeconfig`` file, and it contains definitions for

    #. Clusters
    #. Users (credentials)
    #. Contexts

You can view your ``kubeconfig`` using the ``kubectl`` config view command. 

.. code-block:: bash

    kubectl config view
    apiVersion: v1
    clusters:
    - cluster:
        certificate-authority-data: DATA+OMITTED
        server: https://kubernetes.docker.internal:6443
    name: docker-desktop
    contexts:
    - context:
        cluster: docker-desktop
        user: docker-desktop
    name: docker-desktop
    current-context: docker-desktop
    kind: Config
    preferences: {}
    users:
    - name: docker-desktop
    user:
        client-certificate-data: REDACTED
        client-key-data: REDACTED

You can use ``kubectl`` config current-context to see your current context. The following example shows a system where ``kubectl`` is configured to use the cluster and user-defined in a context called docker-desktop.

.. code-block:: bash

    kubectl config current-context
    docker-desktop

Run a ``kubectl`` explain pods command to list all possible Pod attributes.

.. code-block:: bash

    kubectl explain pods --recursive
    KIND:     Pod
    VERSION:  v1

    DESCRIPTION:
        Pod is a collection of containers that can run on a host. This resource is
        created by clients and scheduled onto hosts.

    FIELDS:
    apiVersion   <string>
    kind <string>
    metadata     <Object>
        annotations       <map[string]string>
        creationTimestamp <string>
        deletionGracePeriodSeconds        <integer>
        deletionTimestamp <string>
        finalizers        <[]string>
        generateName      <string>
        generation        <integer>
        labels    <map[string]string>
        managedFields     <[]Object>
            apiVersion     <string>
            fieldsType     <string>
            fieldsV1       <map[string]>
            manager        <string>
            operation      <string>
            subresource    <string>
            time   <string>
        name      <string>
        namespace <string>
        ownerReferences   <[]Object>
            apiVersion     <string>
            blockOwnerDeletion     <boolean>
            controller     <boolean>
            kind   <string>
            name   <string>
            uid    <string>
        resourceVersion   <string>
        selfLink  <string>
        uid       <string>
    spec <Object>

To find out more about different attributes, you can use

.. code-block:: bash

    kubectl explain pod.spec

======================
Is there a better way?
======================

Using ``kubectl`` to create deployment is perfect but for debugging and testing purposes, it is not the best way to do it. 

We use better cli tools, like ``k9s``

.. code-block:: bash

    brew install derailed/k9s/k9s

Run ``k9s``

.. code-block:: bash

    k9s

==============================
Creating our first hello world
==============================

We've used the Python Fast API application in the previous chapter. We will use it again to create our first hello world application.

.. code-block:: bash

    fastapi/
    ├── Dockerfile
    ├── requirements.txt
    └── app
        ├── __init__.py
        └── main.py
    └──k8s
        └── Chart.yaml
        └── values.yaml
        └── templates
            └── deployment.yaml
            └── service.yaml

==========
Next Steps
==========

Congratulations! You've successfully:

- Set up a local Kubernetes cluster
- Deployed your first application using both imperative commands and declarative YAML
- Learned essential kubectl commands for daily operations
- Migrated a Docker Compose application to Kubernetes

You now have hands-on experience with Kubernetes basics, but we've only scratched the surface. The commands and YAML files you've used contain powerful concepts like Pods, Deployments, and Services that deserve deeper exploration.

In the next chapter, we'll dive into these core concepts, understanding not just the "how" but the "why" behind each component. This foundation will be crucial as we progress to production deployment strategies and advanced Kubernetes features.

.. code-block:: python
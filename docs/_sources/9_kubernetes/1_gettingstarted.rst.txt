###################
9.1 Getting Started
###################

**From Theory to Practice**

Now that you understand what Kubernetes is and why it matters for production applications, let's get hands-on. In this section, you'll set up a local cluster and deploy your first application, experiencing the power of container orchestration firsthand.

===================
Learning Objectives
===================

**By the end of this section, you will:**

1. Set up a local Kubernetes cluster using Docker Desktop
2. Understand the basic Kubernetes architecture and key components
3. Deploy applications using kubectl commands and YAML manifests
4. Transition smoothly from Docker containers to Kubernetes pods
5. Troubleshoot common deployment issues
6. Verify and validate your Kubernetes deployments

=============
Prerequisites
=============

**Before You Begin**

Ensure you have completed:
- Chapter 8: Containerization with Docker
- Basic understanding of YAML syntax
- Terminal/command line comfort

**Required Tools:**
- Docker Desktop (or Rancher Desktop as alternative)
- Terminal access
- Text editor or IDE

========================
Understanding the Basics
========================

**Key Kubernetes Concepts**

Before diving into commands, let's understand the fundamental building blocks:

- **Cluster:** Your complete Kubernetes environment (like a data center)
- **Node:** A machine (physical or virtual) in your cluster that runs containers
- **Pod:** The smallest deployable unit - contains one or more containers that share storage and network
- **Deployment:** Manages multiple pod replicas and handles updates
- **Service:** Provides stable network access to pods (like a load balancer)
- **Namespace:** Virtual clusters within your physical cluster for organization

**The Container-to-Pod Journey:**

Think of it this way:
- Docker runs **containers**
- Kubernetes runs **pods** (which contain containers)
- A pod is like a "wrapper" around your container with additional Kubernetes features

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

    # Check kubectl is installed and cluster is running
    kubectl version --client
    kubectl cluster-info
    kubectl get nodes

You should see your cluster running with one node.

*Complete Setup Verification:*

.. code-block:: bash

    # Verify all system pods are running
    kubectl get pods --all-namespaces
    
    # Check Docker resources
    docker system df
    
    # Test basic functionality
    kubectl create deployment test-nginx --image=nginx
    kubectl get deployments
    kubectl delete deployment test-nginx

===================
Common Setup Issues
===================

**Troubleshooting Your Installation**

If you encounter issues, here are the most common problems and solutions:

**Kubectl command not found:**

.. code-block:: bash

    # On macOS with Homebrew
    brew install kubectl
    
    # On Windows, ensure kubectl is in your PATH
    # Check Docker Desktop settings: General > "Add the *.docker.internal names to the host's /etc/hosts file"

**Cluster not starting:**

.. code-block:: bash

    # Reset Kubernetes in Docker Desktop
    # Settings > Kubernetes > Reset Kubernetes Cluster
    
    # Check Docker is running and has enough resources
    # Minimum: 2GB RAM, 2 CPU cores

**Pods stuck in Pending state:**

.. code-block:: bash

    kubectl describe pod <pod-name>
    # Look for resource constraints or image pull errors
    
    # Check node resources
    kubectl describe nodes

**Service not accessible:**

.. code-block:: bash

    kubectl get endpoints
    kubectl describe service <service-name>
    
    # Verify port-forward is working
    kubectl port-forward service/<service-name> 8080:80

=====================
Deploy Your First App
=====================

**From docker run to kubectl**

Let's start with what you know from Docker and gradually transition to Kubernetes:

**Step 1: The Docker Way (Review)**

.. code-block:: bash

    # What you learned in Chapter 8
    docker run -d -p 8080:80 nginx
    docker ps

**Step 2: The Kubernetes Pod Way**

.. code-block:: bash

    # Create a single pod (closest to docker run)
    kubectl run nginx-pod --image=nginx --port=80
    
    # Check the pod status
    kubectl get pods
    
    # Access the pod directly
    kubectl port-forward pod/nginx-pod 8080:80

**Step 3: The Production Way (Deployments)**

.. code-block:: bash

    # Create a deployment (manages multiple pods)
    kubectl create deployment web --image=nginx
    
    # Expose it as a service
    kubectl expose deployment web --port=80 --type=NodePort
    
    # Access your app
    kubectl port-forward service/web 8080:80

Open http://localhost:8080 - you're running nginx on Kubernetes!

**Understanding the Progression:**

- **Pod:** Single container instance (like docker run)
- **Deployment:** Manages multiple pods with scaling and updates
- **Service:** Provides stable network access to pods

**Checkpoint: Verify Your Progress**

.. code-block:: bash

    # Check everything is running
    kubectl get all
    
    # See the pod details
    kubectl describe pod <pod-name>
    
    # Check the service
    kubectl get services

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

========================
Check Your Understanding
========================

**Self-Assessment Questions:**

1. What's the difference between a Pod and a Deployment?
2. How would you scale your application to 5 replicas?
3. What command shows you the logs of all pods in a deployment?
4. How do you update your application to a new image version?

**Practice Exercise:**

Try to deploy a simple web application with the following requirements:
- Use the ``httpd:latest`` image
- Scale it to 3 replicas
- Expose it on port 8080
- Verify it's working by accessing the service

**Solutions:**

.. code-block:: bash

    # 1. Pod vs Deployment: Pods are single instances, Deployments manage multiple pods
    # 2. Scale to 5 replicas:
    kubectl scale deployment web --replicas=5
    
    # 3. Show deployment logs:
    kubectl logs deployment/web
    
    # 4. Update image:
    kubectl set image deployment/web nginx=nginx:1.21

==================
What's Coming Next
==================

**Chapter 9.2: Core Concepts**

- Deep dive into Pods, Services, and Deployments
- ConfigMaps and Secrets for configuration management
- Namespaces for resource organization

**Chapter 9.3: Production Deployment**

- Ingress controllers and load balancing
- Health checks and monitoring
- Resource quotas and limits
- May not support all Kubernetes features
- Performance can be impacted on resource-constrained machines

.. note::

    **Migration Path:** Docker Desktop Kubernetes is perfect for learning and development. When you're ready for production-like environments, you can use the same kubectl commands and YAML manifests with managed Kubernetes services like EKS, GKE, or AKS.

=======================
Using Better Tools: k9s
=======================

**Enhanced Cluster Management**

While ``kubectl`` is essential, ``k9s`` provides a more intuitive interface for debugging and monitoring:

.. code-block:: bash

    # Install k9s
    brew install derailed/k9s/k9s
    
    # Run k9s
    k9s

``k9s`` gives you a real-time dashboard to:
- View all resources in your cluster
- Monitor pod logs and events
- Edit resources in place
- Navigate between namespaces easily

==========
Next Steps
==========

Congratulations! You've successfully:

- Set up a local Kubernetes cluster
- Deployed your first application using both imperative commands and declarative YAML
- Learned essential kubectl commands for daily operations
- Migrated from Docker containers to Kubernetes pods

You now have hands-on experience with Kubernetes basics, but we've only scratched the surface. The commands and YAML files you've used contain powerful concepts like Pods, Deployments, and Services that deserve deeper exploration.

In the next chapter, we'll dive into these core concepts, understanding not just the "how" but the "why" behind each component. This foundation will be crucial as we progress to production deployment strategies and advanced Kubernetes features.
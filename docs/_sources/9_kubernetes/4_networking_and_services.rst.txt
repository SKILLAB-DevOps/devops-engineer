###########################
9.4 Networking and Services
###########################

**Connecting Applications in Kubernetes**

Kubernetes networking enables pods to communicate with each other and external clients through Services, Ingress, and Network Policies.

========
Services
========

**Stable Network Endpoints**

Services provide stable IP addresses and DNS names for accessing pods.

**ClusterIP Service (Internal)**

.. code-block:: yaml

    # Internal service for database
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
      type: ClusterIP  # Default type

**NodePort Service (External Access)**

.. code-block:: yaml

    # External access via node ports
    apiVersion: v1
    kind: Service
    metadata:
      name: webapp-nodeport
    spec:
      selector:
        app: webapp
      ports:
      - port: 80
        targetPort: 8080
        nodePort: 30080
      type: NodePort

**LoadBalancer Service (Cloud)**

.. code-block:: yaml

    # Cloud load balancer
    apiVersion: v1
    kind: Service
    metadata:
      name: webapp-lb
    spec:
      selector:
        app: webapp
      ports:
      - port: 80
        targetPort: 8080
      type: LoadBalancer

=======
Ingress
=======

**HTTP/HTTPS Routing**

Ingress manages external access to services with advanced routing capabilities.

.. code-block:: yaml

    # Basic ingress
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: webapp-ingress
      annotations:
        nginx.ingress.kubernetes.io/rewrite-target: /
    spec:
      rules:
      - host: myapp.example.com
        http:
          paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: webapp-service
                port:
                  number: 80

**HTTPS with TLS**

.. code-block:: yaml

    # HTTPS ingress
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: secure-ingress
      annotations:
        cert-manager.io/cluster-issuer: "letsencrypt-prod"
    spec:
      tls:
      - hosts:
        - myapp.example.com
        secretName: myapp-tls
      rules:
      - host: myapp.example.com
        http:
          paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: webapp-service
                port:
                  number: 80

================
Network Policies
================

**Traffic Control**

Network Policies control traffic flow between pods for security.

.. code-block:: yaml

    # Deny all ingress traffic by default
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: deny-all
      namespace: production
    spec:
      podSelector: {}
      policyTypes:
      - Ingress

.. code-block:: yaml

    # Allow specific traffic
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: allow-frontend-to-backend
      namespace: production
    spec:
      podSelector:
        matchLabels:
          app: backend
      policyTypes:
      - Ingress
      ingress:
      - from:
        - podSelector:
            matchLabels:
              app: frontend
        ports:
        - protocol: TCP
          port: 8080

=========================
DNS and Service Discovery
=========================

**Automatic DNS**

Kubernetes provides automatic DNS for service discovery:

.. code-block:: bash

    # Service DNS patterns
    <service-name>.<namespace>.svc.cluster.local
    
    # Examples
    postgres-service.production.svc.cluster.local
    webapp-service.default.svc.cluster.local
    
    # Short forms (same namespace)
    postgres-service
    webapp-service

**Service Discovery Example**

.. code-block:: yaml

    # App connecting to database
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: webapp
    spec:
      template:
        spec:
          containers:
          - name: app
            image: webapp:latest
            env:
            - name: DATABASE_URL
              value: "postgres://user:pass@postgres-service:5432/mydb"

=================
Headless Services
=================

**Direct Pod Access**

Headless services return pod IPs directly instead of service IP.

.. code-block:: yaml

    # Headless service for StatefulSet
    apiVersion: v1
    kind: Service
    metadata:
      name: postgres-headless
    spec:
      clusterIP: None  # Makes it headless
      selector:
        app: postgres
      ports:
      - port: 5432

**Benefits:**
- Direct pod-to-pod communication
- Required for StatefulSets
- Service discovery for individual pods

==================
Essential Commands
==================

.. code-block:: bash

    # Services
    kubectl get services
    kubectl describe service webapp-service
    kubectl get endpoints webapp-service
    
    # Ingress
    kubectl get ingress
    kubectl describe ingress webapp-ingress
    
    # Network Policies
    kubectl get networkpolicies
    kubectl describe networkpolicy deny-all
    
    # DNS testing
    kubectl run test-pod --image=busybox --rm -it -- sh
    nslookup postgres-service
    
    # Port forwarding for testing
    kubectl port-forward service/webapp-service 8080:80

============
What's Next?
============

Next, we'll explore **Storage and Persistence** to manage data for your applications.

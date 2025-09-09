#########################
9.16 Advanced Networking
#########################

**Deep Dive into Kubernetes Networking Architecture**

This chapter covers advanced networking concepts, CNI plugins, network policies, and service discovery mechanisms in Kubernetes.

===================
CNI Plugin Overview
===================

**Container Network Interface (CNI)**

CNI is a specification for configuring network interfaces in Linux containers. Kubernetes uses CNI plugins to provide networking capabilities.

**CNI Plugin Responsibilities**

- **IP Address Management (IPAM)**: Assign IP addresses to pods
- **Network Configuration**: Configure network interfaces
- **Route Management**: Set up routing between pods and nodes
- **Network Policies**: Implement network security rules
- **Service Load Balancing**: Distribute traffic across endpoints

===================
Popular CNI Plugins
===================

**Calico - Feature-Rich Networking**

.. code-block:: bash

    # Install Calico
    kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
    
    # Download custom resources
    curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml -O
    
    # Apply custom resources
    kubectl create -f custom-resources.yaml

**Calico Configuration**

.. code-block:: yaml

    # Calico IPPool configuration
    apiVersion: projectcalico.org/v3
    kind: IPPool
    metadata:
      name: default-ipv4-ippool
    spec:
      cidr: 192.168.0.0/16
      ipipMode: Always
      natOutgoing: true
      nodeSelector: all()

**Flannel - Simple Overlay Network**

.. code-block:: bash

    # Install Flannel
    kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

**Flannel Configuration**

.. code-block:: yaml

    # Flannel DaemonSet configuration
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: kube-flannel-cfg
      namespace: kube-flannel
    data:
      cni-conf.json: |
        {
          "name": "cbr0",
          "cniVersion": "0.3.1",
          "plugins": [
            {
              "type": "flannel",
              "delegate": {
                "hairpinMode": true,
                "isDefaultGateway": true
              }
            },
            {
              "type": "portmap",
              "capabilities": {
                "portMappings": true
              }
            }
          ]
        }
      net-conf.json: |
        {
          "Network": "10.244.0.0/16",
          "Backend": {
            "Type": "vxlan"
          }
        }

**Weave Net - Automatic Discovery**

.. code-block:: bash

    # Install Weave Net
    kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

**Weave Configuration**

.. code-block:: yaml

    # Weave Net with encryption
    apiVersion: apps/v1
    kind: DaemonSet
    metadata:
      name: weave-net
      namespace: kube-system
    spec:
      template:
        spec:
          containers:
          - name: weave
            image: weaveworks/weave-kube:2.8.1
            env:
            - name: WEAVE_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: weave-passwd
                  key: weave-passwd
            resources:
              requests:
                cpu: 10m

==========================
Network Policies Deep Dive
==========================

**Default Deny All Policy**

.. code-block:: yaml

    # Deny all ingress traffic
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: deny-all-ingress
      namespace: production
    spec:
      podSelector: {}
      policyTypes:
      - Ingress

**Advanced Network Policy Examples**

.. code-block:: yaml

    # Multi-tier application network policy
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: web-app-policy
      namespace: production
    spec:
      podSelector:
        matchLabels:
          tier: web
      policyTypes:
      - Ingress
      - Egress
      ingress:
      # Allow traffic from load balancer
      - from:
        - namespaceSelector:
            matchLabels:
              name: ingress-nginx
        ports:
        - protocol: TCP
          port: 8080
      # Allow traffic from same namespace
      - from:
        - namespaceSelector:
            matchLabels:
              name: production
          podSelector:
            matchLabels:
              tier: api
        ports:
        - protocol: TCP
          port: 8080
      egress:
      # Allow DNS resolution
      - to: []
        ports:
        - protocol: UDP
          port: 53
      # Allow database access
      - to:
        - podSelector:
            matchLabels:
              tier: database
        ports:
        - protocol: TCP
          port: 5432

**Namespace-based Network Policies**

.. code-block:: yaml

    # Allow cross-namespace communication
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: allow-cross-namespace
      namespace: backend
    spec:
      podSelector:
        matchLabels:
          app: api-server
      policyTypes:
      - Ingress
      ingress:
      - from:
        - namespaceSelector:
            matchLabels:
              environment: production
        - namespaceSelector:
            matchLabels:
              environment: staging
        ports:
        - protocol: TCP
          port: 8080

==============================
Ingress Controllers Comparison
==============================

**NGINX Ingress Controller**

.. code-block:: bash

    # Install NGINX Ingress Controller
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

.. code-block:: yaml

    # NGINX Ingress with advanced features
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: webapp-ingress
      annotations:
        nginx.ingress.kubernetes.io/ssl-redirect: "true"
        nginx.ingress.kubernetes.io/use-regex: "true"
        nginx.ingress.kubernetes.io/rewrite-target: /$2
        nginx.ingress.kubernetes.io/rate-limit: "100"
        nginx.ingress.kubernetes.io/rate-limit-window: "1m"
        nginx.ingress.kubernetes.io/enable-cors: "true"
        nginx.ingress.kubernetes.io/cors-allow-methods: "GET, POST, OPTIONS"
    spec:
      tls:
      - hosts:
        - webapp.example.com
        secretName: webapp-tls
      rules:
      - host: webapp.example.com
        http:
          paths:
          - path: /api(/|$)(.*)
            pathType: Prefix
            backend:
              service:
                name: api-service
                port:
                  number: 8080
          - path: /(.*)
            pathType: Prefix
            backend:
              service:
                name: web-service
                port:
                  number: 80

**Traefik Ingress Controller**

.. code-block:: bash

    # Install Traefik
    helm repo add traefik https://traefik.github.io/charts
    helm install traefik traefik/traefik

.. code-block:: yaml

    # Traefik IngressRoute
    apiVersion: traefik.containo.us/v1alpha1
    kind: IngressRoute
    metadata:
      name: webapp-route
    spec:
      entryPoints:
      - websecure
      routes:
      - match: Host(`webapp.example.com`) && PathPrefix(`/api`)
        kind: Rule
        services:
        - name: api-service
          port: 8080
        middlewares:
        - name: rate-limit
      - match: Host(`webapp.example.com`)
        kind: Rule
        services:
        - name: web-service
          port: 80
      tls:
        certResolver: letsencrypt

**Istio Gateway vs Traditional Ingress**

.. code-block:: yaml

    # Istio Gateway
    apiVersion: networking.istio.io/v1beta1
    kind: Gateway
    metadata:
      name: webapp-gateway
    spec:
      selector:
        istio: ingressgateway
      servers:
      - port:
          number: 443
          name: https
          protocol: HTTPS
        tls:
          mode: SIMPLE
          credentialName: webapp-cert
        hosts:
        - webapp.example.com

=========================
Load Balancing Strategies
=========================

**Service Load Balancing Types**

.. code-block:: yaml

    # ClusterIP with session affinity
    apiVersion: v1
    kind: Service
    metadata:
      name: webapp-service
    spec:
      type: ClusterIP
      sessionAffinity: ClientIP
      sessionAffinityConfig:
        clientIP:
          timeoutSeconds: 10800
      selector:
        app: webapp
      ports:
      - port: 80
        targetPort: 8080

.. code-block:: yaml

    # LoadBalancer with external traffic policy
    apiVersion: v1
    kind: Service
    metadata:
      name: webapp-lb
      annotations:
        service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
        service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
    spec:
      type: LoadBalancer
      externalTrafficPolicy: Local
      selector:
        app: webapp
      ports:
      - port: 80
        targetPort: 8080

**Advanced Load Balancing with EndpointSlices**

.. code-block:: yaml

    # Custom EndpointSlice for advanced routing
    apiVersion: discovery.k8s.io/v1
    kind: EndpointSlice
    metadata:
      name: webapp-endpoints
      labels:
        kubernetes.io/service-name: webapp-service
    addressType: IPv4
    endpoints:
    - addresses:
      - "10.1.2.3"
      conditions:
        ready: true
        serving: true
        terminating: false
      zone: "us-west-2a"
      hints:
        forZones:
        - name: "us-west-2a"
    ports:
    - name: http
      port: 8080
      protocol: TCP

=========================
DNS and Service Discovery
=========================

**CoreDNS Configuration**

.. code-block:: yaml

    # CoreDNS ConfigMap
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: coredns
      namespace: kube-system
    data:
      Corefile: |
        .:53 {
            errors
            health {
                lameduck 5s
            }
            ready
            kubernetes cluster.local in-addr.arpa ip6.arpa {
                pods insecure
                fallthrough in-addr.arpa ip6.arpa
                ttl 30
            }
            prometheus :9153
            forward . /etc/resolv.conf {
                max_concurrent 1000
            }
            cache 30
            loop
            reload
            loadbalance
        }

**Custom DNS Entries**

.. code-block:: yaml

    # Add custom DNS entries
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: coredns-custom
      namespace: kube-system
    data:
      custom.server: |
        custom.local:53 {
            errors
            cache 30
            forward . 8.8.8.8 9.9.9.9
        }

**Headless Services for Service Discovery**

.. code-block:: yaml

    # Headless service for StatefulSet
    apiVersion: v1
    kind: Service
    metadata:
      name: database-headless
    spec:
      clusterIP: None
      selector:
        app: database
      ports:
      - port: 5432
        targetPort: 5432

=======================
Network Debugging Tools
=======================

**Network Troubleshooting Pod**

.. code-block:: yaml

    # Debug pod with networking tools
    apiVersion: v1
    kind: Pod
    metadata:
      name: network-debug
    spec:
      containers:
      - name: debug
        image: nicolaka/netshoot
        command: ["/bin/bash"]
        args: ["-c", "while true; do ping localhost; sleep 60;done"]
        securityContext:
          capabilities:
            add: ["NET_ADMIN"]

**Network Testing Commands**

.. code-block:: bash

    # Test connectivity
    kubectl exec -it network-debug -- nslookup kubernetes.default
    kubectl exec -it network-debug -- curl -I http://webapp-service
    kubectl exec -it network-debug -- traceroute webapp-service
    
    # Test DNS resolution
    kubectl exec -it network-debug -- dig @10.96.0.10 webapp-service.default.svc.cluster.local
    
    # Network policy testing
    kubectl exec -it network-debug -- nc -zv api-service 8080
    
    # Check routing
    kubectl exec -it network-debug -- ip route
    kubectl exec -it network-debug -- iptables -L

==================
Essential Commands
==================

.. code-block:: bash

    # CNI and networking
    kubectl get nodes -o wide
    kubectl describe node <node-name>
    kubectl get pods -o wide
    
    # Network policies
    kubectl get networkpolicies
    kubectl describe networkpolicy <policy-name>
    
    # Services and endpoints
    kubectl get services
    kubectl get endpoints
    kubectl get endpointslices
    
    # Ingress
    kubectl get ingress
    kubectl describe ingress <ingress-name>
    
    # DNS debugging
    kubectl exec -it <pod> -- nslookup <service-name>
    kubectl logs -n kube-system -l k8s-app=kube-dns
    
    # CNI plugin logs (node-level)
    journalctl -u kubelet | grep CNI
    ls /etc/cni/net.d/
    
    # Calico specific
    kubectl get ippools
    kubectl get bgppeers
    calicoctl node status

===============================
Network Security Best Practices
===============================

**1. Implement Default Deny Policies**

.. code-block:: yaml

    # Default deny all traffic
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: default-deny-all
    spec:
      podSelector: {}
      policyTypes:
      - Ingress
      - Egress

**2. Secure Inter-Namespace Communication**

.. code-block:: yaml

    # Allow only specific namespace communication
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: allow-specific-namespace
    spec:
      podSelector: {}
      ingress:
      - from:
        - namespaceSelector:
            matchLabels:
              name: trusted-namespace

**3. Encrypt Network Traffic**

.. code-block:: bash

    # Enable WireGuard with Calico
    kubectl patch felixconfiguration default --type='merge' -p='{"spec":{"wireguardEnabled":true}}'

============
What's Next?
============

Next, we'll enhance existing chapters with missing content, starting with **External Secrets Operator** in Configuration Management.

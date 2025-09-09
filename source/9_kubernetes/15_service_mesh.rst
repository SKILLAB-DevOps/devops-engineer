#################
9.15 Service Mesh
#################

**Advanced Traffic Management and Security for Microservices**

Service mesh provides a dedicated infrastructure layer for facilitating service-to-service communications in microservices architectures.

=====================
What is Service Mesh?
=====================

**Core Concepts**

- **Data Plane**: Handles actual network traffic between services
- **Control Plane**: Manages and configures data plane proxies
- **Sidecar Proxy**: Deployed alongside each service instance
- **Traffic Management**: Load balancing, routing, retries, circuit breaking
- **Security**: mTLS, authentication, authorization
- **Observability**: Metrics, logs, traces

**Benefits**

- **Security**: Automatic mTLS encryption
- **Observability**: Detailed traffic metrics and tracing
- **Traffic Management**: Advanced routing and load balancing
- **Reliability**: Circuit breaking, retries, timeouts
- **Policy Enforcement**: Centralized security and compliance

==================
Istio Installation
==================

**Prerequisites**

.. code-block:: bash

    # Verify Kubernetes cluster
    kubectl cluster-info
    
    # Ensure sufficient resources
    kubectl top nodes

**Download and Install Istio**

.. code-block:: bash

    # Download Istio
    curl -L https://istio.io/downloadIstio | sh -
    
    # Add istioctl to PATH
    export PATH=$PWD/istio-1.19.0/bin:$PATH
    echo 'export PATH=$PWD/istio-1.19.0/bin:$PATH' >> ~/.bashrc
    
    # Verify installation
    istioctl version

**Install Istio Control Plane**

.. code-block:: bash

    # Install with default configuration
    istioctl install --set values.defaultRevision=default
    
    # Verify installation
    kubectl get pods -n istio-system
    
    # Enable sidecar injection for default namespace
    kubectl label namespace default istio-injection=enabled

**Istio Configuration Profiles**

.. code-block:: bash

    # Demo profile (for learning)
    istioctl install --set values.defaultRevision=default --set values.pilot.env.EXTERNAL_ISTIOD=false --set values.global.meshID=mesh1 --set values.global.multiCluster.clusterName=cluster1 --set values.global.network=network1
    
    # Minimal profile (production-lite)
    istioctl install --set values.defaultRevision=default --set components.pilot.k8s.resources.requests.memory=128Mi
    
    # Production profile
    istioctl install --filename istio-production.yaml

========================
Istio Traffic Management
========================

**Virtual Services and Destination Rules**

.. code-block:: yaml

    # Virtual Service for routing
    apiVersion: networking.istio.io/v1beta1
    kind: VirtualService
    metadata:
      name: webapp
    spec:
      http:
      - match:
        - headers:
            canary:
              exact: "true"
        route:
        - destination:
            host: webapp
            subset: v2
          weight: 100
      - route:
        - destination:
            host: webapp
            subset: v1
          weight: 90
        - destination:
            host: webapp
            subset: v2
          weight: 10

.. code-block:: yaml

    # Destination Rule for load balancing
    apiVersion: networking.istio.io/v1beta1
    kind: DestinationRule
    metadata:
      name: webapp
    spec:
      host: webapp
      trafficPolicy:
        loadBalancer:
          simple: LEAST_CONN
        connectionPool:
          tcp:
            maxConnections: 10
          http:
            http1MaxPendingRequests: 10
            maxRequestsPerConnection: 2
        circuitBreaker:
          consecutiveGatewayErrors: 5
          interval: 30s
          baseEjectionTime: 30s
      subsets:
      - name: v1
        labels:
          version: v1
      - name: v2
        labels:
          version: v2

**Gateway Configuration**

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
          number: 80
          name: http
          protocol: HTTP
        hosts:
        - webapp.example.com
        tls:
          httpsRedirect: true
      - port:
          number: 443
          name: https
          protocol: HTTPS
        tls:
          mode: SIMPLE
          credentialName: webapp-tls
        hosts:
        - webapp.example.com

=======================
Istio Security Policies
=======================

**Authentication Policies**

.. code-block:: yaml

    # Mutual TLS for entire mesh
    apiVersion: security.istio.io/v1beta1
    kind: PeerAuthentication
    metadata:
      name: default
      namespace: istio-system
    spec:
      mtls:
        mode: STRICT

.. code-block:: yaml

    # JWT Authentication
    apiVersion: security.istio.io/v1beta1
    kind: RequestAuthentication
    metadata:
      name: jwt-auth
      namespace: default
    spec:
      selector:
        matchLabels:
          app: webapp
      jwtRules:
      - issuer: "https://auth.example.com"
        jwksUri: "https://auth.example.com/.well-known/jwks.json"
        audiences:
        - "webapp-api"

**Authorization Policies**

.. code-block:: yaml

    # RBAC Authorization
    apiVersion: security.istio.io/v1beta1
    kind: AuthorizationPolicy
    metadata:
      name: webapp-authz
      namespace: default
    spec:
      selector:
        matchLabels:
          app: webapp
      rules:
      - from:
        - source:
            principals: ["cluster.local/ns/default/sa/frontend"]
        to:
        - operation:
            methods: ["GET", "POST"]
            paths: ["/api/*"]
        when:
        - key: request.headers[user-role]
          values: ["admin", "user"]

==================================
Linkerd as Lightweight Alternative
==================================

**Why Choose Linkerd?**

- **Simplicity**: Easier to install and operate
- **Performance**: Lower resource overhead
- **Security**: Automatic mTLS out of the box
- **Observability**: Built-in metrics and dashboards
- **Rust-based**: Memory safe and performant

**Linkerd Installation**

.. code-block:: bash

    # Download Linkerd CLI
    curl --proto '=https' --tlsv1.2 -sSfL https://run.linkerd.io/install | sh
    
    # Add to PATH
    export PATH=$HOME/.linkerd2/bin:$PATH
    
    # Verify installation requirements
    linkerd check --pre
    
    # Install Linkerd control plane
    linkerd install --crds | kubectl apply -f -
    linkerd install | kubectl apply -f -
    
    # Verify installation
    linkerd check
    
    # Install observability components
    linkerd viz install | kubectl apply -f -

**Linkerd Traffic Management**

.. code-block:: yaml

    # Linkerd TrafficSplit for canary
    apiVersion: split.smi-spec.io/v1alpha1
    kind: TrafficSplit
    metadata:
      name: webapp-split
    spec:
      service: webapp
      backends:
      - service: webapp-v1
        weight: 90
      - service: webapp-v2
        weight: 10

.. code-block:: yaml

    # Linkerd ServiceProfile for retries
    apiVersion: linkerd.io/v1alpha2
    kind: ServiceProfile
    metadata:
      name: webapp.default.svc.cluster.local
    spec:
      routes:
      - name: api
        condition:
          method: GET
          pathRegex: "/api/.*"
        responseClasses:
        - condition:
            status:
              min: 500
              max: 599
          isFailure: true
        retryBudget:
          retryRatio: 0.2
          minRetriesPerSecond: 10
          ttl: 10s

==========================
Service Mesh Observability
==========================

**Istio Observability Stack**

.. code-block:: bash

    # Install Kiali (service mesh dashboard)
    kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.19/samples/addons/kiali.yaml
    
    # Install Jaeger (distributed tracing)
    kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.19/samples/addons/jaeger.yaml
    
    # Install Prometheus (metrics)
    kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.19/samples/addons/prometheus.yaml
    
    # Install Grafana (dashboards)
    kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.19/samples/addons/grafana.yaml

**Access Observability Tools**

.. code-block:: bash

    # Kiali dashboard
    istioctl dashboard kiali
    
    # Jaeger tracing
    istioctl dashboard jaeger
    
    # Grafana dashboards
    istioctl dashboard grafana
    
    # Prometheus metrics
    istioctl dashboard prometheus

**Custom Telemetry Configuration**

.. code-block:: yaml

    # Custom metrics configuration
    apiVersion: telemetry.istio.io/v1alpha1
    kind: Telemetry
    metadata:
      name: custom-metrics
      namespace: istio-system
    spec:
      metrics:
      - providers:
        - name: prometheus
      - overrides:
        - match:
            metric: ALL_METRICS
          tagOverrides:
            request_id:
              value: "%{REQUEST_ID}"
        - match:
            metric: REQUEST_COUNT
          disabled: false

================
Traffic Policies
================

**Fault Injection**

.. code-block:: yaml

    # HTTP fault injection
    apiVersion: networking.istio.io/v1beta1
    kind: VirtualService
    metadata:
      name: webapp-fault
    spec:
      http:
      - match:
        - headers:
            test-fault:
              exact: "true"
        fault:
          delay:
            percentage:
              value: 50
            fixedDelay: 5s
          abort:
            percentage:
              value: 10
            httpStatus: 500
        route:
        - destination:
            host: webapp

**Rate Limiting**

.. code-block:: yaml

    # Envoy rate limiting
    apiVersion: networking.istio.io/v1alpha3
    kind: EnvoyFilter
    metadata:
      name: rate-limit-filter
    spec:
      configPatches:
      - applyTo: HTTP_FILTER
        match:
          context: SIDECAR_INBOUND
          listener:
            filterChain:
              filter:
                name: "envoy.filters.network.http_connection_manager"
        patch:
          operation: INSERT_BEFORE
          value:
            name: envoy.filters.http.local_ratelimit
            typed_config:
              "@type": type.googleapis.com/udpa.type.v1.TypedStruct
              type_url: type.googleapis.com/envoy.extensions.filters.http.local_ratelimit.v3.LocalRateLimit
              value:
                stat_prefix: rate_limiter
                token_bucket:
                  max_tokens: 100
                  tokens_per_fill: 100
                  fill_interval: 60s

==================
Essential Commands
==================

.. code-block:: bash

    # Istio commands
    istioctl version
    istioctl proxy-config cluster <pod-name>
    istioctl proxy-status
    istioctl analyze
    istioctl kube-inject -f deployment.yaml
    
    # Linkerd commands
    linkerd version
    linkerd top
    linkerd stat
    linkerd profile webapp
    linkerd inject deployment.yaml | kubectl apply -f -
    
    # Service mesh debugging
    istioctl proxy-config endpoints <pod-name>
    istioctl proxy-config listeners <pod-name>
    linkerd check
    linkerd diagnostics proxy-metrics <pod-name>

=======================
Service Mesh Comparison
=======================

+------------------+-------------+-------------+----------------+
| Feature          | Istio       | Linkerd     | Consul Connect |
+==================+=============+=============+================+
| Learning Curve   | High        | Low         | Medium         |
+------------------+-------------+-------------+----------------+
| Resource Usage   | High        | Low         | Medium         |
+------------------+-------------+-------------+----------------+
| Feature Set      | Extensive   | Essential   | Comprehensive  |
+------------------+-------------+-------------+----------------+
| Traffic Mgmt     | Advanced    | Basic       | Good           |
+------------------+-------------+-------------+----------------+
| Security         | Advanced    | Automatic   | Good           |
+------------------+-------------+-------------+----------------+
| Observability    | Excellent   | Good        | Good           |
+------------------+-------------+-------------+----------------+

============
What's Next?
============

Next, we'll explore **Advanced Networking** concepts including CNI plugins and network policies.

################################
9.8 Observability and Monitoring
################################

**Gaining Visibility into Kubernetes**

Observability combines metrics, logs, and traces to understand system behavior and troubleshoot issues.

=======================
Metrics with Prometheus
=======================

**Collecting System Metrics**

.. code-block:: yaml

    # ServiceMonitor for app metrics
    apiVersion: monitoring.coreos.com/v1
    kind: ServiceMonitor
    metadata:
      name: webapp-metrics
    spec:
      selector:
        matchLabels:
          app: webapp
      endpoints:
      - port: metrics
        interval: 30s
        path: /metrics

**Custom Metrics**

.. code-block:: yaml

    # Pod with metrics endpoint
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: webapp
    spec:
      template:
        metadata:
          labels:
            app: webapp
        spec:
          containers:
          - name: app
            image: webapp:latest
            ports:
            - name: metrics
              containerPort: 9090
            - name: http
              containerPort: 8080

=======
Logging
=======

**Centralized Log Collection**

.. code-block:: yaml

    # Fluent Bit DaemonSet
    apiVersion: apps/v1
    kind: DaemonSet
    metadata:
      name: fluent-bit
      namespace: logging
    spec:
      selector:
        matchLabels:
          app: fluent-bit
      template:
        metadata:
          labels:
            app: fluent-bit
        spec:
          containers:
          - name: fluent-bit
            image: fluent/fluent-bit:latest
            volumeMounts:
            - name: varlog
              mountPath: /var/log
              readOnly: true
            - name: config
              mountPath: /fluent-bit/etc
          volumes:
          - name: varlog
            hostPath:
              path: /var/log
          - name: config
            configMap:
              name: fluent-bit-config

**Application Logging**

.. code-block:: yaml

    # Structured logging example
    apiVersion: v1
    kind: Pod
    metadata:
      name: app-with-logging
    spec:
      containers:
      - name: app
        image: myapp:latest
        env:
        - name: LOG_LEVEL
          value: "info"
        - name: LOG_FORMAT
          value: "json"

=============
Health Checks
=============

**Probes for Application Health**

.. code-block:: yaml

    # Pod with health checks
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
            startupProbe:
              httpGet:
                path: /startup
                port: 8080
              failureThreshold: 30
              periodSeconds: 10

======
Alerts
======

**Prometheus Alerting Rules**

.. code-block:: yaml

    # PrometheusRule for alerts
    apiVersion: monitoring.coreos.com/v1
    kind: PrometheusRule
    metadata:
      name: webapp-alerts
    spec:
      groups:
      - name: webapp.rules
        rules:
        - alert: HighErrorRate
          expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
          for: 5m
          labels:
            severity: warning
          annotations:
            summary: "High error rate detected"
            description: "Error rate is {{ $value }} errors per second"

===================
Distributed Tracing
===================

**Tracing with Jaeger**

.. code-block:: yaml

    # Application with tracing
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
            - name: JAEGER_AGENT_HOST
              value: "jaeger-agent"
            - name: JAEGER_AGENT_PORT
              value: "6831"

======================
Dashboard with Grafana
======================

**Visualization Setup**

.. code-block:: yaml

    # Grafana ConfigMap
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: grafana-datasources
    data:
      prometheus.yaml: |
        apiVersion: 1
        datasources:
        - name: Prometheus
          type: prometheus
          url: http://prometheus-server:80
          access: proxy
          isDefault: true

===================
Resource Monitoring
===================

**Cluster Resource Usage**

.. code-block:: bash

    # Built-in resource monitoring
    kubectl top nodes
    kubectl top pods --all-namespaces
    kubectl top pods --containers

**Metrics Server**

.. code-block:: yaml

    # Enable metrics collection
    apiVersion: v1
    kind: Service
    metadata:
      name: metrics-server
      namespace: kube-system
    spec:
      selector:
        k8s-app: metrics-server
      ports:
      - port: 443
        targetPort: 4443

==================
Essential Commands
==================

.. code-block:: bash

    # Metrics and monitoring
    kubectl top nodes
    kubectl top pods
    kubectl get servicemonitors
    kubectl get prometheusrules
    
    # Logs
    kubectl logs pod-name
    kubectl logs pod-name -c container-name
    kubectl logs -f deployment/webapp
    kubectl logs --previous pod-name
    
    # Events and troubleshooting
    kubectl get events --sort-by=.metadata.creationTimestamp
    kubectl describe pod problematic-pod

============
What's Next?
============

Next, we'll explore **Helm Package Management** for deploying and managing complex applications.

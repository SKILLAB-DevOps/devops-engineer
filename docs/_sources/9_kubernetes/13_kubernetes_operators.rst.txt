#########################
9.13 Kubernetes Operators
#########################

#########################
9.13 Kubernetes Operators
#########################

**Automating Complex Applications with Operators**

Operators extend Kubernetes to manage stateful applications like databases and monitoring systems. They encode operational knowledge into software that can provision, scale, backup, and maintain complex applications automatically.

===================
What are Operators?
===================

**Operator Pattern**

Operators combine:

- **Custom Resource Definitions (CRDs)** - New Kubernetes API types
- **Controllers** - Logic to manage those resources
- **Operational Knowledge** - Best practices encoded in software

**Benefits:**

- Automated deployment and scaling
- Self-healing applications
- Backup and disaster recovery
- Rolling updates and maintenance

===================
PostgreSQL Operator
===================

**Zalando PostgreSQL Operator**

The PostgreSQL Operator manages PostgreSQL clusters with high availability, backups, and monitoring.

**Installation**

.. code-block:: bash

    # Install PostgreSQL Operator
    kubectl apply -k github.com/zalando/postgres-operator/manifests
    
    # Verify installation
    kubectl get pods -n postgres-operator

**PostgreSQL Cluster**

.. code-block:: yaml

    # High-availability PostgreSQL cluster
    apiVersion: "acid.zalan.do/v1"
    kind: postgresql
    metadata:
      name: webapp-postgres
      namespace: production
    spec:
      teamId: "webapp-team"
      volume:
        size: 100Gi
        storageClass: "gp3"
      numberOfInstances: 3
      users:
        webapp_user: []
        readonly_user: []
      databases:
        webapp_db: webapp_user
      postgresql:
        version: "15"
        parameters:
          max_connections: "200"
          shared_buffers: "256MB"
          effective_cache_size: "1GB"
      resources:
        requests:
          cpu: 500m
          memory: 1Gi
        limits:
          cpu: 2000m
          memory: 4Gi
      patroni:
        initdb:
          encoding: "UTF8"
          locale: "en_US.UTF-8"
        pg_hba:
          - hostssl all all 0.0.0.0/0 md5
      backup:
        schedule: "0 2 * * *"
        retentionDays: 30

**Using the PostgreSQL Cluster**

.. code-block:: yaml

    # Application connecting to PostgreSQL
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
              value: "postgresql://webapp_user:$(POSTGRES_PASSWORD)@webapp-postgres:5432/webapp_db"
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: webapp-user.webapp-postgres.credentials
                  key: password

**PostgreSQL Operations**

.. code-block:: bash

    # List PostgreSQL clusters
    kubectl get postgresql
    
    # Check cluster status
    kubectl describe postgresql webapp-postgres
    
    # Get connection details
    kubectl get secret webapp-user.webapp-postgres.credentials -o yaml
    
    # Scale cluster
    kubectl patch postgresql webapp-postgres --type='merge' -p='{\"spec\":{\"numberOfInstances\":5}}'

===================
Prometheus Operator
===================

**Kube-Prometheus Stack**

The Prometheus Operator provides Kubernetes native deployment and management of Prometheus and related monitoring components.

**Installation**

.. code-block:: bash

    # Add Helm repository
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    
    # Install kube-prometheus-stack
    helm install prometheus prometheus-community/kube-prometheus-stack 
      --namespace monitoring 
      --create-namespace 
      --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName=gp3 
      --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=50Gi

**Prometheus Instance**

.. code-block:: yaml

    # Custom Prometheus configuration
    apiVersion: monitoring.coreos.com/v1
    kind: Prometheus
    metadata:
      name: webapp-prometheus
      namespace: monitoring
    spec:
      serviceAccountName: prometheus-webapp-prometheus
      serviceMonitorSelector:
        matchLabels:
          team: webapp
      ruleSelector:
        matchLabels:
          prometheus: webapp
      storage:
        volumeClaimTemplate:
          spec:
            storageClassName: gp3
            accessModes: ["ReadWriteOnce"]
            resources:
              requests:
                storage: 100Gi
      retention: 30d
      replicas: 2
      resources:
        requests:
          memory: 2Gi
          cpu: 1000m
        limits:
          memory: 4Gi
          cpu: 2000m

**ServiceMonitor for Application**

.. code-block:: yaml

    # Monitor application metrics
    apiVersion: monitoring.coreos.com/v1
    kind: ServiceMonitor
    metadata:
      name: webapp-metrics
      namespace: monitoring
      labels:
        team: webapp
    spec:
      selector:
        matchLabels:
          app: webapp
      endpoints:
      - port: metrics
        interval: 30s
        path: /metrics
      namespaceSelector:
        matchNames:
        - production

**PrometheusRule for Alerts**

.. code-block:: yaml

    # Application alerts
    apiVersion: monitoring.coreos.com/v1
    kind: PrometheusRule
    metadata:
      name: webapp-alerts
      namespace: monitoring
      labels:
        prometheus: webapp
    spec:
      groups:
      - name: webapp.rules
        rules:
        - alert: WebappDown
          expr: up{job="webapp"} == 0
          for: 5m
          labels:
            severity: critical
          annotations:
            summary: "Webapp is down"
            description: "Webapp has been down for more than 5 minutes"
        
        - alert: HighErrorRate
          expr: rate(http_requests_total{job="webapp",status=~"5.."}[5m]) > 0.1
          for: 2m
          labels:
            severity: warning
          annotations:
            summary: "High error rate detected"
            description: "Error rate is {{ $value }} per second"

=====================
Cert-Manager Operator
=====================

**TLS Certificate Automation**

.. code-block:: bash

    # Install cert-manager
    helm install cert-manager jetstack/cert-manager 
      --namespace cert-manager 
      --create-namespace 
      --set installCRDs=true

**ClusterIssuer**

.. code-block:: yaml

    # Let's Encrypt issuer
    apiVersion: cert-manager.io/v1
    kind: ClusterIssuer
    metadata:
      name: letsencrypt-prod
    spec:
      acme:
        server: https://acme-v02.api.letsencrypt.org/directory
        email: admin@example.com
        privateKeySecretRef:
          name: letsencrypt-prod
        solvers:
        - http01:
            ingress:
              class: nginx

**Certificate Request**

.. code-block:: yaml

    # Automatic certificate
    apiVersion: cert-manager.io/v1
    kind: Certificate
    metadata:
      name: webapp-tls
      namespace: production
    spec:
      secretName: webapp-tls
      issuerRef:
        name: letsencrypt-prod
        kind: ClusterIssuer
      dnsNames:
      - webapp.example.com
      - api.example.com

===================
Operator Management
===================

**Operator Lifecycle Manager (OLM)**

.. code-block:: bash

    # Install OLM
    curl -sL https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.24.0/install.sh | bash -s v0.24.0
    
    # List available operators
    kubectl get packagemanifests

**Installing Operators via OLM**

.. code-block:: yaml

    # Operator subscription
    apiVersion: operators.coreos.com/v1alpha1
    kind: Subscription
    metadata:
      name: postgresql-operator
      namespace: postgres-operator
    spec:
      channel: stable
      name: postgresql-operator
      source: community-operators
      sourceNamespace: olm

==================
Essential Commands
==================

.. code-block:: bash

    # PostgreSQL Operator
    kubectl get postgresql
    kubectl describe postgresql webapp-postgres
    kubectl logs -f deployment/postgres-operator -n postgres-operator
    
    # Prometheus Operator
    kubectl get prometheus
    kubectl get servicemonitors
    kubectl get prometheusrules
    kubectl port-forward svc/prometheus-operated 9090:9090 -n monitoring
    
    # Cert-Manager
    kubectl get certificates
    kubectl get clusterissuers
    kubectl describe certificate webapp-tls
    
    # General operator management
    kubectl get crds | grep -E "(postgresql|monitoring|cert-manager)"
    kubectl get operators

============
What's Next?
============

Operators significantly simplify managing complex applications in Kubernetes. Consider exploring:

- **ArgoCD Operator** for GitOps workflows
- **Grafana Operator** for dashboard management  
- **Elasticsearch Operator** for logging infrastructure
- **Redis Operator** for caching solutions

Operators represent the future of Kubernetes application management, encoding decades of operational expertise into automated software.
##############################
9.11 Production Best Practices
##############################

**Running Kubernetes in Production**

Production Kubernetes requires careful planning for security, reliability, monitoring, and resource management.

===================
Resource Management
===================

**Resource Requests and Limits**

.. code-block:: yaml

    # Properly configured resources
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
            resources:
              requests:
                memory: "256Mi"
                cpu: "250m"
              limits:
                memory: "512Mi"
                cpu: "500m"

**Quality of Service Classes**

- **Guaranteed**: requests = limits for all containers
- **Burstable**: at least one container has requests < limits  
- **BestEffort**: no requests or limits specified

=================
High Availability
=================

**Pod Disruption Budgets**

.. code-block:: yaml

    # Ensure minimum availability
    apiVersion: policy/v1
    kind: PodDisruptionBudget
    metadata:
      name: webapp-pdb
    spec:
      minAvailable: 2
      selector:
        matchLabels:
          app: webapp

**Anti-Affinity Rules**

.. code-block:: yaml

    # Spread pods across nodes
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: webapp
    spec:
      template:
        spec:
          affinity:
            podAntiAffinity:
              requiredDuringSchedulingIgnoredDuringExecution:
              - labelSelector:
                  matchLabels:
                    app: webapp
                topologyKey: kubernetes.io/hostname

===================
Cluster Autoscaling
===================

**Horizontal Pod Autoscaler**

.. code-block:: yaml

    # CPU-based autoscaling
    apiVersion: autoscaling/v2
    kind: HorizontalPodAutoscaler
    metadata:
      name: webapp-hpa
    spec:
      scaleTargetRef:
        apiVersion: apps/v1
        kind: Deployment
        name: webapp
      minReplicas: 3
      maxReplicas: 20
      metrics:
      - type: Resource
        resource:
          name: cpu
          target:
            type: Utilization
            averageUtilization: 70

**Cluster Autoscaler**

.. code-block:: yaml

    # Node autoscaling
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: cluster-autoscaler
      namespace: kube-system
    spec:
      template:
        spec:
          containers:
          - image: k8s.gcr.io/autoscaling/cluster-autoscaler:v1.21.0
            name: cluster-autoscaler
            command:
            - ./cluster-autoscaler
            - --v=4
            - --stderrthreshold=info
            - --cloud-provider=aws
            - --skip-nodes-with-local-storage=false
            - --expander=least-waste
            - --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/my-cluster

============================
Backup and Disaster Recovery
============================

**Velero Backup**

.. code-block:: yaml

    # Backup schedule
    apiVersion: velero.io/v1
    kind: Schedule
    metadata:
      name: daily-backup
      namespace: velero
    spec:
      schedule: "0 2 * * *"
      template:
        includedNamespaces:
        - production
        - staging
        ttl: "720h"  # 30 days

=================
Cost Optimization
=================

**Resource Quotas**

.. code-block:: yaml

    # Namespace resource limits
    apiVersion: v1
    kind: ResourceQuota
    metadata:
      name: compute-quota
      namespace: production
    spec:
      hard:
        requests.cpu: "100"
        requests.memory: 200Gi
        limits.cpu: "200"
        limits.memory: 400Gi
        pods: "50"

**Spot Instances and Node Pools**

.. code-block:: yaml

    # Mixed instance types
    apiVersion: v1
    kind: Node
    metadata:
      labels:
        node-type: spot
        instance-type: m5.large
    spec:
      taints:
      - key: spot-instance
        value: "true"
        effect: NoSchedule

==================
Security Hardening
==================

**Pod Security Standards**

.. code-block:: yaml

    # Restricted namespace
    apiVersion: v1
    kind: Namespace
    metadata:
      name: production
      labels:
        pod-security.kubernetes.io/enforce: restricted
        pod-security.kubernetes.io/audit: restricted
        pod-security.kubernetes.io/warn: restricted

**Network Policies**

.. code-block:: yaml

    # Default deny all
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: default-deny-all
      namespace: production
    spec:
      podSelector: {}
      policyTypes:
      - Ingress
      - Egress

==================
Essential Commands
==================

.. code-block:: bash

    # Resource monitoring
    kubectl top nodes
    kubectl top pods --all-namespaces
    kubectl describe node node-name
    
    # Cluster health
    kubectl get componentstatuses
    kubectl get events --all-namespaces
    
    # Resource management
    kubectl get resourcequotas --all-namespaces
    kubectl get poddisruptionbudgets
    kubectl get hpa

============
What's Next?
============

Next, we'll explore **Troubleshooting and Debugging** techniques for production issues.

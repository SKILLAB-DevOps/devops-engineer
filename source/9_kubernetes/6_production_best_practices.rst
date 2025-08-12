#############################
9.6 Production Best Practices
#############################

**Running Kubernetes at Scale**

You've built CI/CD pipelines, deployed with Helm, and automated with ArgoCD. Now learn the essential practices that keep production Kubernetes clusters secure, reliable, and cost-effective at scale.

This covers the real-world operational knowledge that separates development clusters from production-grade platforms.

===================
Production Security
===================

**Defense in Depth**

Production security requires multiple layers of protection:

**Pod Security Standards:**

.. code-block:: yaml

    # Secure namespace configuration
    apiVersion: v1
    kind: Namespace
    metadata:
      name: production
      labels:
        pod-security.kubernetes.io/enforce: restricted
        pod-security.kubernetes.io/audit: restricted
        pod-security.kubernetes.io/warn: restricted

**Production-Ready Deployment:**

.. code-block:: yaml

    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: webapp
      namespace: production
    spec:
      template:
        spec:
          serviceAccountName: webapp-sa
          automountServiceAccountToken: false
          securityContext:
            runAsNonRoot: true
            runAsUser: 10001
            fsGroup: 10001
            seccompProfile:
              type: RuntimeDefault
          containers:
          - name: webapp
            image: myapp:v1.0.0
            securityContext:
              allowPrivilegeEscalation: false
              readOnlyRootFilesystem: true
              runAsNonRoot: true
              capabilities:
                drop: ["ALL"]
            resources:
              requests:
                memory: "256Mi"
                cpu: "250m"
              limits:
                memory: "512Mi"
                cpu: "500m"
            volumeMounts:
            - name: tmp
              mountPath: /tmp
          volumes:
          - name: tmp
            emptyDir: {}

**Network Security:**

.. code-block:: yaml

    # Default deny all traffic
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: default-deny
      namespace: production
    spec:
      podSelector: {}
      policyTypes: [Ingress, Egress]
    
    ---
    # Allow specific traffic
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: webapp-policy
      namespace: production
    spec:
      podSelector:
        matchLabels:
          app: webapp
      policyTypes: [Ingress, Egress]
      ingress:
      - from:
        - namespaceSelector:
            matchLabels:
              name: frontend
        ports:
        - protocol: TCP
          port: 8080
      egress:
      - to:
        - namespaceSelector:
            matchLabels:
              name: database
        ports:
        - protocol: TCP
          port: 5432

=====================
Monitoring & Alerting
=====================

**Observability Stack**

Production requires comprehensive monitoring at all levels:

**Application Metrics:**

.. code-block:: python

    # Add to your application
    from prometheus_client import Counter, Histogram, Gauge
    
    # Define key metrics
    REQUEST_COUNT = Counter('http_requests_total', 'Total requests', ['method', 'endpoint', 'status'])
    REQUEST_LATENCY = Histogram('http_request_duration_seconds', 'Request latency')
    ACTIVE_CONNECTIONS = Gauge('active_database_connections', 'Active DB connections')
    
    @app.route('/metrics')
    def metrics():
        return generate_latest()

**Critical Alerts:**

.. code-block:: yaml

    # Essential production alerts
    groups:
    - name: production-critical
      rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "High error rate: {{ $value }} errors/sec"
      
      - alert: PodCrashLooping
        expr: rate(kube_pod_container_status_restarts_total[15m]) > 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Pod {{ $labels.pod }} is crash looping"
      
      - alert: HighMemoryUsage
        expr: container_memory_usage_bytes / container_spec_memory_limit_bytes > 0.9
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Container memory usage > 90%"
      
      - alert: NodeNotReady
        expr: kube_node_status_condition{condition="Ready",status="true"} == 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Node {{ $labels.node }} is not ready"

===================
Resource Management
===================

**Efficient Resource Usage**

Proper resource management prevents issues and optimizes costs:

**Resource Quotas & Limits:**

.. code-block:: yaml

    # Namespace resource limits
    apiVersion: v1
    kind: ResourceQuota
    metadata:
      name: production-quota
      namespace: production
    spec:
      hard:
        requests.cpu: "10"
        requests.memory: "20Gi"
        limits.cpu: "20"
        limits.memory: "40Gi"
        pods: "20"
        services: "10"
    
    ---
    # Default resource limits
    apiVersion: v1
    kind: LimitRange
    metadata:
      name: production-limits
      namespace: production
    spec:
      limits:
      - type: Container
        default:
          cpu: "500m"
          memory: "512Mi"
        defaultRequest:
          cpu: "100m"
          memory: "128Mi"
        max:
          cpu: "2"
          memory: "4Gi"

**Horizontal Pod Autoscaler:**

.. code-block:: yaml

    apiVersion: autoscaling/v2
    kind: HorizontalPodAutoscaler
    metadata:
      name: webapp-hpa
      namespace: production
    spec:
      scaleTargetRef:
        apiVersion: apps/v1
        kind: Deployment
        name: webapp
      minReplicas: 3
      maxReplicas: 50
      metrics:
      - type: Resource
        resource:
          name: cpu
          target:
            type: Utilization
            averageUtilization: 70
      - type: Resource
        resource:
          name: memory
          target:
            type: Utilization
            averageUtilization: 80
      behavior:
        scaleDown:
          stabilizationWindowSeconds: 300
          policies:
          - type: Percent
            value: 10
            periodSeconds: 60
        scaleUp:
          stabilizationWindowSeconds: 60
          policies:
          - type: Percent
            value: 50
            periodSeconds: 60

=================
High Availability
=================

**Pod Distribution Strategy**

Ensure your applications survive node failures:

.. code-block:: yaml

    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: webapp
      namespace: production
    spec:
      replicas: 5
      template:
        spec:
          affinity:
            # Spread across availability zones
            podAntiAffinity:
              requiredDuringSchedulingIgnoredDuringExecution:
              - labelSelector:
                  matchLabels:
                    app: webapp
                topologyKey: topology.kubernetes.io/zone
            # Prefer spreading across nodes
            podAntiAffinity:
              preferredDuringSchedulingIgnoredDuringExecution:
              - weight: 100
                podAffinityTerm:
                  labelSelector:
                    matchLabels:
                      app: webapp
                  topologyKey: kubernetes.io/hostname

**Pod Disruption Budget:**

.. code-block:: yaml

    apiVersion: policy/v1
    kind: PodDisruptionBudget
    metadata:
      name: webapp-pdb
      namespace: production
    spec:
      minAvailable: 2
      selector:
        matchLabels:
          app: webapp

=================
Backup & Recovery
=================

**Data Protection**

Critical data requires automated backup:

.. code-block:: yaml

    # Database backup job
    apiVersion: batch/v1
    kind: CronJob
    metadata:
      name: database-backup
      namespace: production
    spec:
      schedule: "0 2 * * *"  # Daily at 2 AM
      jobTemplate:
        spec:
          template:
            spec:
              containers:
              - name: backup
                image: postgres:15
                command:
                - /bin/bash
                - -c
                - |
                  pg_dump $DATABASE_URL | gzip > /backup/db-$(date +%Y%m%d-%H%M%S).sql.gz
                  # Upload to cloud storage
                  aws s3 cp /backup/*.sql.gz s3://backups/database/
                  # Keep only last 7 days locally
                  find /backup -name "*.sql.gz" -mtime +7 -delete
                env:
                - name: DATABASE_URL
                  valueFrom:
                    secretKeyRef:
                      name: postgres-secret
                      key: url
                - name: AWS_ACCESS_KEY_ID
                  valueFrom:
                    secretKeyRef:
                      name: backup-credentials
                      key: access-key
                - name: AWS_SECRET_ACCESS_KEY
                  valueFrom:
                    secretKeyRef:
                      name: backup-credentials
                      key: secret-key
                volumeMounts:
                - name: backup-storage
                  mountPath: /backup
              volumes:
              - name: backup-storage
                emptyDir: {}
              restartPolicy: OnFailure

**Cluster Configuration Backup:**

.. code-block:: bash

    #!/bin/bash
    # backup-cluster.sh - Run weekly
    
    DATE=$(date +%Y%m%d)
    BACKUP_DIR="cluster-backups"
    
    mkdir -p $BACKUP_DIR
    
    # Backup all resources
    kubectl get all --all-namespaces -o yaml > $BACKUP_DIR/all-resources-$DATE.yaml
    
    # Backup critical resources
    kubectl get secrets,configmaps --all-namespaces -o yaml > $BACKUP_DIR/configs-$DATE.yaml
    kubectl get pv,pvc --all-namespaces -o yaml > $BACKUP_DIR/storage-$DATE.yaml
    
    # Backup RBAC
    kubectl get clusterroles,clusterrolebindings,roles,rolebindings --all-namespaces -o yaml > $BACKUP_DIR/rbac-$DATE.yaml
    
    # Upload to S3
    aws s3 sync $BACKUP_DIR s3://cluster-backups/

========================
Performance Optimization
========================

**Quality of Service**

Assign appropriate QoS classes:

.. code-block:: yaml

    # Guaranteed QoS for critical services
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: payment-service
    spec:
      template:
        spec:
          containers:
          - name: payment
            image: payment:v1.0.0
            resources:
              requests:
                cpu: "1"
                memory: "2Gi"
              limits:
                cpu: "1"        # Same as requests = Guaranteed
                memory: "2Gi"   # Same as requests = Guaranteed
    
    ---
    # Burstable QoS for standard services
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: api-service
    spec:
      template:
        spec:
          containers:
          - name: api
            image: api:v1.0.0
            resources:
              requests:
                cpu: "500m"
                memory: "1Gi"
              limits:
                cpu: "2"        # Higher than requests = Burstable
                memory: "4Gi"   # Higher than requests = Burstable

**Node Affinity for Performance:**

.. code-block:: yaml

    # High-performance workload
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: analytics-service
    spec:
      template:
        spec:
          affinity:
            nodeAffinity:
              requiredDuringSchedulingIgnoredDuringExecution:
                nodeSelectorTerms:
                - matchExpressions:
                  - key: node-type
                    operator: In
                    values: ["high-cpu", "high-memory"]
              preferredDuringSchedulingIgnoredDuringExecution:
              - weight: 100
                preference:
                  matchExpressions:
                  - key: zone
                    operator: In
                    values: ["us-west-2a"]

=================
Cost Optimization
=================

**Vertical Pod Autoscaler**

Automatically optimize resource requests:

.. code-block:: yaml

    apiVersion: autoscaling.k8s.io/v1
    kind: VerticalPodAutoscaler
    metadata:
      name: webapp-vpa
      namespace: production
    spec:
      targetRef:
        apiVersion: apps/v1
        kind: Deployment
        name: webapp
      updatePolicy:
        updateMode: "Auto"
      resourcePolicy:
        containerPolicies:
        - containerName: webapp
          maxAllowed:
            cpu: "2"
            memory: "4Gi"
          minAllowed:
            cpu: "100m"
            memory: "128Mi"
          controlledResources: ["cpu", "memory"]

**Cluster Autoscaler:**

.. code-block:: yaml

    # Node scaling configuration
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: cluster-autoscaler
      namespace: kube-system
    spec:
      template:
        spec:
          containers:
          - image: k8s.gcr.io/autoscaling/cluster-autoscaler:v1.27.0
            name: cluster-autoscaler
            command:
            - ./cluster-autoscaler
            - --v=4
            - --stderrthreshold=info
            - --cloud-provider=aws
            - --skip-nodes-with-local-storage=false
            - --expander=least-waste
            - --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled
            - --balance-similar-node-groups
            - --scale-down-delay-after-add=10m
            - --scale-down-unneeded-time=10m

=================
Security Scanning
=================

**Automated Vulnerability Detection**

.. code-block:: yaml

    # Image scanning job
    apiVersion: batch/v1
    kind: CronJob
    metadata:
      name: security-scan
    spec:
      schedule: "0 6 * * *"  # Daily at 6 AM
      jobTemplate:
        spec:
          template:
            spec:
              containers:
              - name: trivy-scan
                image: aquasec/trivy:latest
                command:
                - /bin/sh
                args:
                - -c
                - |
                  # Scan all images in production namespace
                  kubectl get pods -n production -o jsonpath='{.items[*].spec.containers[*].image}' | \
                  tr ' ' '\n' | sort -u | while read image; do
                    echo "Scanning $image"
                    trivy image --format json --output /reports/$(echo $image | tr '/' '_' | tr ':' '_').json $image
                  done
                  
                  # Upload reports
                  aws s3 sync /reports s3://security-reports/$(date +%Y%m%d)/
                volumeMounts:
                - name: reports
                  mountPath: /reports
                - name: kubeconfig
                  mountPath: /root/.kube
              volumes:
              - name: reports
                emptyDir: {}
              - name: kubeconfig
                secret:
                  secretName: scanner-kubeconfig
              restartPolicy: OnFailure

==================
Policy Enforcement
==================

**Open Policy Agent (OPA) Gatekeeper**

Enforce organizational policies:

.. code-block:: yaml

    # Require specific labels
    apiVersion: templates.gatekeeper.sh/v1beta1
    kind: ConstraintTemplate
    metadata:
      name: k8srequiredlabels
    spec:
      crd:
        spec:
          names:
            kind: K8sRequiredLabels
          validation:
            properties:
              labels:
                type: array
                items:
                  type: string
      targets:
        - target: admission.k8s.gatekeeper.sh
          rego: |
            package k8srequiredlabels
            
            violation[{"msg": msg}] {
              required := input.parameters.labels
              provided := input.review.object.metadata.labels
              missing := required[_]
              not provided[missing]
              msg := sprintf("Missing required label: %v", [missing])
            }
    
    ---
    # Apply the policy
    apiVersion: constraints.gatekeeper.sh/v1beta1
    kind: K8sRequiredLabels
    metadata:
      name: must-have-owner
    spec:
      match:
        kinds:
          - apiGroups: ["apps"]
            kinds: ["Deployment"]
        excludedNamespaces: ["kube-system", "gatekeeper-system"]
      parameters:
        labels: ["owner", "team", "environment"]

====================
Production Checklist
====================

**Go-Live Verification**

Before production deployment, verify:

**Security**

- Pod Security Standards enforced
- Network policies configured
- RBAC with least privilege
- Secrets encrypted at rest
- Image scanning implemented
- Security policies enforced

**Reliability**

- Multiple replicas configured
- Pod disruption budgets set
- Health checks implemented
- Resource limits defined
- Anti-affinity rules configured
- Backup procedures tested

**Monitoring**

- Metrics collection enabled
- Critical alerts configured
- Log aggregation setup
- Dashboards created
- SLO/SLI tracked
- On-call procedures documented

**Performance**

- Load testing completed
- Autoscaling configured
- Resource requests optimized
- QoS classes assigned
- Performance baselines established

**Operations**

- Deployment automation working
- Rollback procedures tested
- Maintenance procedures documented
- Disaster recovery plan verified
- Team training completed

==================
Essential Commands
==================

**Daily Operations:**

.. code-block:: bash

    # Cluster health
    kubectl get nodes
    kubectl get pods --all-namespaces | grep -v Running
    kubectl top nodes
    kubectl top pods --all-namespaces
    
    # Resource usage
    kubectl describe node NODE_NAME
    kubectl get events --sort-by=.metadata.creationTimestamp
    kubectl get pvc --all-namespaces
    
    # Troubleshooting
    kubectl logs -f deployment/webapp -n production
    kubectl describe pod POD_NAME -n production
    kubectl exec -it POD_NAME -n production -- /bin/bash
    
    # Scaling
    kubectl scale deployment webapp --replicas=10 -n production
    kubectl get hpa -n production
    
    # Security
    kubectl auth can-i create pods --as=system:serviceaccount:production:webapp-sa
    kubectl get networkpolicies -n production
    
    # Maintenance
    kubectl drain NODE_NAME --ignore-daemonsets
    kubectl uncordon NODE_NAME
    kubectl rollout restart deployment/webapp -n production

============
What's Next?
============

**You're Production Ready!**

You now have a complete production Kubernetes platform:

- **Security Hardened** - Multi-layer security with policies and scanning
- **Highly Available** - Distributed across zones with auto-scaling
- **Fully Monitored** - Comprehensive metrics, alerts, and logging
- **Cost Optimized** - Resource management and auto-scaling
- **Operationally Mature** - Backup, recovery, and maintenance procedures
- **Policy Enforced** - Automated governance and compliance

**Your Complete DevOps Pipeline:**
1. **Code** → GitHub with CI/CD
2. **Build** → Automated testing and container creation
3. **Package** → Helm charts for consistent deployment
4. **Deploy** → ArgoCD for GitOps automation
5. **Operate** → Production-grade monitoring and security

You've transformed from manual deployments to a complete, automated, production-ready DevOps platform capable of supporting enterprise applications at scale.

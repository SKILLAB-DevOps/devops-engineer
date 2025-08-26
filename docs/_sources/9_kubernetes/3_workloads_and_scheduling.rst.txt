############################
9.3 Workloads and Scheduling
############################

**Managing Different Types of Applications**

Kubernetes provides different controllers for various workload patterns. Each controller manages pods according to specific use cases.

============
StatefulSets
============

**For Stateful Applications**

StatefulSets provide stable network identities and persistent storage for applications like databases.

.. code-block:: yaml

    # Simple PostgreSQL StatefulSet
    apiVersion: apps/v1
    kind: StatefulSet
    metadata:
      name: postgres
    spec:
      serviceName: postgres-headless
      replicas: 3
      selector:
        matchLabels:
          app: postgres
      template:
        metadata:
          labels:
            app: postgres
        spec:
          containers:
          - name: postgres
            image: postgres:15
            env:
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: postgres-secret
                  key: password
            volumeMounts:
            - name: data
              mountPath: /var/lib/postgresql/data
      volumeClaimTemplates:
      - metadata:
          name: data
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 10Gi

**Key Features:**
- Stable pod names: postgres-0, postgres-1, postgres-2
- Ordered deployment and scaling
- Persistent storage per pod

==========
DaemonSets
==========

**Run Pods on Every Node**

DaemonSets ensure a copy runs on all nodes, perfect for monitoring and logging.

.. code-block:: yaml

    # Log collector on every node
    apiVersion: apps/v1
    kind: DaemonSet
    metadata:
      name: fluentd
    spec:
      selector:
        matchLabels:
          app: fluentd
      template:
        metadata:
          labels:
            app: fluentd
        spec:
          containers:
          - name: fluentd
            image: fluent/fluentd:v1.16
            volumeMounts:
            - name: varlog
              mountPath: /var/log
              readOnly: true
          volumes:
          - name: varlog
            hostPath:
              path: /var/log

**Use Cases:**
- Log collection agents
- Monitoring agents
- Network proxies
- Storage daemons

====
Jobs
====

**Run-to-Completion Tasks**

Jobs run pods until successful completion, perfect for batch processing.

.. code-block:: yaml

    # Database backup job
    apiVersion: batch/v1
    kind: Job
    metadata:
      name: db-backup
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: postgres:15
            command:
            - pg_dump
            - -h
            - postgres-service
            - -U
            - postgres
            - mydb
            env:
            - name: PGPASSWORD
              valueFrom:
                secretKeyRef:
                  name: postgres-secret
                  key: password
          restartPolicy: OnFailure

**Parallel Job Example:**

.. code-block:: yaml

    # Process data in parallel
    apiVersion: batch/v1
    kind: Job
    metadata:
      name: data-processing
    spec:
      completions: 100      # Total successful completions needed
      parallelism: 10       # Run 10 pods concurrently
      template:
        spec:
          containers:
          - name: processor
            image: data-processor:latest
          restartPolicy: Never

========
CronJobs
========

**Scheduled Tasks**

CronJobs create Jobs on a schedule, like traditional cron.

.. code-block:: yaml

    # Daily backup at 2 AM
    apiVersion: batch/v1
    kind: CronJob
    metadata:
      name: daily-backup
    spec:
      schedule: "0 2 * * *"
      jobTemplate:
        spec:
          template:
            spec:
              containers:
              - name: backup
                image: backup-tool:latest
                command:
                - /backup-script.sh
              restartPolicy: OnFailure

**Schedule Examples:**
- ``"0 2 * * *"`` - Daily at 2 AM
- ``"0 */6 * * *"`` - Every 6 hours
- ``"30 1 * * 0"`` - Weekly on Sunday at 1:30 AM

=========================
Horizontal Pod Autoscaler
=========================

**Automatic Scaling**

HPA automatically scales pods based on CPU, memory, or custom metrics.

.. code-block:: yaml

    # Scale based on CPU usage
    apiVersion: autoscaling/v2
    kind: HorizontalPodAutoscaler
    metadata:
      name: webapp-hpa
    spec:
      scaleTargetRef:
        apiVersion: apps/v1
        kind: Deployment
        name: webapp
      minReplicas: 2
      maxReplicas: 10
      metrics:
      - type: Resource
        resource:
          name: cpu
          target:
            type: Utilization
            averageUtilization: 70

==================
Essential Commands
==================

.. code-block:: bash

    # StatefulSets
    kubectl get statefulsets
    kubectl scale statefulset postgres --replicas=5
    kubectl delete statefulset postgres --cascade=orphan
    
    # DaemonSets
    kubectl get daemonsets -A
    kubectl rollout status daemonset/fluentd
    
    # Jobs and CronJobs
    kubectl get jobs
    kubectl get cronjobs
    kubectl create job manual-backup --from=cronjob/daily-backup
    
    # HPA
    kubectl get hpa
    kubectl top pods  # View resource usage
    kubectl autoscale deployment webapp --cpu-percent=50 --min=1 --max=10

============
What's Next?
============

Next, we'll explore **Networking and Services** to connect your workloads and expose them to users and other services.

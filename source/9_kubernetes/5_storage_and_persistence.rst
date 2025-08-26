###########################
9.5 Storage and Persistence
###########################

**Managing Data in Kubernetes**

Kubernetes provides several storage options for persistent data, from simple volumes to enterprise storage solutions.

=======
Volumes
=======

**Basic Storage Types**

.. code-block:: yaml

    # Pod with different volume types
    apiVersion: v1
    kind: Pod
    metadata:
      name: storage-demo
    spec:
      containers:
      - name: app
        image: nginx
        volumeMounts:
        - name: empty-vol
          mountPath: /tmp/empty
        - name: host-vol
          mountPath: /tmp/host
        - name: config-vol
          mountPath: /etc/config
      volumes:
      - name: empty-vol
        emptyDir: {}              # Temporary storage
      - name: host-vol
        hostPath:                 # Node filesystem
          path: /data
      - name: config-vol
        configMap:                # Configuration data
          name: app-config

==================
Persistent Volumes
==================

**Long-term Storage**

Persistent Volumes (PV) provide durable storage that exists beyond pod lifecycle.

**Persistent Volume**

.. code-block:: yaml

    # Manual PV creation
    apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: postgres-pv
    spec:
      capacity:
        storage: 10Gi
      accessModes:
      - ReadWriteOnce
      persistentVolumeReclaimPolicy: Retain
      hostPath:
        path: /data/postgres

**Persistent Volume Claim**

.. code-block:: yaml

    # Request storage
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: postgres-pvc
    spec:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 10Gi

**Using PVC in Pod**

.. code-block:: yaml

    # Pod using PVC
    apiVersion: v1
    kind: Pod
    metadata:
      name: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
      volumes:
      - name: postgres-storage
        persistentVolumeClaim:
          claimName: postgres-pvc

===============
Storage Classes
===============

**Dynamic Provisioning**

Storage Classes enable automatic PV creation when PVCs are requested.

.. code-block:: yaml

    # AWS EBS Storage Class
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: fast-ssd
    provisioner: ebs.csi.aws.com
    parameters:
      type: gp3
      fsType: ext4
    reclaimPolicy: Delete
    allowVolumeExpansion: true

**Using Storage Class**

.. code-block:: yaml

    # PVC with Storage Class
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: app-storage
    spec:
      accessModes:
      - ReadWriteOnce
      storageClassName: fast-ssd
      resources:
        requests:
          storage: 20Gi

===================
StatefulSet Storage
===================

**Volume Claim Templates**

StatefulSets can automatically create PVCs for each pod.

.. code-block:: yaml

    # StatefulSet with storage
    apiVersion: apps/v1
    kind: StatefulSet
    metadata:
      name: database
    spec:
      serviceName: database
      replicas: 3
      selector:
        matchLabels:
          app: database
      template:
        metadata:
          labels:
            app: database
        spec:
          containers:
          - name: postgres
            image: postgres:15
            volumeMounts:
            - name: data
              mountPath: /var/lib/postgresql/data
      volumeClaimTemplates:
      - metadata:
          name: data
        spec:
          accessModes: ["ReadWriteOnce"]
          storageClassName: fast-ssd
          resources:
            requests:
              storage: 50Gi

=================================
ConfigMaps and Secrets as Volumes
=================================

**Configuration Files**

.. code-block:: yaml

    # ConfigMap as volume
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: nginx-config
    data:
      nginx.conf: |
        server {
          listen 80;
          location / {
            proxy_pass http://backend;
          }
        }

.. code-block:: yaml

    # Using ConfigMap in pod
    apiVersion: v1
    kind: Pod
    metadata:
      name: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        volumeMounts:
        - name: config
          mountPath: /etc/nginx/conf.d
      volumes:
      - name: config
        configMap:
          name: nginx-config

====================
Backup and Snapshots
====================

**Volume Snapshots**

.. code-block:: yaml

    # Create volume snapshot
    apiVersion: snapshot.storage.k8s.io/v1
    kind: VolumeSnapshot
    metadata:
      name: postgres-snapshot
    spec:
      source:
        persistentVolumeClaimName: postgres-pvc
      volumeSnapshotClassName: csi-hostpath-snapclass

**Restore from Snapshot**

.. code-block:: yaml

    # PVC from snapshot
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: postgres-restore
    spec:
      dataSource:
        name: postgres-snapshot
        kind: VolumeSnapshot
        apiGroup: snapshot.storage.k8s.io
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 10Gi

==================
Essential Commands
==================

.. code-block:: bash

    # Persistent Volumes
    kubectl get pv
    kubectl get pvc
    kubectl describe pv postgres-pv
    kubectl describe pvc postgres-pvc
    
    # Storage Classes
    kubectl get storageclass
    kubectl describe storageclass fast-ssd
    
    # Volume usage
    kubectl exec postgres-0 -- df -h /var/lib/postgresql/data
    
    # Snapshots
    kubectl get volumesnapshots
    kubectl get volumesnapshotclasses

============
What's Next?
============

Next, we'll explore **Configuration Management** with ConfigMaps and Secrets.

#####################
9.7 Security and RBAC
#####################

**Securing Kubernetes Clusters and Applications**

Kubernetes security involves multiple layers: cluster security, pod security, network security, and access control.

======================
Pod Security Standards
======================

**Securing Pod Configurations**

Pod Security Standards define security policies for pods.

.. code-block:: yaml

    # Restricted security context
    apiVersion: v1
    kind: Pod
    metadata:
      name: secure-pod
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        fsGroup: 2000
      containers:
      - name: app
        image: nginx:alpine
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          capabilities:
            drop:
            - ALL

**Namespace Security Policy**

.. code-block:: yaml

    # Enforce restricted policy
    apiVersion: v1
    kind: Namespace
    metadata:
      name: secure-namespace
      labels:
        pod-security.kubernetes.io/enforce: restricted
        pod-security.kubernetes.io/audit: restricted
        pod-security.kubernetes.io/warn: restricted

================================
RBAC (Role-Based Access Control)
================================

**Fine-Grained Access Control**

RBAC controls what users and services can do in the cluster.

**Role and RoleBinding**

.. code-block:: yaml

    # Role for reading pods
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
      namespace: production
      name: pod-reader
    rules:
    - apiGroups: [""]
      resources: ["pods"]
      verbs: ["get", "list", "watch"]

.. code-block:: yaml

    # Bind role to user
    apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
      name: read-pods
      namespace: production
    subjects:
    - kind: User
      name: jane
      apiGroup: rbac.authorization.k8s.io
    roleRef:
      kind: Role
      name: pod-reader
      apiGroup: rbac.authorization.k8s.io

**ClusterRole and ClusterRoleBinding**

.. code-block:: yaml

    # Cluster-wide role
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: node-reader
    rules:
    - apiGroups: [""]
      resources: ["nodes"]
      verbs: ["get", "list", "watch"]

**Service Account RBAC**

.. code-block:: yaml

    # Service Account
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: app-service-account
      namespace: production

.. code-block:: yaml

    # Role for service account
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
      namespace: production
      name: configmap-reader
    rules:
    - apiGroups: [""]
      resources: ["configmaps"]
      verbs: ["get", "list"]

================
Network Security
================

**Network Policies**

Control traffic between pods and external sources.

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

.. code-block:: yaml

    # Allow specific communication
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: allow-frontend-to-backend
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

==================
Secrets Management
==================

**Secure Secret Handling**

.. code-block:: yaml

    # Encrypted secret at rest
    apiVersion: v1
    kind: Secret
    metadata:
      name: secure-secret
    type: Opaque
    data:
      api-key: <base64-encoded-value>

**Using secrets securely:**

.. code-block:: yaml

    # Pod with secret volume
    apiVersion: v1
    kind: Pod
    metadata:
      name: secure-app
    spec:
      containers:
      - name: app
        image: myapp:latest
        volumeMounts:
        - name: secret-volume
          mountPath: /etc/secrets
          readOnly: true
      volumes:
      - name: secret-volume
        secret:
          secretName: secure-secret
          defaultMode: 0400  # Read-only for owner

==============
Image Security
==============

**Secure Container Images**

.. code-block:: yaml

    # Pod with image security
    apiVersion: v1
    kind: Pod
    metadata:
      name: secure-pod
    spec:
      containers:
      - name: app
        image: myregistry.com/myapp:v1.2.3@sha256:abc123...
        imagePullPolicy: Always
      imagePullSecrets:
      - name: registry-secret

==================
Essential Commands
==================

.. code-block:: bash

    # RBAC
    kubectl get roles,rolebindings
    kubectl get clusterroles,clusterrolebindings
    kubectl auth can-i get pods --as=jane
    kubectl auth can-i create deployments --as=system:serviceaccount:default:app-sa
    
    # Security contexts
    kubectl get pod secure-pod -o jsonpath='{.spec.securityContext}'
    
    # Network policies
    kubectl get networkpolicies
    kubectl describe networkpolicy default-deny-all
    
    # Secrets
    kubectl get secrets
    kubectl create secret docker-registry registry-secret \
      --docker-server=myregistry.com \
      --docker-username=user \
      --docker-password=pass

============
What's Next?
============

Next, we'll explore **Observability and Monitoring** to gain visibility into your applications and cluster.

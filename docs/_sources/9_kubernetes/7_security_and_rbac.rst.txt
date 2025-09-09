#####################
9.7 Security and RBAC
#####################

**Securing Kubernetes Clusters and Applications**

Kubernetes security involves multiple layers: cluster security, pod security, network security, and access control.

======================
Pod Security Standards
======================

**Modern Pod Security (Replacing Pod Security Policies)**

Pod Security Standards provide three predefined security profiles: Privileged, Baseline, and Restricted.

**Pod Security Standard Levels**

- **Privileged**: Unrestricted policy (no restrictions)
- **Baseline**: Minimally restrictive policy (prevents known privilege escalations)
- **Restricted**: Heavily restricted policy (follows security best practices)

**Namespace-Level Pod Security**

.. code-block:: yaml

    # Enforce restricted pod security at namespace level
    apiVersion: v1
    kind: Namespace
    metadata:
      name: secure-namespace
      labels:
        pod-security.kubernetes.io/enforce: restricted
        pod-security.kubernetes.io/audit: restricted
        pod-security.kubernetes.io/warn: restricted
        pod-security.kubernetes.io/enforce-version: v1.28

**Secure Pod Configuration**

.. code-block:: yaml

    # Pod following restricted security standards
    apiVersion: v1
    kind: Pod
    metadata:
      name: secure-pod
      namespace: secure-namespace
    spec:
      serviceAccountName: restricted-sa
      securityContext:
        runAsNonRoot: true
        runAsUser: 65534
        runAsGroup: 65534
        fsGroup: 65534
        seccompProfile:
          type: RuntimeDefault
      containers:
      - name: app
        image: nginx:1.21-alpine
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 65534
          runAsGroup: 65534
          capabilities:
            drop:
            - ALL
          seccompProfile:
            type: RuntimeDefault
        volumeMounts:
        - name: tmp-volume
          mountPath: /tmp
        - name: var-cache-nginx
          mountPath: /var/cache/nginx
        - name: var-run
          mountPath: /var/run
        resources:
          limits:
            cpu: 100m
            memory: 128Mi
          requests:
            cpu: 50m
            memory: 64Mi
      volumes:
      - name: tmp-volume
        emptyDir: {}
      - name: var-cache-nginx
        emptyDir: {}
      - name: var-run
        emptyDir: {}

**Pod Security Policy Migration**

.. code-block:: bash

    # Check current PSP usage
    kubectl get psp
    kubectl get podsecuritypolicy
    
    # Validate pods against new standards
    kubectl label --dry-run=server --overwrite ns production \
      pod-security.kubernetes.io/enforce=restricted
    
    # Gradual migration approach
    kubectl label ns production pod-security.kubernetes.io/warn=restricted
    kubectl label ns production pod-security.kubernetes.io/audit=restricted
    # After validation, enforce
    kubectl label ns production pod-security.kubernetes.io/enforce=restricted

===========================
Runtime Security with Falco
===========================

**Falco for Runtime Threat Detection**

Falco detects unexpected behavior and security threats in real-time using kernel-level monitoring.

**Falco Installation**

.. code-block:: bash

    # Install Falco using Helm
    helm repo add falcosecurity https://falcosecurity.github.io/charts
    helm repo update
    
    # Install with default configuration
    helm install falco falcosecurity/falco \
      --namespace falco-system \
      --create-namespace \
      --set falco.grpc.enabled=true \
      --set falco.grpcOutput.enabled=true

**Falco Rules Configuration**

.. code-block:: yaml

    # Custom Falco rules
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: falco-rules
      namespace: falco-system
    data:
      custom-rules.yaml: |
        - rule: Unauthorized Process in Container
          desc: Detect unauthorized processes in containers
          condition: >
            spawned_process and container and 
            not proc.name in (nginx, apache2, httpd, node, python, java)
          output: >
            Unauthorized process spawned in container 
            (user=%user.name command=%proc.cmdline container=%container.name 
            image=%container.image.repository:%container.image.tag)
          priority: WARNING
          tags: [process, container]
        
        - rule: Sensitive File Access
          desc: Detect access to sensitive files
          condition: >
            open_read and sensitive_files and 
            not proc.name in (systemd, kubelet, dockerd)
          output: >
            Sensitive file opened for reading 
            (user=%user.name command=%proc.cmdline file=%fd.name 
            container=%container.name)
          priority: WARNING
          tags: [filesystem, container]
        
        - macro: sensitive_files
          condition: >
            fd.name startswith /etc/passwd or
            fd.name startswith /etc/shadow or
            fd.name startswith /etc/ssh/ or
            fd.name startswith /root/.ssh/

**Falco Integration with External Systems**

.. code-block:: yaml

    # Falco with Slack notifications
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: falco-config
      namespace: falco-system
    data:
      falco.yaml: |
        outputs:
          rate: 1
          max_burst: 1000
        
        outputs_file:
          enabled: true
          keep_alive: false
          filename: /var/log/falco.log
        
        http_output:
          enabled: true
          url: "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
          user_agent: "falco/0.34.1"
        
        program_output:
          enabled: true
          keep_alive: false
          program: 'curl -X POST -H "Content-Type: application/json" -d @- https://your-webhook-url.com/falco'

=======================
Image Scanning Security
=======================

**Trivy Image Scanning**

.. code-block:: bash

    # Install Trivy
    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
    
    # Scan container image
    trivy image nginx:latest
    
    # Scan with specific severity
    trivy image --severity HIGH,CRITICAL nginx:latest
    
    # Output as JSON for automation
    trivy image --format json --output results.json nginx:latest

**Trivy Operator for Kubernetes**

.. code-block:: bash

    # Install Trivy Operator
    kubectl apply -f https://raw.githubusercontent.com/aquasecurity/trivy-operator/main/deploy/static/trivy-operator.yaml

.. code-block:: yaml

    # Trivy scan configuration
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: trivy-operator
      namespace: trivy-system
    data:
      config.yaml: |
        vulnerabilityReports:
          scanner: Trivy
        configAuditReports:
          scanner: Trivy
        compliance:
          cron: "0 */6 * * *"
        trivy:
          severity: CRITICAL,HIGH,MEDIUM
          ignoreUnfixed: true
          timeout: 5m

**Admission Controller for Image Scanning**

.. code-block:: yaml

    # ValidatingAdmissionWebhook for image scanning
    apiVersion: admissionregistration.k8s.io/v1
    kind: ValidatingAdmissionWebhook
    metadata:
      name: image-security-webhook
    webhooks:
    - name: image-scan.security.io
      clientConfig:
        service:
          name: image-scanner
          namespace: security-system
          path: "/scan"
      rules:
      - operations: ["CREATE", "UPDATE"]
        apiGroups: [""]
        apiVersions: ["v1"]
        resources: ["pods"]
      - operations: ["CREATE", "UPDATE"]
        apiGroups: ["apps"]
        apiVersions: ["v1"]
        resources: ["deployments", "replicasets"]

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

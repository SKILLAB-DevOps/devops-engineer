#######################
9.10 GitOps with ArgoCD
#######################

**Declarative Deployment Automation**

GitOps uses Git repositories as the source of truth for deployment configuration, with tools like ArgoCD and Flux automating the deployment process.

=============
ArgoCD Basics
=============

**Installing ArgoCD**

.. code-block:: bash

    # Install ArgoCD
    kubectl create namespace argocd
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    
    # Access ArgoCD UI
    kubectl port-forward svc/argocd-server -n argocd 8080:443
    
    # Get admin password
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

======================
Application Deployment
======================

**Basic Application**

.. code-block:: yaml

    # Basic ArgoCD Application
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: webapp
      namespace: argocd
    spec:
      project: default
      source:
        repoURL: https://github.com/company/k8s-manifests
        targetRevision: HEAD
        path: webapp
      destination:
        server: https://kubernetes.default.svc
        namespace: production
      syncPolicy:
        automated:
          prune: true
          selfHeal: true

===================
Flux v2 Alternative
===================

**Why Choose Flux v2?**

- **Kubernetes-native**: Uses CRDs for configuration
- **Multi-tenancy**: Built-in support for multiple teams
- **OCI Support**: Can store manifests in OCI registries
- **Helm Integration**: Native Helm controller
- **Notification System**: Rich notification capabilities

**Flux v2 Installation**

.. code-block:: bash

    # Install Flux CLI
    curl -s https://fluxcd.io/install.sh | sudo bash
    
    # Bootstrap Flux on cluster
    export GITHUB_TOKEN=<your-token>
    flux bootstrap github \
      --owner=<github-username> \
      --repository=<repository-name> \
      --branch=main \
      --path=./clusters/production \
      --personal

**Flux v2 GitRepository and Kustomization**

.. code-block:: yaml

    # GitRepository source
    apiVersion: source.toolkit.fluxcd.io/v1beta2
    kind: GitRepository
    metadata:
      name: webapp-source
      namespace: flux-system
    spec:
      interval: 1m
      ref:
        branch: main
      url: https://github.com/company/k8s-manifests
      secretRef:
        name: git-credentials

.. code-block:: yaml

    # Kustomization for deployment
    apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
    kind: Kustomization
    metadata:
      name: webapp
      namespace: flux-system
    spec:
      interval: 5m
      path: "./webapp/overlays/production"
      prune: true
      sourceRef:
        kind: GitRepository
        name: webapp-source
      validation: client
      healthChecks:
      - apiVersion: apps/v1
        kind: Deployment
        name: webapp
        namespace: production

**Flux v2 Helm Integration**

.. code-block:: yaml

    # HelmRepository source
    apiVersion: source.toolkit.fluxcd.io/v1beta2
    kind: HelmRepository
    metadata:
      name: bitnami
      namespace: flux-system
    spec:
      interval: 24h
      url: https://charts.bitnami.com/bitnami

.. code-block:: yaml

    # HelmRelease
    apiVersion: helm.toolkit.fluxcd.io/v2beta1
    kind: HelmRelease
    metadata:
      name: nginx
      namespace: flux-system
    spec:
      interval: 5m
      chart:
        spec:
          chart: nginx
          version: "13.x.x"
          sourceRef:
            kind: HelmRepository
            name: bitnami
            namespace: flux-system
      values:
        replicaCount: 3
        service:
          type: LoadBalancer

**Flux v2 Multi-Tenancy**

.. code-block:: yaml

    # Tenant configuration
    apiVersion: v1
    kind: Namespace
    metadata:
      name: team-a
      labels:
        toolkit.fluxcd.io/tenant: team-a

.. code-block:: yaml

    # Tenant-specific Kustomization
    apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
    kind: Kustomization
    metadata:
      name: team-a-apps
      namespace: team-a
    spec:
      interval: 5m
      path: "./teams/team-a"
      prune: true
      sourceRef:
        kind: GitRepository
        name: fleet-infra
        namespace: flux-system
      serviceAccountName: team-a-reconciler

=========================
ArgoCD vs Flux Comparison
=========================

+------------------+------------------+----------------------+
| Feature          | ArgoCD           | Flux v2              |
+==================+==================+======================+
| UI Dashboard     | Rich Web UI      | CLI + Kubernetes     |
+------------------+------------------+----------------------+
| Architecture     | Server-based     | Agent-based          |
+------------------+------------------+----------------------+
| Multi-cluster    | Excellent        | Good                 |
+------------------+------------------+----------------------+
| Helm Support     | Built-in         | Dedicated Controller |
+------------------+------------------+----------------------+
| RBAC             | Application-level| Kubernetes-native    |
+------------------+------------------+----------------------+
| Git Providers    | Multiple         | Multiple + OCI       |
+------------------+------------------+----------------------+
| Learning Curve   | Medium           | Steeper              |
+------------------+------------------+----------------------+
| Resource Usage   | Higher           | Lower                |
+------------------+------------------+----------------------+

**When to Choose ArgoCD:**

- Need rich UI for visualization
- Multiple teams with different access levels
- Complex multi-cluster deployments
- Prefer centralized control

**When to Choose Flux v2:**

- Kubernetes-native approach preferred
- Lower resource overhead required
- OCI registry support needed
- Strong multi-tenancy requirements

**Helm Application**

.. code-block:: yaml

    # ArgoCD Application for Helm chart
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: postgres
      namespace: argocd
    spec:
      project: default
      source:
        chart: postgresql
        repoURL: https://charts.bitnami.com/bitnami
        targetRevision: 11.6.12
        helm:
          values: |
            auth:
              postgresPassword: "secret123"
            primary:
              persistence:
                size: 20Gi
      destination:
        server: https://kubernetes.default.svc
        namespace: database

=======================
Multi-Environment Setup
=======================

**Environment-Specific Applications**

.. code-block:: yaml

    # Development environment
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: webapp-dev
      namespace: argocd
    spec:
      source:
        repoURL: https://github.com/company/k8s-manifests
        targetRevision: develop
        path: webapp
        helm:
          valueFiles:
          - values-dev.yaml
      destination:
        namespace: development

.. code-block:: yaml

    # Production environment
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: webapp-prod
      namespace: argocd
    spec:
      source:
        repoURL: https://github.com/company/k8s-manifests
        targetRevision: main
        path: webapp
        helm:
          valueFiles:
          - values-prod.yaml
      destination:
        namespace: production

================
Application Sets
================

**Managing Multiple Applications**

.. code-block:: yaml

    # ApplicationSet for multiple environments
    apiVersion: argoproj.io/v1alpha1
    kind: ApplicationSet
    metadata:
      name: webapp-environments
      namespace: argocd
    spec:
      generators:
      - list:
          elements:
          - cluster: dev
            namespace: development
            branch: develop
          - cluster: prod
            namespace: production
            branch: main
      template:
        metadata:
          name: webapp-{{cluster}}
        spec:
          project: default
          source:
            repoURL: https://github.com/company/k8s-manifests
            targetRevision: '{{branch}}'
            path: webapp
          destination:
            server: https://kubernetes.default.svc
            namespace: '{{namespace}}'

=============
Sync Policies
=============

**Automated and Manual Sync**

.. code-block:: yaml

    # Automated sync with policies
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: webapp
    spec:
      syncPolicy:
        automated:
          prune: true       # Delete removed resources
          selfHeal: true    # Correct drift
        syncOptions:
        - CreateNamespace=true
        - PrunePropagationPolicy=foreground
        retry:
          limit: 5
          backoff:
            duration: 5s
            factor: 2
            maxDuration: 3m

==================
Essential Commands
==================

.. code-block:: bash

    # ArgoCD CLI
    argocd login localhost:8080
    argocd app list
    argocd app get webapp
    argocd app sync webapp
    argocd app diff webapp
    
    # Application management
    kubectl get applications -n argocd
    kubectl describe application webapp -n argocd

============
What's Next?
============

Next, we'll explore **Production Best Practices** for running Kubernetes in production environments.

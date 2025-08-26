#######################
9.10 GitOps with ArgoCD
#######################

**Declarative Deployment Automation**

GitOps uses Git repositories as the source of truth for deployment configuration, with ArgoCD automating the deployment process.

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

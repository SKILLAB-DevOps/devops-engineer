#################
9.5 ArgoCD GitOps
#################

**Git-Driven Deployments**

Your CI/CD pipelines build and test applications. Your Helm charts package them. ArgoCD completes the automation with GitOps - where Git commits automatically trigger production deployments. No more manual kubectl commands or complex scripts.

Think: **Git push = Deploy to production**. Every change tracked, reviewed, and auditable.

================
GitOps in Action
================

**Git as Single Source of Truth**

GitOps makes Git the control center for your infrastructure:

.. list-table::
   :header-rows: 1
   :widths: 30 35 35

   * - Traditional CI/CD
     - GitOps with ArgoCD
     - Benefits
   * - Pipeline pushes to cluster
     - Git triggers deployment
     - Full audit trail
   * - Credentials in CI system
     - Cluster pulls from Git
     - Better security
   * - Hard to rollback
     - Git revert = instant rollback
     - Easy recovery
   * - Manual drift detection
     - Automatic drift correction
     - Self-healing

**How It Works:**
1. **Developer** pushes code → CI builds image
2. **CI system** updates deployment repo with new image tag
3. **ArgoCD** detects Git changes and applies them to cluster
4. **Production** automatically updates to match Git state

==============
Install ArgoCD
==============

**Quick Setup**

Install ArgoCD in your cluster:

.. code-block:: bash

    # Create namespace
    kubectl create namespace argocd
    
    # Install ArgoCD
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    
    # Wait for pods to be ready
    kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s

**Access ArgoCD UI:**

.. code-block:: bash

    # Get initial admin password
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
    
    # Port forward to access UI
    kubectl port-forward svc/argocd-server -n argocd 8080:443
    
    # Access at https://localhost:8080
    # Username: admin
    # Password: (from command above)

**Install ArgoCD CLI:**

.. code-block:: bash

    # Linux/macOS
    curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
    
    # Login via CLI
    argocd login localhost:8080

===========================
GitOps Repository Structure
===========================

**Separate Config from Code**

Organize your repositories for GitOps:

.. code-block:: text

    # Application Repository (webapp-api)
    webapp-api/
    ├── src/                    # Application code
    ├── Dockerfile              # Container build
    ├── .github/workflows/      # CI pipeline
    └── README.md
    
    # Configuration Repository (webapp-config)
    webapp-config/
    ├── environments/
    │   ├── development/
    │   │   ├── values.yaml     # Dev configuration
    │   │   └── application.yaml
    │   ├── staging/
    │   │   ├── values.yaml     # Staging configuration
    │   │   └── application.yaml
    │   └── production/
    │       ├── values.yaml     # Production configuration
    │       └── application.yaml
    ├── charts/
    │   └── webapp/             # Helm chart
    └── README.md

**Why Separate Repositories?**

- **Security**: Config repo has different access controls
- **Release Cycle**: App changes != config changes
- **Clear Responsibility**: Developers own code, DevOps owns config
- **Audit Trail**: Clear separation of what changed where

=====================
Setup GitOps Workflow
=====================

**Complete CI/CD + GitOps Pipeline**

Update your GitHub Actions to work with ArgoCD:

.. code-block:: yaml

    # .github/workflows/ci-cd.yml (in webapp-api repo)
    name: CI/CD Pipeline
    
    on:
      push:
        branches: [main, develop]
    
    jobs:
      test-and-build:
        runs-on: ubuntu-latest
        outputs:
          image_tag: ${{ steps.tag.outputs.tag }}
        steps:
          - uses: actions/checkout@v4
          
          - name: Run tests
            run: |
              pip install -r requirements.txt
              pytest
          
          - name: Generate image tag
            id: tag
            run: echo "tag=sha-$(git rev-parse --short HEAD)" >> $GITHUB_OUTPUT
          
          - name: Build and push image
            run: |
              docker build -t myregistry/webapp:${{ steps.tag.outputs.tag }} .
              docker push myregistry/webapp:${{ steps.tag.outputs.tag }}
      
      update-config:
        needs: test-and-build
        runs-on: ubuntu-latest
        steps:
          - name: Update deployment config
            uses: fjogeleit/yaml-update-action@main
            with:
              repository: mycompany/webapp-config
              token: ${{ secrets.CONFIG_REPO_TOKEN }}
              workDir: environments/development
              fileName: values.yaml
              propertyPath: 'image.tag'
              value: ${{ needs.test-and-build.outputs.image_tag }}
              branch: main
              createPR: false
              message: 'Update development image to ${{ needs.test-and-build.outputs.image_tag }}'

**Config Repository Structure (webapp-config):**

.. code-block:: yaml

    # environments/development/values.yaml
    image:
      repository: myregistry/webapp
      tag: "sha-abc123"  # Updated by CI pipeline
      pullPolicy: Always
    
    replicaCount: 1
    
    resources:
      requests:
        memory: "128Mi"
        cpu: "100m"
    
    ingress:
      host: webapp-dev.example.com
    
    postgresql:
      enabled: true

.. code-block:: yaml

    # environments/production/values.yaml
    image:
      repository: myregistry/webapp
      tag: "sha-def456"  # Updated manually or via promotion workflow
      pullPolicy: IfNotPresent
    
    replicaCount: 5
    
    resources:
      requests:
        memory: "512Mi"
        cpu: "500m"
    
    ingress:
      host: webapp.example.com
      tls: true
    
    postgresql:
      enabled: true
      primary:
        persistence:
          size: 100Gi

==========================
Create ArgoCD Applications
==========================

**Configure ArgoCD to Watch Your Repos**

Create ArgoCD applications for each environment:

.. code-block:: yaml

    # environments/development/application.yaml
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: webapp-dev
      namespace: argocd
      finalizers:
        - resources-finalizer.argocd.argoproj.io
    spec:
      project: default
      source:
        repoURL: https://github.com/mycompany/webapp-config.git
        targetRevision: HEAD
        path: charts/webapp
        helm:
          valueFiles:
            - ../../environments/development/values.yaml
      destination:
        server: https://kubernetes.default.svc
        namespace: development
      syncPolicy:
        automated:
          prune: true        # Remove resources not in Git
          selfHeal: true     # Fix manual changes
        syncOptions:
          - CreateNamespace=true

.. code-block:: yaml

    # environments/production/application.yaml
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: webapp-prod
      namespace: argocd
      finalizers:
        - resources-finalizer.argocd.argoproj.io
    spec:
      project: default
      source:
        repoURL: https://github.com/mycompany/webapp-config.git
        targetRevision: HEAD
        path: charts/webapp
        helm:
          valueFiles:
            - ../../environments/production/values.yaml
      destination:
        server: https://kubernetes.default.svc
        namespace: production
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
          - CreateNamespace=true

**Apply ArgoCD Applications:**

.. code-block:: bash

    # Create development application
    kubectl apply -f environments/development/application.yaml
    
    # Create production application  
    kubectl apply -f environments/production/application.yaml

=====================
Environment Promotion
=====================

**Promote Between Environments**

Create a promotion workflow for moving changes from dev → staging → production:

.. code-block:: yaml

    # .github/workflows/promote.yml (in webapp-config repo)
    name: Promote to Production
    
    on:
      workflow_dispatch:
        inputs:
          image_tag:
            description: 'Image tag to promote'
            required: true
            type: string
    
    jobs:
      promote:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          
          - name: Update production config
            run: |
              # Update production values.yaml with new image tag
              sed -i 's/tag: ".*"/tag: "${{ github.event.inputs.image_tag }}"/' environments/production/values.yaml
              
              # Commit changes
              git config user.name "GitHub Actions"
              git config user.email "actions@github.com"
              git add environments/production/values.yaml
              git commit -m "Promote ${{ github.event.inputs.image_tag }} to production"
              git push

**Automated Promotion (Optional):**

.. code-block:: yaml

    # Auto-promote successful staging deployments
    promote-to-production:
      needs: verify-staging
      if: success()
      runs-on: ubuntu-latest
      steps:
        - name: Get current staging image
          run: |
            STAGING_IMAGE=$(kubectl get deployment webapp-staging -n staging -o jsonpath='{.spec.template.spec.containers[0].image}')
            echo "STAGING_IMAGE=$STAGING_IMAGE" >> $GITHUB_ENV
        
        - name: Update production config
          uses: fjogeleit/yaml-update-action@main
          with:
            repository: mycompany/webapp-config
            token: ${{ secrets.CONFIG_REPO_TOKEN }}
            workDir: environments/production
            fileName: values.yaml
            propertyPath: 'image.tag'
            value: ${{ env.STAGING_IMAGE }}
            message: 'Auto-promote ${{ env.STAGING_IMAGE }} to production'

=============================
ArgoCD Dashboard & Operations
=============================

**Monitor Your Deployments**

ArgoCD provides a comprehensive dashboard:

.. code-block:: bash

    # Access ArgoCD UI
    kubectl port-forward svc/argocd-server -n argocd 8080:443
    
    # View applications
    argocd app list
    
    # Get application details
    argocd app get webapp-dev
    
    # Sync application manually
    argocd app sync webapp-dev
    
    # View application history
    argocd app history webapp-dev

**Key Dashboard Features:**

- **Application Health**: Green/Yellow/Red status for each app
- **Sync Status**: Whether cluster matches Git state
- **Resource Tree**: Visual representation of all Kubernetes resources
- **Deployment History**: Timeline of all changes
- **Rollback Capability**: One-click rollback to previous versions

=================
Disaster Recovery
=================

**Self-Healing Infrastructure**

ArgoCD automatically fixes configuration drift:

.. code-block:: bash

    # Someone manually changes production
    kubectl scale deployment webapp-prod --replicas=10 -n production
    
    # ArgoCD detects drift and fixes it automatically
    # (if selfHeal is enabled)
    
    # Manual sync if needed
    argocd app sync webapp-prod

**Rollback Scenarios:**

.. code-block:: bash

    # Bad deployment? Revert Git commit
    git revert HEAD
    git push
    # ArgoCD automatically rolls back
    
    # Emergency rollback via ArgoCD
    argocd app rollback webapp-prod
    
    # Or via UI: Select previous version and sync

=======================
Security Best Practices
=======================

**Secure GitOps Setup**

.. code-block:: yaml

    # ArgoCD RBAC configuration
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: argocd-rbac-cm
      namespace: argocd
    data:
      policy.default: role:readonly
      policy.csv: |
        # Developer role - can view and sync dev apps
        p, role:developer, applications, get, default/webapp-dev, allow
        p, role:developer, applications, sync, default/webapp-dev, allow
        
        # DevOps role - full access to all environments
        p, role:devops, applications, *, *, allow
        p, role:devops, clusters, *, *, allow
        
        # Bind users to roles
        g, dev-team, role:developer
        g, devops-team, role:devops

**Repository Access:**

.. code-block:: yaml

    # ArgoCD repository credentials
    apiVersion: v1
    kind: Secret
    metadata:
      name: webapp-config-repo
      namespace: argocd
      labels:
        argocd.argoproj.io/secret-type: repository
    stringData:
      type: git
      url: https://github.com/mycompany/webapp-config.git
      password: your-github-token
      username: not-used

=========================
Essential ArgoCD Commands
=========================

**Daily Operations:**

.. code-block:: bash

    # Application management
    argocd app create webapp-dev --repo https://github.com/mycompany/webapp-config.git --path charts/webapp --dest-server https://kubernetes.default.svc --dest-namespace development
    argocd app list
    argocd app get webapp-dev
    argocd app delete webapp-dev
    
    # Sync operations
    argocd app sync webapp-dev              # Manual sync
    argocd app sync webapp-dev --prune      # Sync and remove extra resources
    argocd app refresh webapp-dev           # Refresh Git cache
    
    # History and rollbacks
    argocd app history webapp-dev
    argocd app rollback webapp-dev 5        # Rollback to revision 5
    
    # Configuration
    argocd repo add https://github.com/mycompany/webapp-config.git --username youruser --password yourtoken
    argocd cluster add kubernetes-context-name
    
    # Troubleshooting
    argocd app logs webapp-dev
    argocd app diff webapp-dev               # Show what would change
    argocd app wait webapp-dev               # Wait for sync to complete

=======================
Complete GitOps Example
=======================

**End-to-End Workflow**

Here's how everything works together:

**1. Developer Workflow:**

.. code-block:: bash

    # Developer makes changes
    git add src/app.py
    git commit -m "Add new feature"
    git push origin main

**2. CI Pipeline (Auto-triggered):**

.. code-block:: bash

    # GitHub Actions runs:
    # 1. Tests pass
    # 2. Builds image: myregistry/webapp:sha-abc123
    # 3. Updates webapp-config/environments/development/values.yaml
    # 4. Commits to config repo

**3. ArgoCD (Auto-sync):**

.. code-block:: bash

    # ArgoCD detects Git change
    # Applies new configuration to development namespace
    # Developer sees changes in dev environment

**4. Production Promotion:**

.. code-block:: bash

    # Manual approval process
    # Update production values.yaml with tested image tag
    # ArgoCD automatically deploys to production

**Benefits Achieved:**

- **Full Automation** - Git push → production deployment
- **Complete Audit Trail** - Every change tracked in Git
- **Easy Rollbacks** - Git revert = instant rollback
- **Self-Healing** - Cluster automatically matches Git state
- **Security** - No cluster credentials in CI systems
- **Multi-Environment** - Consistent process across all environments

============
What's Next?
============

**Production Best Practices**

You now understand GitOps with ArgoCD:

- **GitOps Principles** - Git as single source of truth
- **ArgoCD Setup** - Installation and configuration
- **Repository Structure** - Separate code from config
- **Automated Workflows** - CI/CD + GitOps integration
- **Environment Promotion** - Safe production deployments
- **Security & RBAC** - Secure access controls
- **Disaster Recovery** - Rollbacks and self-healing

Next: **Production Best Practices** for monitoring, logging, security, and operational excellence in Kubernetes environments.

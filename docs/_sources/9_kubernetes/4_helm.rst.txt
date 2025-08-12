########################
9.4 Helm Package Manager
########################

**From YAML Files to Reusable Packages**

You've mastered Kubernetes deployments, but managing dozens of YAML files across environments gets complex fast. Helm transforms this into package management - templated, versioned, and reusable deployments that integrate with your CI/CD pipelines.

Think of Helm as the npm for Kubernetes - but beyond simple installation, it provides templating, versioning, and lifecycle management.

================
Why Helm Matters
================

**Problems Helm Solves:**

- **Configuration Chaos** - Different values for dev/staging/production
- **YAML Explosion** - 10+ files become unmanageable  
- **No Versioning** - Can't track or rollback application versions
- **Copy-Paste Deployments** - No reusability across teams
- **Dependency Hell** - Apps need databases, caches, monitoring

**Helm Concepts:**

.. list-table::
   :header-rows: 1
   :widths: 20 30 50

   * - Component
     - What It Is
     - Example
   * - **Chart**
     - Templated Kubernetes package
     - Your webapp with configurable values
   * - **Release**
     - Installed chart instance
     - webapp-prod running in production
   * - **Values**
     - Configuration for templates
     - Different settings per environment
   * - **Repository**
     - Chart storage
     - Company chart registry

=====================
Your First Helm Chart
=====================

**From Kubernetes Manifests to Templates**

Transform your webapp deployment into a reusable Helm chart:

.. code-block:: bash

    # Create chart structure
    helm create webapp
    
    # See what's generated
    tree webapp

**Chart Structure:**

.. code-block:: text

    webapp/
    ├── Chart.yaml          # Chart metadata
    ├── values.yaml         # Default configuration
    ├── templates/          # Kubernetes templates
    │   ├── deployment.yaml
    │   ├── service.yaml
    │   ├── ingress.yaml
    │   └── configmap.yaml
    └── charts/             # Dependencies

**Chart.yaml - Metadata:**

.. code-block:: yaml

    apiVersion: v2
    name: webapp
    description: Production-ready web application
    version: 1.0.0          # Chart version
    appVersion: "1.3.0"     # App version
    
    dependencies:
    - name: postgresql
      version: "12.1.0"
      repository: "https://charts.bitnami.com/bitnami"
      condition: postgresql.enabled

**values.yaml - Configuration:**

.. code-block:: yaml

    # Default configuration
    image:
      repository: myregistry/webapp
      tag: "1.3.0"
      pullPolicy: IfNotPresent
    
    replicaCount: 3
    
    resources:
      requests:
        memory: "256Mi"
        cpu: "250m"
      limits:
        memory: "512Mi"
        cpu: "500m"
    
    service:
      type: ClusterIP
      port: 80
    
    ingress:
      enabled: true
      host: webapp.example.com
      tls: true
    
    autoscaling:
      enabled: true
      minReplicas: 3
      maxReplicas: 20
      targetCPU: 70
    
    env:
      LOG_LEVEL: "INFO"
      ENVIRONMENT: "production"
    
    postgresql:
      enabled: true
      auth:
        database: webapp

========================
Template Your Deployment
========================

**Dynamic Kubernetes Manifests**

Transform static YAML into dynamic templates:

.. code-block:: yaml

    # templates/deployment.yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: {{ include "webapp.fullname" . }}
      labels:
        {{- include "webapp.labels" . | nindent 4 }}
    spec:
      {{- if not .Values.autoscaling.enabled }}
      replicas: {{ .Values.replicaCount }}
      {{- end }}
      strategy:
        type: RollingUpdate
        rollingUpdate:
          maxSurge: 1
          maxUnavailable: 0
      selector:
        matchLabels:
          {{- include "webapp.selectorLabels" . | nindent 6 }}
      template:
        metadata:
          annotations:
            checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}
          labels:
            {{- include "webapp.selectorLabels" . | nindent 8 }}
        spec:
          containers:
          - name: {{ .Chart.Name }}
            image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
            imagePullPolicy: {{ .Values.image.pullPolicy }}
            ports:
            - name: http
              containerPort: 8080
            env:
            {{- range $key, $value := .Values.env }}
            - name: {{ $key }}
              value: {{ $value | quote }}
            {{- end }}
            {{- if .Values.postgresql.enabled }}
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: {{ include "webapp.fullname" . }}-postgres
                  key: database-url
            {{- end }}
            livenessProbe:
              httpGet:
                path: /health
                port: http
              initialDelaySeconds: 30
            readinessProbe:
              httpGet:
                path: /ready
                port: http
              initialDelaySeconds: 10
            resources:
              {{- toYaml .Values.resources | nindent 12 }}

**Helper Templates (_helpers.tpl):**

.. code-block:: yaml

    {{/*
    Common labels
    */}}
    {{- define "webapp.labels" -}}
    helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
    {{ include "webapp.selectorLabels" . }}
    app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
    app.kubernetes.io/managed-by: {{ .Release.Service }}
    {{- end }}

    {{/*
    Selector labels
    */}}
    {{- define "webapp.selectorLabels" -}}
    app.kubernetes.io/name: {{ .Chart.Name }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    {{- end }}

    {{/*
    Create a default fully qualified app name
    */}}
    {{- define "webapp.fullname" -}}
    {{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
    {{- end }}

============================
Multi-Environment Deployment
============================

**Environment-Specific Values**

Create different configurations for each environment:

**Development (values-dev.yaml):**

.. code-block:: yaml

    replicaCount: 1
    
    image:
      tag: "latest"
      pullPolicy: Always
    
    resources:
      requests:
        memory: "128Mi"
        cpu: "100m"
      limits:
        memory: "256Mi"
        cpu: "200m"
    
    env:
      LOG_LEVEL: "DEBUG"
      ENVIRONMENT: "development"
    
    ingress:
      host: webapp-dev.example.com
      tls: false
    
    autoscaling:
      enabled: false
    
    postgresql:
      auth:
        database: webapp_dev

**Production (values-prod.yaml):**

.. code-block:: yaml

    replicaCount: 5
    
    image:
      tag: "1.3.0"
      pullPolicy: IfNotPresent
    
    resources:
      requests:
        memory: "512Mi"
        cpu: "500m"
      limits:
        memory: "1Gi"
        cpu: "1000m"
    
    env:
      LOG_LEVEL: "WARN"
      ENVIRONMENT: "production"
    
    ingress:
      host: webapp.example.com
      tls: true
      annotations:
        nginx.ingress.kubernetes.io/rate-limit: "100"
    
    autoscaling:
      enabled: true
      minReplicas: 5
      maxReplicas: 50
    
    postgresql:
      primary:
        persistence:
          size: 100Gi

**Deploy to Environments:**

.. code-block:: bash

    # Development
    helm upgrade --install webapp-dev ./webapp \
      --namespace development \
      --create-namespace \
      --values values-dev.yaml
    
    # Production
    helm upgrade --install webapp-prod ./webapp \
      --namespace production \
      --create-namespace \
      --values values-prod.yaml

===============
CI/CD with Helm
===============

**Automated Helm Deployments**

Integrate Helm into your GitHub Actions workflow:

.. code-block:: yaml

    # .github/workflows/helm-deploy.yml
    name: Build and Deploy with Helm
    
    on:
      push:
        branches: [main, develop]
    
    jobs:
      build:
        runs-on: ubuntu-latest
        outputs:
          image_tag: ${{ steps.tag.outputs.tag }}
        steps:
          - uses: actions/checkout@v4
          
          - name: Get image tag
            id: tag
            run: echo "tag=sha-$(git rev-parse --short HEAD)" >> $GITHUB_OUTPUT
          
          - name: Build and push image
            run: |
              docker build -t myregistry/webapp:${{ steps.tag.outputs.tag }} .
              docker push myregistry/webapp:${{ steps.tag.outputs.tag }}
      
      deploy-dev:
        if: github.ref == 'refs/heads/develop'
        needs: build
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          
          - name: Setup Helm
            uses: azure/setup-helm@v3
          
          - name: Setup kubectl
            uses: azure/setup-kubectl@v3
          
          - name: Configure kubectl
            run: echo "${{ secrets.KUBE_CONFIG }}" | base64 -d > ~/.kube/config
          
          - name: Deploy to development
            run: |
              helm upgrade --install webapp-dev ./charts/webapp \
                --namespace development \
                --create-namespace \
                --values ./charts/webapp/values-dev.yaml \
                --set image.tag=${{ needs.build.outputs.image_tag }} \
                --wait --timeout=300s
      
      deploy-prod:
        if: github.ref == 'refs/heads/main'
        needs: build
        runs-on: ubuntu-latest
        environment: production
        steps:
          - uses: actions/checkout@v4
          
          - name: Setup Helm
            uses: azure/setup-helm@v3
          
          - name: Setup kubectl
            uses: azure/setup-kubectl@v3
          
          - name: Configure kubectl
            run: echo "${{ secrets.KUBE_CONFIG_PROD }}" | base64 -d > ~/.kube/config
          
          - name: Deploy to production
            run: |
              helm upgrade --install webapp-prod ./charts/webapp \
                --namespace production \
                --create-namespace \
                --values ./charts/webapp/values-prod.yaml \
                --set image.tag=${{ needs.build.outputs.image_tag }} \
                --wait --timeout=600s
          
          - name: Verify deployment
            run: |
              kubectl wait --for=condition=available deployment/webapp-prod -n production --timeout=300s
              kubectl get pods -l app.kubernetes.io/name=webapp -n production

==================
Chart Dependencies
==================

**Managing Database Dependencies**

Your app needs PostgreSQL and Redis. Helm manages these as dependencies:

.. code-block:: yaml

    # Chart.yaml
    dependencies:
    - name: postgresql
      version: "12.1.0"
      repository: "https://charts.bitnami.com/bitnami"
      condition: postgresql.enabled
    
    - name: redis
      version: "17.3.0"
      repository: "https://charts.bitnami.com/bitnami"
      condition: redis.enabled

**Install Dependencies:**

.. code-block:: bash

    # Download dependencies
    helm dependency update
    
    # Deploy with dependencies
    helm upgrade --install webapp ./webapp \
      --set postgresql.enabled=true \
      --set redis.enabled=true

**Override Dependency Values:**

.. code-block:: yaml

    # values.yaml
    postgresql:
      enabled: true
      auth:
        database: webapp
        username: webapp
        password: secretpassword
      primary:
        persistence:
          size: 20Gi
    
    redis:
      enabled: true
      auth:
        enabled: false
      replica:
        replicaCount: 2

==========================
Chart Testing & Validation
==========================

**Ensure Chart Quality**

Test your charts before deployment:

.. code-block:: yaml

    # templates/tests/test-connection.yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: "{{ include "webapp.fullname" . }}-test"
      annotations:
        "helm.sh/hook": test
    spec:
      restartPolicy: Never
      containers:
      - name: test
        image: busybox:1.35
        command: ['wget']
        args: ['{{ include "webapp.fullname" . }}:{{ .Values.service.port }}/health']

**Validation Commands:**

.. code-block:: bash

    # Lint chart
    helm lint ./webapp
    
    # Dry run
    helm install webapp-test ./webapp --dry-run --debug
    
    # Template validation
    helm template webapp ./webapp --values values-prod.yaml | kubectl apply --dry-run=client -f -
    
    # Run tests
    helm test webapp-prod -n production

================
Chart Repository
================

**Sharing Charts**

Package and share your charts:

.. code-block:: bash

    # Package chart
    helm package ./webapp
    
    # Create repository index
    helm repo index . --url https://charts.mycompany.com
    
    # Add custom repository
    helm repo add mycompany https://charts.mycompany.com
    helm repo update
    
    # Install from repository
    helm install webapp mycompany/webapp --version 1.0.0

=======================
Essential Helm Commands
=======================

**Daily Operations:**

.. code-block:: bash

    # Chart management
    helm create mychart
    helm package ./mychart
    helm lint ./mychart
    
    # Installation and upgrades
    helm install myapp ./mychart
    helm upgrade myapp ./mychart
    helm upgrade --install myapp ./mychart  # Install or upgrade
    
    # Release management
    helm list
    helm status myapp
    helm history myapp
    helm rollback myapp 1
    
    # Values and templates
    helm show values bitnami/postgresql
    helm template myapp ./mychart --values values-prod.yaml
    
    # Dependencies
    helm dependency update
    helm dependency build
    
    # Testing
    helm test myapp
    
    # Uninstall
    helm uninstall myapp

============
What's Next?
============

**GitOps with ArgoCD**

You now understand Helm package management:

- **Chart Creation** - Templated, reusable Kubernetes applications
- **Multi-Environment** - Different configurations per environment
- **CI/CD Integration** - Automated deployments with GitHub Actions
- **Dependency Management** - PostgreSQL, Redis, and other services
- **Testing & Validation** - Quality assurance for your charts
- **Chart Repositories** - Sharing and versioning charts

Next: **ArgoCD** for GitOps workflows that take deployment automation to the next level with declarative, Git-driven deployments.

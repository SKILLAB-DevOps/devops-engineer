###########################
9.9 Helm Package Management
###########################

**Managing Complex Kubernetes Applications**

Helm is the package manager for Kubernetes, making it easy to deploy and manage complex applications.

===========
Helm Basics
===========

**Charts, Releases, and Repositories**

.. code-block:: bash

    # Install Helm
    curl https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz | tar xz
    sudo mv linux-amd64/helm /usr/local/bin/
    
    # Add chart repositories
    helm repo add stable https://charts.helm.sh/stable
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo update

**Installing Applications**

.. code-block:: bash

    # Install from repository
    helm install my-nginx bitnami/nginx
    helm install postgres bitnami/postgresql --set auth.postgresPassword=secret123
    
    # List releases
    helm list
    helm status my-nginx

===============
Creating Charts
===============

**Basic Chart Structure**

.. code-block:: bash

    # Create new chart
    helm create webapp
    
    # Chart structure
    webapp/
    ├── Chart.yaml
    ├── values.yaml
    ├── templates/
    │   ├── deployment.yaml
    │   ├── service.yaml
    │   └── ingress.yaml
    └── charts/

**Chart.yaml**

.. code-block:: yaml

    # Chart metadata
    apiVersion: v2
    name: webapp
    description: A Helm chart for web application
    version: 0.1.0
    appVersion: "1.0.0"

**values.yaml**

.. code-block:: yaml

    # Default values
    replicaCount: 1
    
    image:
      repository: webapp
      tag: "latest"
      pullPolicy: IfNotPresent
    
    service:
      type: ClusterIP
      port: 80
    
    ingress:
      enabled: false
      host: webapp.example.com

=========
Templates
=========

**Templating with Go Templates**

.. code-block:: yaml

    # templates/deployment.yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: {{ include "webapp.fullname" . }}
      labels:
        {{- include "webapp.labels" . | nindent 4 }}
    spec:
      replicas: {{ .Values.replicaCount }}
      selector:
        matchLabels:
          {{- include "webapp.selectorLabels" . | nindent 6 }}
      template:
        metadata:
          labels:
            {{- include "webapp.selectorLabels" . | nindent 8 }}
        spec:
          containers:
            - name: {{ .Chart.Name }}
              image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
              ports:
                - name: http
                  containerPort: 8080

**Helpers Template**

.. code-block:: yaml

    # templates/_helpers.tpl
    {{- define "webapp.name" -}}
    {{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
    {{- end }}
    
    {{- define "webapp.fullname" -}}
    {{- $name := default .Chart.Name .Values.nameOverride }}
    {{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
    {{- end }}

=================
Managing Releases
=================

**Deployment and Updates**

.. code-block:: bash

    # Install with custom values
    helm install webapp ./webapp --set replicaCount=3
    helm install webapp ./webapp -f production-values.yaml
    
    # Upgrade releases
    helm upgrade webapp ./webapp --set image.tag=v2.0.0
    
    # Rollback
    helm rollback webapp 1
    
    # Uninstall
    helm uninstall webapp

**Environment-Specific Values**

.. code-block:: yaml

    # production-values.yaml
    replicaCount: 3
    
    image:
      tag: "v1.2.3"
    
    ingress:
      enabled: true
      host: myapp.company.com
      tls:
        enabled: true
    
    resources:
      limits:
        cpu: 1000m
        memory: 1Gi

============
Dependencies
============

**Chart Dependencies**

.. code-block:: yaml

    # Chart.yaml
    dependencies:
    - name: postgresql
      version: "11.6.12"
      repository: "https://charts.bitnami.com/bitnami"
      condition: postgresql.enabled
    - name: redis
      version: "16.13.2"
      repository: "https://charts.bitnami.com/bitnami"
      condition: redis.enabled

.. code-block:: bash

    # Update dependencies
    helm dependency update
    helm dependency build

==============
Testing Charts
==============

**Chart Testing**

.. code-block:: bash

    # Lint chart
    helm lint ./webapp
    
    # Dry run
    helm install webapp ./webapp --dry-run --debug
    
    # Template rendering
    helm template webapp ./webapp

**Test Templates**

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
        - name: wget
          image: busybox
          command: ['wget']
          args: ['{{ include "webapp.fullname" . }}:{{ .Values.service.port }}']

.. code-block:: bash

    # Run tests
    helm test webapp

==================
Essential Commands
==================

.. code-block:: bash

    # Repository management
    helm repo list
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm search repo postgres
    
    # Release management
    helm list --all-namespaces
    helm history webapp
    helm get values webapp
    helm get manifest webapp
    
    # Chart development
    helm create mychart
    helm package mychart/
    helm install mychart ./mychart-0.1.0.tgz

============
What's Next?
============

Next, we'll explore **GitOps with ArgoCD** for automated deployment workflows.

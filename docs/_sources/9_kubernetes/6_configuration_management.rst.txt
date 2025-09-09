############################
9.6 Configuration Management
############################

**Separating Configuration from Code**

Kubernetes provides ConfigMaps and Secrets to externalize application configuration and sensitive data.

==========
ConfigMaps
==========

**Non-Sensitive Configuration Data**

ConfigMaps store configuration data as key-value pairs or files.

**Creating ConfigMaps**

.. code-block:: yaml

    # Basic ConfigMap
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: app-config
    data:
      database_host: "postgres-service"
      database_port: "5432"
      log_level: "info"
      app.properties: |
        server.port=8080
        spring.datasource.url=jdbc:postgresql://postgres-service:5432/mydb
        logging.level.root=INFO

**Using ConfigMaps**

.. code-block:: yaml

    # Environment variables from ConfigMap
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: webapp
    spec:
      template:
        spec:
          containers:
          - name: app
            image: webapp:latest
            envFrom:
            - configMapRef:
                name: app-config
            # Or specific keys
            env:
            - name: DB_HOST
              valueFrom:
                configMapKeyRef:
                  name: app-config
                  key: database_host

**ConfigMap as Volume**

.. code-block:: yaml

    # Mount as files
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

=======
Secrets
=======

**Sensitive Data Management**

Secrets store sensitive information like passwords, tokens, and keys.

**Creating Secrets**

.. code-block:: yaml

    # Basic Secret
    apiVersion: v1
    kind: Secret
    metadata:
      name: db-secret
    type: Opaque
    data:
      username: cG9zdGdyZXM=  # base64 encoded 'postgres'
      password: c2VjcmV0MTIz    # base64 encoded 'secret123'

.. code-block:: bash

    # Create secret from command line
    kubectl create secret generic db-secret \
      --from-literal=username=postgres \
      --from-literal=password=secret123

**Using Secrets**

.. code-block:: yaml

    # Environment variables from Secret
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: webapp
    spec:
      template:
        spec:
          containers:
          - name: app
            image: webapp:latest
            env:
            - name: DB_USERNAME
              valueFrom:
                secretKeyRef:
                  name: db-secret
                  key: username
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: db-secret
                  key: password

**Secret as Volume**

.. code-block:: yaml

    # Mount secret as files
    apiVersion: v1
    kind: Pod
    metadata:
      name: app
    spec:
      containers:
      - name: app
        image: app:latest
        volumeMounts:
        - name: secret-volume
          mountPath: /etc/secrets
          readOnly: true
      volumes:
      - name: secret-volume
        secret:
          secretName: db-secret

===========
TLS Secrets
===========

**SSL/TLS Certificates**

.. code-block:: yaml

    # TLS Secret for HTTPS
    apiVersion: v1
    kind: Secret
    metadata:
      name: tls-secret
    type: kubernetes.io/tls
    data:
      tls.crt: LS0tLS...  # base64 encoded certificate
      tls.key: LS0tLS...  # base64 encoded private key

.. code-block:: bash

    # Create TLS secret from files
    kubectl create secret tls tls-secret \
      --cert=path/to/tls.crt \
      --key=path/to/tls.key

================
External Secrets
================

**Integration with External Systems**

External Secrets Operator can sync secrets from external systems like AWS Secrets Manager, HashiCorp Vault, etc.

.. code-block:: yaml

    # External Secret
    apiVersion: external-secrets.io/v1beta1
    kind: ExternalSecret
    metadata:
      name: vault-secret
    spec:
      refreshInterval: 15s
      secretStoreRef:
        name: vault-backend
        kind: SecretStore
      target:
        name: myapp-secret
        creationPolicy: Owner
      data:
      - secretKey: password
        remoteRef:
          key: secret/myapp
          property: password

=========
Kustomize
=========

**Native Kubernetes Configuration Management**

Kustomize is a native Kubernetes configuration management tool that introduces a template-free way to customize application configuration files tailored to specific environments.

**Why Kustomize?**

- **No Templates**: Works with plain YAML files - no need to learn templating languages
- **Native Integration**: Built into kubectl (kubectl apply -k)
- **Inheritance**: Base configurations can be inherited and customized for different environments
- **Overlay Pattern**: Apply patches and modifications without changing original files
- **Composition**: Combine multiple resources and configurations easily

**Problems Kustomize Solves**

1. **Environment Configuration Drift**: Different environments need different configurations
2. **DRY Principle**: Avoid duplicating configuration across environments
3. **Template Complexity**: Eliminates need for complex templating systems
4. **Configuration Management**: Systematic way to manage configurations across environments

**Basic Structure**

.. code-block:: bash

    # Typical Kustomize project structure
    myapp/
    ├── base/
    │   ├── kustomization.yaml
    │   ├── deployment.yaml
    │   ├── service.yaml
    │   └── configmap.yaml
    └── overlays/
        ├── development/
        │   ├── kustomization.yaml
        │   └── patches/
        └── production/
            ├── kustomization.yaml
            ├── patches/
            └── secrets.yaml

**Base Configuration**

.. code-block:: yaml

    # base/kustomization.yaml
    apiVersion: kustomize.config.k8s.io/v1beta1
    kind: Kustomization
    
    resources:
    - deployment.yaml
    - service.yaml
    - configmap.yaml
    
    commonLabels:
      app: webapp
      version: v1

.. code-block:: yaml

    # base/deployment.yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: webapp
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: webapp
      template:
        metadata:
          labels:
            app: webapp
        spec:
          containers:
          - name: webapp
            image: webapp:latest
            ports:
            - containerPort: 8080
            resources:
              limits:
                cpu: 100m
                memory: 128Mi

.. code-block:: yaml

    # base/service.yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: webapp-service
    spec:
      selector:
        app: webapp
      ports:
      - port: 80
        targetPort: 8080

**Environment Overlays**

.. code-block:: yaml

    # overlays/development/kustomization.yaml
    apiVersion: kustomize.config.k8s.io/v1beta1
    kind: Kustomization
    
    bases:
    - ../../base
    
    namePrefix: dev-
    nameSuffix: -v1
    
    commonLabels:
      environment: development
    
    images:
    - name: webapp
      newTag: dev-latest
    
    replicas:
    - name: webapp
      count: 1
    
    patchesStrategicMerge:
    - patches/resources-patch.yaml

.. code-block:: yaml

    # overlays/development/patches/resources-patch.yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: webapp
    spec:
      template:
        spec:
          containers:
          - name: webapp
            resources:
              limits:
                cpu: 50m
                memory: 64Mi

**Production Overlay**

.. code-block:: yaml

    # overlays/production/kustomization.yaml
    apiVersion: kustomize.config.k8s.io/v1beta1
    kind: Kustomization
    
    bases:
    - ../../base
    
    namePrefix: prod-
    
    commonLabels:
      environment: production
    
    images:
    - name: webapp
      newTag: v1.2.3
    
    replicas:
    - name: webapp
      count: 3
    
    patchesStrategicMerge:
    - production-resources.yaml
    
    secretGenerator:
    - name: webapp-secrets
      literals:
      - database_password=prod-secret-password

.. code-block:: yaml

    # overlays/production/production-resources.yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: webapp
    spec:
      template:
        spec:
          containers:
          - name: webapp
            resources:
              limits:
                cpu: 1000m
                memory: 1Gi
              requests:
                cpu: 500m
                memory: 512Mi

**Advanced Features**

.. code-block:: yaml

    # JSON patches for precise modifications
    # overlays/staging/kustomization.yaml
    apiVersion: kustomize.config.k8s.io/v1beta1
    kind: Kustomization
    
    bases:
    - ../../base
    
    patchesJson6902:
    - target:
        group: apps
        version: v1
        kind: Deployment
        name: webapp
      path: add-sidecar.yaml

.. code-block:: yaml

    # overlays/staging/add-sidecar.yaml
    - op: add
      path: /spec/template/spec/containers/-
      value:
        name: logging-sidecar
        image: fluent/fluent-bit:1.8
        args:
        - /fluent-bit/bin/fluent-bit
        - --config=/fluent-bit/etc/fluent-bit.conf

**ConfigMap and Secret Generators**

.. code-block:: yaml

    # kustomization.yaml with generators
    apiVersion: kustomize.config.k8s.io/v1beta1
    kind: Kustomization
    
    configMapGenerator:
    - name: app-config
      literals:
      - database_host=postgres-service
      - log_level=info
      files:
      - application.properties
    
    secretGenerator:
    - name: app-secrets
      literals:
      - api_key=super-secret-key
      - database_password=secret123

**Using Kustomize**

.. code-block:: bash

    # Apply base configuration
    kubectl apply -k base/
    
    # Apply development overlay
    kubectl apply -k overlays/development/
    
    # Apply production overlay
    kubectl apply -k overlays/production/
    
    # Preview what will be applied
    kubectl kustomize overlays/production/
    
    # Build and save to file
    kubectl kustomize overlays/production/ > production-manifests.yaml

**Common Patterns**

.. code-block:: yaml

    # Multi-environment with shared components
    environments/
    ├── base/
    │   ├── kustomization.yaml
    │   ├── backend/
    │   ├── frontend/
    │   └── database/
    ├── dev/
    │   └── kustomization.yaml
    ├── staging/
    │   └── kustomization.yaml
    └── prod/
        └── kustomization.yaml

**Kustomize vs Helm**

+----------------+------------------+-------------------+
| Feature        | Kustomize        | Helm              |
+================+==================+===================+
| Learning Curve | Low              | Medium            |
+----------------+------------------+-------------------+
| Templates      | None (YAML)      | Go Templates      |
+----------------+------------------+-------------------+
| Packaging      | No               | Yes (Charts)      |
+----------------+------------------+-------------------+
| Lifecycle      | kubectl native   | Helm releases     |
+----------------+------------------+-------------------+
| Community      | Kubernetes       | Large ecosystem   |
+----------------+------------------+-------------------+

**Complete Example**

A comprehensive Kustomize example with base configuration and environment overlays can be found in the ``source_code/kubernetes/kustomize-example/`` directory, demonstrating:

- Base configuration with deployment, service, and configmap
- Development overlay with debug settings and reduced resources
- Production overlay with multiple replicas, secrets, and enhanced monitoring
- Best practices for environment-specific configuration management

===============================
External Secrets Operator (ESO)
===============================

**Integration with External Secret Management Systems**

External Secrets Operator synchronizes secrets from external systems like AWS Secrets Manager, HashiCorp Vault, Azure Key Vault, and Google Secret Manager into Kubernetes Secrets.

**Why Use External Secrets Operator?**

- **Centralized Secret Management**: Keep secrets in external systems
- **GitOps Friendly**: No secrets stored in Git repositories
- **Multiple Providers**: Support for various secret management systems
- **Automatic Rotation**: Sync secrets automatically when they change
- **Security**: Reduced blast radius for secret exposure

**Installation**

.. code-block:: bash

    # Install External Secrets Operator using Helm
    helm repo add external-secrets https://charts.external-secrets.io
    helm install external-secrets external-secrets/external-secrets -n external-secrets --create-namespace

**AWS Secrets Manager Integration**

.. code-block:: yaml

    # SecretStore for AWS Secrets Manager
    apiVersion: external-secrets.io/v1beta1
    kind: SecretStore
    metadata:
      name: aws-secrets-store
      namespace: default
    spec:
      provider:
        aws:
          service: SecretsManager
          region: us-west-2
          auth:
            secretRef:
              accessKeyIDSecretRef:
                name: aws-secret
                key: access-key-id
              secretAccessKeySecretRef:
                name: aws-secret
                key: secret-access-key

.. code-block:: yaml

    # ExternalSecret using AWS Secrets Manager
    apiVersion: external-secrets.io/v1beta1
    kind: ExternalSecret
    metadata:
      name: database-secret
      namespace: default
    spec:
      refreshInterval: 30s
      secretStoreRef:
        name: aws-secrets-store
        kind: SecretStore
      target:
        name: db-credentials
        creationPolicy: Owner
        template:
          type: Opaque
          data:
            username: "{{ .username }}"
            password: "{{ .password }}"
            connection_string: "postgresql://{{ .username }}:{{ .password }}@postgres:5432/mydb"
      data:
      - secretKey: username
        remoteRef:
          key: prod/database
          property: username
      - secretKey: password
        remoteRef:
          key: prod/database
          property: password

**HashiCorp Vault Integration**

.. code-block:: yaml

    # SecretStore for Vault
    apiVersion: external-secrets.io/v1beta1
    kind: SecretStore
    metadata:
      name: vault-backend
      namespace: default
    spec:
      provider:
        vault:
          server: "https://vault.example.com"
          path: "secret"
          version: "v2"
          auth:
            kubernetes:
              mountPath: "kubernetes"
              role: "external-secrets"
              serviceAccountRef:
                name: external-secrets-sa

.. code-block:: yaml

    # ExternalSecret for Vault
    apiVersion: external-secrets.io/v1beta1
    kind: ExternalSecret
    metadata:
      name: vault-secret
      namespace: default
    spec:
      refreshInterval: 15s
      secretStoreRef:
        name: vault-backend
        kind: SecretStore
      target:
        name: myapp-secret
        creationPolicy: Owner
      data:
      - secretKey: api_key
        remoteRef:
          key: secret/myapp
          property: api_key
      - secretKey: database_password
        remoteRef:
          key: secret/database
          property: password

**Google Secret Manager Integration**

.. code-block:: yaml

    # ClusterSecretStore for Google Secret Manager
    apiVersion: external-secrets.io/v1beta1
    kind: ClusterSecretStore
    metadata:
      name: gcp-secret-store
    spec:
      provider:
        gcpsm:
          projectId: "my-project"
          auth:
            workloadIdentity:
              clusterLocation: us-central1
              clusterName: my-cluster
              serviceAccountRef:
                name: external-secrets-sa

**Azure Key Vault Integration**

.. code-block:: yaml

    # SecretStore for Azure Key Vault
    apiVersion: external-secrets.io/v1beta1
    kind: SecretStore
    metadata:
      name: azure-keyvault-store
    spec:
      provider:
        azurekv:
          vaultUrl: "https://my-keyvault.vault.azure.net/"
          authType: ManagedIdentity
          identityId: "/subscriptions/.../resourcegroups/.../providers/Microsoft.ManagedIdentity/userAssignedIdentities/external-secrets"

**Monitoring External Secrets**

.. code-block:: bash

    # Check ExternalSecret status
    kubectl get externalsecrets
    kubectl describe externalsecret database-secret
    
    # Check created secrets
    kubectl get secrets
    kubectl describe secret db-credentials
    
    # Monitor operator logs
    kubectl logs -n external-secrets -l app.kubernetes.io/name=external-secrets

======================
Configuration Patterns
======================

**Environment-Specific Configuration**

.. code-block:: yaml

    # Development ConfigMap
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: app-config-dev
      namespace: development
    data:
      environment: "development"
      database_host: "postgres-dev"
      log_level: "debug"

.. code-block:: yaml

    # Production ConfigMap
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: app-config-prod
      namespace: production
    data:
      environment: "production"
      database_host: "postgres-prod"
      log_level: "warn"

==============
Best Practices
==============

**Security and Management**

1. **Never put secrets in ConfigMaps**
2. **Use RBAC to control access**
3. **Enable encryption at rest**
4. **Rotate secrets regularly**
5. **Use external secret management when possible**

.. code-block:: yaml

    # RBAC for ConfigMaps/Secrets
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
      name: config-reader
    rules:
    - apiGroups: [""]
      resources: ["configmaps"]
      verbs: ["get", "list"]
    - apiGroups: [""]
      resources: ["secrets"]
      verbs: ["get"]

==================
Essential Commands
==================

.. code-block:: bash

    # ConfigMaps
    kubectl get configmaps
    kubectl describe configmap app-config
    kubectl create configmap app-config --from-file=config.properties
    
    # Secrets
    kubectl get secrets
    kubectl describe secret db-secret
    kubectl create secret generic mysecret --from-literal=key1=value1
    
    # Viewing data (be careful with secrets!)
    kubectl get configmap app-config -o yaml
    kubectl get secret db-secret -o jsonpath='{.data.password}' | base64 -d
    
    # Kustomize
    kubectl apply -k base/                    # Apply base configuration
    kubectl apply -k overlays/development/    # Apply development overlay
    kubectl kustomize overlays/production/    # Preview production config
    kubectl delete -k overlays/staging/       # Delete staging resources
    
    # Build and validate
    kustomize build overlays/production/      # Using standalone kustomize
    kubectl kustomize . --enable-helm        # With Helm support

============
What's Next?
============

Next, we'll explore **Security and RBAC** to secure your Kubernetes cluster and applications.

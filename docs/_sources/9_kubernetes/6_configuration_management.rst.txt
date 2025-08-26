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

============
What's Next?
============

Next, we'll explore **Security and RBAC** to secure your Kubernetes cluster and applications.

######################
9.14 CI/CD Integration
######################

**Continuous Integration and Deployment with Kubernetes**

This chapter covers integrating Kubernetes with modern CI/CD pipelines, focusing on GitHub Actions and security best practices.

=============================
GitHub Actions for Kubernetes
=============================

**Why GitHub Actions with Kubernetes?**

- **Native integration** with GitHub repositories
- **Kubernetes-specific actions** available in marketplace
- **Matrix builds** for multi-environment deployments
- **Security scanning** integration
- **Cost-effective** for open source projects

**Basic Workflow Structure**

.. code-block:: yaml

    # .github/workflows/k8s-deploy.yml
    name: Deploy to Kubernetes
    
    on:
      push:
        branches: [main]
      pull_request:
        branches: [main]
    
    env:
      REGISTRY: ghcr.io
      IMAGE_NAME: ${{ github.repository }}
    
    jobs:
      build-and-test:
        runs-on: ubuntu-latest
        steps:
        - name: Checkout code
          uses: actions/checkout@v4
        
        - name: Set up Docker Buildx
          uses: docker/setup-buildx-action@v3
        
        - name: Log in to Container Registry
          uses: docker/login-action@v3
          with:
            registry: ${{ env.REGISTRY }}
            username: ${{ github.actor }}
            password: ${{ secrets.GITHUB_TOKEN }}
        
        - name: Build and push Docker image
          uses: docker/build-push-action@v5
          with:
            context: .
            push: true
            tags: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
            cache-from: type=gha
            cache-to: type=gha,mode=max

**Multi-Environment Deployment**

.. code-block:: yaml

    # .github/workflows/multi-env-deploy.yml
    name: Multi-Environment Deploy
    
    on:
      push:
        branches: [main, develop]
    
    jobs:
      deploy:
        runs-on: ubuntu-latest
        strategy:
          matrix:
            environment: [development, staging, production]
            include:
            - environment: development
              branch: develop
              cluster: dev-cluster
            - environment: staging
              branch: main
              cluster: staging-cluster
            - environment: production
              branch: main
              cluster: prod-cluster
              manual_approval: true
        
        environment: 
          name: ${{ matrix.environment }}
          url: https://${{ matrix.environment }}.example.com
        
        steps:
        - name: Checkout code
          uses: actions/checkout@v4
        
        - name: Configure kubectl
          uses: azure/setup-kubectl@v3
          with:
            version: 'v1.28.0'
        
        - name: Set up Kustomize
          run: |
            curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
            sudo mv kustomize /usr/local/bin/
        
        - name: Deploy to Kubernetes
          run: |
            echo "${{ secrets.KUBECONFIG }}" | base64 -d > kubeconfig
            export KUBECONFIG=kubeconfig
            
            # Update image tag in kustomization
            cd k8s/overlays/${{ matrix.environment }}
            kustomize edit set image app=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
            
            # Apply with kubectl
            kubectl apply -k .
            kubectl rollout status deployment/app -n ${{ matrix.environment }}

=======================
Image Scanning Pipeline
=======================

**Trivy Security Scanning**

.. code-block:: yaml

    # .github/workflows/security-scan.yml
    name: Security Scan
    
    on:
      push:
        branches: [main]
      pull_request:
        branches: [main]
    
    jobs:
      security-scan:
        runs-on: ubuntu-latest
        steps:
        - name: Checkout code
          uses: actions/checkout@v4
        
        - name: Build Docker image
          run: docker build -t test-image .
        
        - name: Run Trivy vulnerability scanner
          uses: aquasecurity/trivy-action@master
          with:
            image-ref: 'test-image'
            format: 'sarif'
            output: 'trivy-results.sarif'
        
        - name: Upload Trivy scan results
          uses: github/codeql-action/upload-sarif@v2
          with:
            sarif_file: 'trivy-results.sarif'
        
        - name: Fail on critical vulnerabilities
          uses: aquasecurity/trivy-action@master
          with:
            image-ref: 'test-image'
            format: 'table'
            exit-code: '1'
            severity: 'CRITICAL,HIGH'

**Advanced Security Pipeline**

.. code-block:: yaml

    # .github/workflows/advanced-security.yml
    name: Advanced Security Pipeline
    
    on:
      push:
        branches: [main]
    
    jobs:
      security-pipeline:
        runs-on: ubuntu-latest
        steps:
        - name: Checkout code
          uses: actions/checkout@v4
        
        # Dockerfile security scanning
        - name: Scan Dockerfile
          uses: hadolint/hadolint-action@v3.1.0
          with:
            dockerfile: Dockerfile
            format: sarif
            output-file: hadolint-results.sarif
        
        # Build image
        - name: Build image
          run: docker build -t security-test .
        
        # Container image scanning
        - name: Container image scan
          uses: anchore/scan-action@v3
          with:
            image: security-test
            fail-build: true
            severity-cutoff: high
        
        # Kubernetes manifest scanning
        - name: Scan Kubernetes manifests
          uses: stackrox/kube-linter-action@v1
          with:
            directory: k8s/
            format: sarif
            output-file: kube-linter-results.sarif
        
        # SBOM generation
        - name: Generate SBOM
          uses: anchore/sbom-action@v0
          with:
            image: security-test
            format: spdx-json
            output-file: sbom.spdx.json
        
        # Sign container image
        - name: Install Cosign
          uses: sigstore/cosign-installer@v3
        
        - name: Sign container image
          run: |
            cosign sign --yes ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
          env:
            COSIGN_EXPERIMENTAL: 1

======================================
GitOps Integration with GitHub Actions
======================================

**ArgoCD Sync with GitHub Actions**

.. code-block:: yaml

    # .github/workflows/gitops-sync.yml
    name: GitOps Sync
    
    on:
      push:
        branches: [main]
    
    jobs:
      update-manifests:
        runs-on: ubuntu-latest
        steps:
        - name: Checkout config repo
          uses: actions/checkout@v4
          with:
            repository: company/k8s-config
            token: ${{ secrets.GITOPS_TOKEN }}
            path: config-repo
        
        - name: Update image tags
          run: |
            cd config-repo
            
            # Update image tag using yq
            yq eval '.spec.template.spec.containers[0].image = "${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}"' \
              -i environments/production/app-deployment.yaml
            
            # Commit changes
            git config user.name "GitHub Actions"
            git config user.email "actions@github.com"
            git add .
            git commit -m "Update image to ${{ github.sha }}"
            git push
        
        - name: Trigger ArgoCD sync
          run: |
            curl -X POST \
              -H "Authorization: Bearer ${{ secrets.ARGOCD_TOKEN }}" \
              -H "Content-Type: application/json" \
              "${{ secrets.ARGOCD_URL }}/api/v1/applications/app-production/sync" \
              -d '{"revision": "HEAD"}'

=======================
Pipeline Best Practices
=======================

**Security Best Practices**

.. code-block:: yaml

    # Security-focused pipeline structure
    jobs:
      security-checks:
        runs-on: ubuntu-latest
        steps:
        # 1. Static code analysis
        - name: CodeQL Analysis
          uses: github/codeql-action/analyze@v2
        
        # 2. Dependency scanning
        - name: Dependency Review
          uses: actions/dependency-review-action@v3
        
        # 3. Secret scanning
        - name: TruffleHog Secret Scan
          uses: trufflesecurity/trufflehog@main
          with:
            path: ./
            base: main
            head: HEAD
        
        # 4. Infrastructure as Code scanning
        - name: Checkov IaC scan
          uses: bridgecrewio/checkov-action@master
          with:
            directory: k8s/
            framework: kubernetes

**Performance and Optimization**

.. code-block:: yaml

    # Optimized pipeline with caching
    jobs:
      build:
        runs-on: ubuntu-latest
        steps:
        - name: Cache Docker layers
          uses: actions/cache@v3
          with:
            path: /tmp/.buildx-cache
            key: ${{ runner.os }}-buildx-${{ github.sha }}
            restore-keys: |
              ${{ runner.os }}-buildx-
        
        - name: Build with cache
          uses: docker/build-push-action@v5
          with:
            context: .
            cache-from: type=local,src=/tmp/.buildx-cache
            cache-to: type=local,dest=/tmp/.buildx-cache-new,mode=max
        
        - name: Move cache
          run: |
            rm -rf /tmp/.buildx-cache
            mv /tmp/.buildx-cache-new /tmp/.buildx-cache

==================
Essential Commands
==================

.. code-block:: bash

    # GitHub CLI for workflow management
    gh workflow list
    gh workflow run deploy.yml
    gh run list --workflow=deploy.yml
    gh run watch
    
    # ArgoCD CLI integration
    argocd login argocd.example.com
    argocd app sync myapp
    argocd app wait myapp
    
    # Image signing verification
    cosign verify $IMAGE_NAME
    cosign verify-attestation $IMAGE_NAME
    
    # Security scanning locally
    trivy image myapp:latest
    grype myapp:latest
    syft myapp:latest

============
What's Next?
============

Next, we'll explore **Service Mesh** for advanced traffic management and security in microservices architectures.

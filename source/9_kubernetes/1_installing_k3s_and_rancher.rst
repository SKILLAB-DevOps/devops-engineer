##############################
9.1 Installing k3s and Rancher
##############################

**Complete Guide for Rocky Linux 10**

This section provides a comprehensive step-by-step manual for installing k3s (lightweight Kubernetes) and Rancher (Kubernetes management platform) on Rocky Linux 10.

============
What is k3s?
============

k3s is a lightweight Kubernetes distribution designed for:

- **Edge computing** and IoT devices
- **Development environments** and CI/CD
- **Resource-constrained environments**
- **Easy installation** with minimal dependencies

=============
Prerequisites
=============

**System Requirements**

- Rocky Linux 10 server (physical or virtual)
- Minimum 4GB RAM (8GB recommended)
- Minimum 2 CPU cores
- 20GB free disk space
- Root or sudo access
- Internet connectivity

**Network Requirements**

- Ports 6443 (Kubernetes API)
- Ports 80/443 (Rancher UI)
- Port 10250 (kubelet)

====================
Step 1: System Setup
====================

**1.1 Update the System**

.. code-block:: bash

    # Update all packages
    sudo dnf update -y
    
    # Reboot to ensure kernel updates take effect
    sudo reboot

**1.2 Configure Firewall**

.. code-block:: bash

    # Check firewall status
    sudo systemctl status firewalld
    
    # If firewall is active, open required ports
    sudo firewall-cmd --permanent --add-port=6443/tcp
    sudo firewall-cmd --permanent --add-port=443/tcp
    sudo firewall-cmd --permanent --add-port=80/tcp
    sudo firewall-cmd --permanent --add-port=10250/tcp
    sudo firewall-cmd --reload
    
    # Verify open ports
    sudo firewall-cmd --list-ports

**1.3 Disable SELinux (Optional)**

.. code-block:: bash

    # Check SELinux status
    sestatus
    
    # Temporarily disable (for current session)
    sudo setenforce 0
    
    # Permanently disable (edit config file)
    sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

**1.4 Install Required Packages**

.. code-block:: bash

    # Install essential tools
    sudo dnf install -y curl wget git vim

**1.5 Configure System Settings**

.. code-block:: bash

    # Enable IP forwarding
    echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
    echo 'net.bridge.bridge-nf-call-iptables = 1' | sudo tee -a /etc/sysctl.conf
    
    # Apply changes
    sudo sysctl -p

===================
Step 2: Install k3s
===================

**2.1 Download and Install k3s**

.. code-block:: bash

    # Download and install k3s with default settings
    curl -sfL https://get.k3s.io | sh -

**Expected Output:**

.. code-block:: text

    [INFO]  Finding release for channel stable
    [INFO]  Using v1.28.2+k3s1 as release
    [INFO]  Downloading hash https://github.com/k3s-io/k3s/releases/download/v1.28.2+k3s1/sha256sum-amd64.txt
    [INFO]  Downloading binary https://github.com/k3s-io/k3s/releases/download/v1.28.2+k3s1/k3s
    [INFO]  Verifying binary download
    [INFO]  Installing k3s to /usr/local/bin/k3s
    [INFO]  Skipping installation of SELinux RPM
    [INFO]  Creating /usr/local/bin/kubectl symlink to k3s
    [INFO]  Creating /usr/local/bin/crictl symlink to k3s
    [INFO]  Creating /usr/local/bin/ctr symlink to k3s
    [INFO]  Creating killall script /usr/local/bin/k3s-killall.sh
    [INFO]  Creating uninstall script /usr/local/bin/k3s-uninstall.sh
    [INFO]  env: Creating environment file /etc/systemd/system/k3s.service.env
    [INFO]  systemd: Creating service file /etc/systemd/system/k3s.service
    [INFO]  systemd: Enabling k3s unit
    [INFO]  systemd: Starting k3s

**2.2 Verify k3s Installation**

.. code-block:: bash

    # Check k3s service status
    sudo systemctl status k3s
    
    # Check if k3s is running
    sudo systemctl is-active k3s
    
    # View k3s logs
    sudo journalctl -u k3s -f

**2.3 Configure kubectl Access**

.. code-block:: bash

    # Create .kube directory for current user
    mkdir -p ~/.kube
    
    # Copy k3s kubeconfig to standard location
    sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
    
    # Change ownership to current user
    sudo chown $(id -u):$(id -g) ~/.kube/config
    
    # Set proper permissions
    chmod 600 ~/.kube/config
    
    # Set KUBECONFIG environment variable
    echo 'export KUBECONFIG=~/.kube/config' >> ~/.bashrc
    source ~/.bashrc

**2.4 Test kubectl**

.. code-block:: bash

    # Check cluster info
    kubectl cluster-info
    
    # List nodes
    kubectl get nodes
    
    # List all pods in all namespaces
    kubectl get pods -A
    
    # Check node details
    kubectl describe node $(hostname)

**Expected kubectl Output:**

.. code-block:: text

    NAME           STATUS   ROLES                  AGE   VERSION
    rocky-server   Ready    control-plane,master   2m    v1.28.2+k3s1
    
    NAMESPACE     NAME                                      READY   STATUS      RESTARTS   AGE
    kube-system   local-path-provisioner-6c86858495-xyz    1/1     Running     0          2m
    kube-system   coredns-96cc4f57d-abc                     1/1     Running     0          2m
    kube-system   metrics-server-67c658944b-def             1/1     Running     0          2m
    kube-system   helm-install-traefik-crd-ghi              0/1     Completed   0          2m
    kube-system   helm-install-traefik-jkl                  0/1     Completed   0          2m
    kube-system   traefik-7d5f6474df-mno                    1/1     Running     0          2m

====================
Step 3: Install Helm
====================

**3.1 Download and Install Helm**

.. code-block:: bash

    # Download Helm installation script
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    
    # Make script executable
    chmod 700 get_helm.sh
    
    # Run installation script
    ./get_helm.sh
    
    # Remove installation script
    rm get_helm.sh

**3.2 Verify Helm Installation**

.. code-block:: bash

    # Check Helm version
    helm version
    
    # Add stable repository
    helm repo add stable https://charts.helm.sh/stable
    
    # Update repositories
    helm repo update
    
    # List repositories
    helm repo list

**Expected Helm Output:**

.. code-block:: text

    version.BuildInfo{Version:"v3.12.3", GitCommit:"3a31588ad33fe3b89af5a2a54ee1d25bfe6eaa5e", GitTreeState:"clean", GoVersion:"go1.20.7"}

=======================
Step 4: Install Rancher
=======================

**4.1 Add Rancher Helm Repository**

.. code-block:: bash

    # Add Rancher stable repository
    helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
    
    # Update Helm repositories
    helm repo update
    
    # Verify Rancher repository
    helm search repo rancher

**4.2 Create Rancher Namespace**

.. code-block:: bash

    # Create cattle-system namespace for Rancher
    kubectl create namespace cattle-system
    
    # Verify namespace creation
    kubectl get namespaces

**4.3 Install cert-manager (Required for SSL)**

.. code-block:: bash

    # Add cert-manager repository
    helm repo add jetstack https://charts.jetstack.io
    
    # Update repositories
    helm repo update
    
    # Install cert-manager
    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.crds.yaml
    
    # Create cert-manager namespace
    kubectl create namespace cert-manager
    
    # Install cert-manager using Helm
    helm install cert-manager jetstack/cert-manager \
      --namespace cert-manager \
      --version v1.13.0

**4.4 Verify cert-manager Installation**

.. code-block:: bash

    # Wait for cert-manager pods to be ready
    kubectl get pods --namespace cert-manager
    
    # Check cert-manager status
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=cert-manager --namespace cert-manager --timeout=60s

**4.5 Install Rancher**

.. code-block:: bash

    # Install Rancher with hostname (replace with your domain/IP)
    helm install rancher rancher-stable/rancher \
      --namespace cattle-system \
      --set hostname=rancher.local \
      --set bootstrapPassword=admin123 \
      --set ingress.tls.source=rancher \
      --set replicas=1

**For Production with Custom Domain:**

.. code-block:: bash

    # Replace rancher.yourdomain.com with your actual domain
    helm install rancher rancher-stable/rancher \
      --namespace cattle-system \
      --set hostname=rancher.yourdomain.com \
      --set bootstrapPassword=SecurePassword123! \
      --set ingress.tls.source=letsEncrypt \
      --set letsEncrypt.email=your-email@domain.com \
      --set letsEncrypt.environment=production \
      --set replicas=3

**4.6 Verify Rancher Installation**

.. code-block:: bash

    # Watch Rancher deployment
    kubectl -n cattle-system rollout status deploy/rancher
    
    # Check Rancher pods
    kubectl -n cattle-system get pods
    
    # Check services
    kubectl -n cattle-system get svc
    
    # Get Rancher URL
    echo "Rancher URL: https://$(kubectl -n cattle-system get ingress rancher -o jsonpath='{.spec.rules[0].host}')"

=========================
Step 5: Access Rancher UI
=========================

**5.1 Wait for Rancher to be Ready**

.. code-block:: bash

    # Monitor Rancher deployment progress
    kubectl -n cattle-system get pods -w
    
    # Wait for all pods to be running (press Ctrl+C to exit watch)
    # You should see output similar to:
    # rancher-xxx-yyy   1/1     Running   0          2m
    # rancher-webhook-xxx-yyy   1/1     Running   0          1m

**5.2 Access Methods**

**Method 1: Using Local Domain (Development)**

.. code-block:: bash

    # Add entry to /etc/hosts file
    echo "127.0.0.1 rancher.local" | sudo tee -a /etc/hosts
    
    # Access via browser: https://rancher.local

**Method 2: Using Server IP**

.. code-block:: bash

    # Get server IP
    ip addr show | grep "inet " | grep -v 127.0.0.1
    
    # Access via browser: https://YOUR_SERVER_IP
    # Accept self-signed certificate warning

**Method 3: Port Forwarding (Testing)**

.. code-block:: bash

    # Forward local port to Rancher service
    kubectl -n cattle-system port-forward svc/rancher 8443:443
    
    # Access via browser: https://localhost:8443

**5.3 Initial Rancher Setup**

1. **Open Browser**: Navigate to your Rancher URL
2. **Accept Certificate**: Accept the self-signed certificate warning
3. **Bootstrap Password**: Enter the password you set during installation (default: admin123)
4. **Set New Password**: Create a new secure password
5. **Server URL**: Confirm the server URL for Rancher

=======================
Step 6: Troubleshooting
=======================

**6.1 Common Issues and Solutions**

**Issue: k3s Service Not Starting**

.. code-block:: bash

    # Check service status
    sudo systemctl status k3s
    
    # View detailed logs
    sudo journalctl -u k3s -n 50
    
    # Restart k3s service
    sudo systemctl restart k3s

**Issue: kubectl Command Not Found**

.. code-block:: bash

    # Check if kubectl symlink exists
    ls -la /usr/local/bin/kubectl
    
    # If missing, recreate symlink
    sudo ln -s /usr/local/bin/k3s /usr/local/bin/kubectl
    
    # Add to PATH
    echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
    source ~/.bashrc

**Issue: Rancher Pods Not Starting**

.. code-block:: bash

    # Check pod status and events
    kubectl -n cattle-system describe pods
    
    # Check cert-manager pods
    kubectl -n cert-manager get pods
    
    # Check for certificate issues
    kubectl -n cattle-system get certificates

**Issue: Cannot Access Rancher UI**

.. code-block:: bash

    # Check ingress configuration
    kubectl -n cattle-system get ingress
    
    # Check Traefik (k3s default ingress controller)
    kubectl -n kube-system get pods | grep traefik
    
    # Check service endpoints
    kubectl -n cattle-system get endpoints

**6.2 Useful Debug Commands**

.. code-block:: bash

    # Check cluster health
    kubectl get componentstatuses
    
    # Check node resources
    kubectl top nodes
    
    # Check pod resources
    kubectl top pods -A
    
    # Check events
    kubectl get events -A --sort-by='.lastTimestamp'
    
    # Check k3s configuration
    sudo cat /etc/rancher/k3s/k3s.yaml

==================
Step 7: Next Steps
==================

**7.1 Security Hardening**

.. code-block:: bash

    # Enable RBAC (already enabled in k3s by default)
    kubectl get clusterrolebindings
    
    # Create network policies
    kubectl get networkpolicies -A
    
    # Configure pod security standards
    kubectl get podsecuritypolicies

**7.2 Backup Configuration**

.. code-block:: bash

    # Create backup directory
    mkdir -p ~/k3s-backup
    
    # Backup k3s configuration
    sudo cp /etc/rancher/k3s/k3s.yaml ~/k3s-backup/
    
    # Backup Rancher configuration
    kubectl -n cattle-system get all -o yaml > ~/k3s-backup/rancher-backup.yaml

**7.3 Adding Worker Nodes**

.. code-block:: bash

    # Get node token from master
    sudo cat /var/lib/rancher/k3s/server/node-token
    
    # On worker node, run:
    # curl -sfL https://get.k3s.io | K3S_URL=https://MASTER_IP:6443 K3S_TOKEN=NODE_TOKEN sh -

===============
Useful Commands
===============

.. code-block:: bash

    # k3s Management
    sudo systemctl start k3s
    sudo systemctl stop k3s
    sudo systemctl restart k3s
    sudo systemctl status k3s
    
    # Uninstall k3s (if needed)
    sudo /usr/local/bin/k3s-uninstall.sh
    
    # Rancher Management
    helm list -n cattle-system
    helm status rancher -n cattle-system
    helm upgrade rancher rancher-stable/rancher -n cattle-system
    
    # Reset Rancher admin password
    kubectl -n cattle-system exec $(kubectl -n cattle-system get pods -l app=rancher | grep '1/1' | head -1 | awk '{ print $1 }') -- reset-password
    
    # View Rancher logs
    kubectl -n cattle-system logs -f deployment/rancher

============
What's Next?
============

Now that you have k3s and Rancher installed, you can:

1. **Import existing clusters** into Rancher
2. **Deploy applications** using Rancher's catalog
3. **Set up monitoring** and logging
4. **Configure backup strategies**
5. **Implement GitOps workflows**

Next, we'll explore **Kubernetes Core Concepts** to understand the fundamental building blocks of Kubernetes.
#####################
2.3 Managing Software
#####################

==========================
Package Management Systems
==========================

**Debian/Ubuntu (APT):**

.. code-block:: bash

    # Update package list
    sudo apt update
    
    # Install packages
    sudo apt install package_name
    sudo apt install -y package_name    # Skip confirmation
    
    # Search packages
    apt search keyword
    apt list --installed
    
    # Remove packages
    sudo apt remove package_name
    sudo apt purge package_name         # Remove config files too
    sudo apt autoremove                 # Remove unused dependencies

**RHEL/CentOS/Fedora (DNF/YUM):**

.. code-block:: bash

    # Install packages
    sudo dnf install package_name
    sudo yum install package_name       # Older systems
    
    # Search and info
    dnf search keyword
    dnf info package_name
    
    # Remove packages
    sudo dnf remove package_name
    sudo dnf autoremove

**Universal and Modern Packages:**

.. code-block:: bash

    # Snap packages (Ubuntu/Debian)
    sudo snap install package_name              # Install snap package
    sudo snap install --classic code            # Install with classic confinement
    snap list                                   # List installed snaps
    snap info package_name                      # Show package info
    sudo snap remove package_name              # Remove snap package
    sudo snap refresh                          # Update all snaps
    
    # Flatpak packages (cross-distribution)
    flatpak install flathub package_name       # Install from Flathub
    flatpak list                               # List installed packages
    flatpak run package_name                   # Run flatpak application
    flatpak uninstall package_name            # Remove package
    flatpak update                             # Update all packages
    
    # AppImage (portable applications)
    chmod +x Application.AppImage               # Make executable
    ./Application.AppImage                      # Run directly
    
    # Container-based package managers
    docker run --rm -it ubuntu:20.04 bash     # Run temporary container
    podman install package_name                # Podman package management

**Modern Package Managers:**

.. code-block:: bash

    # Homebrew (cross-platform)
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew install package_name
    brew update && brew upgrade
    
    # Nix package manager
    curl -L https://nixos.org/nix/install | sh
    nix-env -iA nixpkgs.package_name

=========================
DevOps Package Management
=========================

**Essential Development Tools:**

.. code-block:: bash

    # Ubuntu/Debian development essentials
    sudo apt update
    sudo apt install -y \
        curl wget git vim \
        build-essential \
        tree htop tmux

    # RHEL/CentOS development essentials  
    sudo dnf install -y \
        curl wget git vim \
        tree htop tmux

**Container-Based Development:**

.. code-block:: bash

    # Use containers for isolated environments
    # Python development container
    docker run -it --rm -v $(pwd):/workspace python:3.11 bash


=============================
Package Repository Management  
=============================

**Adding Third-Party Repositories:**

.. code-block:: bash

    # Docker repository (Ubuntu/Debian)
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Node.js repository (Ubuntu/Debian)
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    
    # Kubernetes repository
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

**Essential Development Packages:**

.. code-block:: bash

    # Ubuntu/Debian development stack
    sudo apt update
    sudo apt install python3 python3-pip python3-venv python3-dev
    sudo apt install nodejs npm
    sudo apt install docker.io docker-compose
    sudo apt install git curl wget vim tree htop

    # RHEL/CentOS development stack  
    sudo dnf install python3 python3-pip python3-devel
    sudo dnf install nodejs npm
    sudo dnf install docker docker-compose
    sudo dnf install git curl wget vim tree htop
       
=================
Development Tools
=================

**Essential DevOps Tools:**

.. code-block:: bash

    # Build tools and compilers (Ubuntu/Debian)
    sudo apt update
    sudo apt install build-essential git curl wget vim htop tree jq unzip
    
    # Build tools (RHEL/CentOS/Fedora)
    sudo dnf groupinstall "Development Tools"
    
    # Container and orchestration tools
    # Docker (Ubuntu/Debian)
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update && sudo apt install docker-ce docker-ce-cli containerd.io
    
    # Kubernetes tools
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    
    # Helm
    curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    sudo apt update && sudo apt install helm

**Cloud CLI Tools:**

.. code-block:: bash

    # AWS CLI
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip && sudo ./aws/install
    
    # Azure CLI
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    
    # Google Cloud CLI
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    sudo apt update && sudo apt install google-cloud-cli

**Infrastructure as Code Tools:**

.. code-block:: bash

    # Terraform
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install terraform
    
    # Ansible
    sudo apt install ansible
    # or via pip for latest version
    pip3 install ansible
    
    # Pulumi
    curl -fsSL https://get.pulumi.com | sh

**Monitoring and Observability:**

.. code-block:: bash

    # Prometheus (using Docker)
    docker run -d --name=prometheus -p 9090:9090 prom/prometheus
    
    # Grafana
    sudo apt install -y software-properties-common
    sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
    wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
    sudo apt update && sudo apt install grafana
    
    # Modern CLI tools
    cargo install bat exa fd-find ripgrep du-dust  # Rust-based tools
    pip3 install tldr cheat                        # Documentation tools

**Security Best Practices:**

.. code-block:: bash

    # Always update before installing
    sudo apt update && sudo apt upgrade -y
    
    # Verify GPG signatures
    wget -qO - https://packages.grafana.com/gpg.key | gpg --show-keys
    
    # Use specific versions for production
    sudo apt install docker-ce=5:20.10.21~3-0~ubuntu-jammy
    
    # Regular security updates
    sudo apt install unattended-upgrades
    sudo dpkg-reconfigure unattended-upgrades
    
    # Remove unused packages
    sudo apt autoremove && sudo apt autoclean

**Package Management Best Practices:**

1. **Version Control**: Pin important package versions in production
2. **Repository Management**: Use official repositories when possible
3. **Security Updates**: Enable automatic security updates
4. **Minimal Installation**: Only install required packages
5. **Regular Audits**: Review and remove unused packages
6. **Backup Configuration**: Save package lists for disaster recovery

.. code-block:: bash

    # Save package list for backup
    dpkg --get-selections > installed-packages.txt
    
    # Restore packages on new system
    sudo dpkg --set-selections < installed-packages.txt
    sudo apt-get dselect-upgrade

.. warning::

    **Security Alert**: Only install software from trusted sources. Always verify checksums and GPG signatures for security-critical tools. Avoid curl-pipe-bash installations in production environments.
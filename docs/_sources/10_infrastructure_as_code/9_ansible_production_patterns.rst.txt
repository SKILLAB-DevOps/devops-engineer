################################
10.9 Ansible Production Patterns
################################

===================
Learning Objectives
===================

By the end of this chapter, you will be able to:

• **Design** enterprise-scale Ansible architectures for production environments
• **Integrate** Ansible seamlessly with Terraform workflows for complete IaC solutions
• **Implement** robust CI/CD pipelines using Ansible for automated deployments
• **Apply** security best practices and compliance frameworks in Ansible automation
• **Monitor** and observe Ansible automation with logging, metrics, and alerting
• **Scale** Ansible operations across large, distributed infrastructures
• **Troubleshoot** complex production issues and implement reliable error recovery
• **Establish** governance and organizational patterns for team collaboration
• **Optimize** Ansible workflows for performance, reliability, and maintainability

**Prerequisites:** Mastery of Ansible core concepts (Chapters 10.6-10.8) and understanding of Terraform from previous chapters. Experience with production systems recommended.

**Enterprise Focus:** This chapter focuses on real-world, production-ready patterns used in enterprise environments with hundreds or thousands of managed nodes.

===============================
Enterprise Ansible Architecture
===============================

Production Ansible deployments require careful architectural planning to ensure scalability, reliability, and maintainability across large organizations.

**Centralized Control Architecture:**

.. code-block:: text

    Enterprise Ansible Architecture:
    
    ┌─────────────────────────────────────────────────────┐
    │                 Control Plane                       │
    │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │
    │  │   Ansible   │  │   Ansible   │  │   Ansible   │  │
    │  │  Controller │  │   AWX/Tower │  │   Semaphore │  │
    │  │  (Primary)  │  │  (Secondary)│  │  (Backup)   │  │
    │  └─────────────┘  └─────────────┘  └─────────────┘  │
    │           │                │                │       │
    │  ┌──────────────────────────────────────────────────┤
    │  │              Shared Storage                      │
    │  │  • Playbooks & Roles Repository                  │
    │  │  • Inventory Management                          │
    │  │  • Secrets & Vault Files                         │
    │  │  • Execution Logs & Artifacts                    │
    │  └──────────────────────────────────────────────────│
    └─────────────────────────────────────────────────────┘
                              │
    ┌─────────────────────────────────────────────────────┐
    │                 Network Layer                       │
    │                                                     │
    │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │
    │  │    DMZ      │  │  Private    │  │   Cloud     │  │
    │  │   Bastion   │  │  Network    │  │  Provider   │  │
    │  │   Hosts     │  │   Subnets   │  │   APIs      │  │
    │  └─────────────┘  └─────────────┘  └─────────────┘  │
    └─────────────────────────────────────────────────────┘
                              │
    ┌─────────────────────────────────────────────────────┐
    │                 Managed Nodes                       │
    │                                                     │
    │  Production    │    Staging      │   Development    │
    │  ┌─────────┐   │   ┌─────────┐   │   ┌─────────┐    │
    │  │ Web     │   │   │ Web     │   │   │ Web     │    │
    │  │ Servers │   │   │ Servers │   │   │ Servers │    │
    │  ├─────────┤   │   ├─────────┤   │   ├─────────┤    │
    │  │ DB      │   │   │ DB      │   │   │ DB      │    │
    │  │ Servers │   │   │ Servers │   │   │ Servers │    │
    │  ├─────────┤   │   ├─────────┤   │   ├─────────┤    │
    │  │ Cache   │   │   │ Cache   │   │   │ Cache   │    │
    │  │ Servers │   │   │ Servers │   │   │ Servers │    │
    │  └─────────┘   │   └─────────┘   │   └─────────┘    │
    └─────────────────────────────────────────────────────┘

**Directory Structure for Enterprise:**

.. code-block:: text

    ansible-infrastructure/
    ├── ansible.cfg                 # Global Ansible configuration
    ├── requirements.yml            # External collections and roles
    ├── vault-password-files/       # Vault password management
    │   ├── production
    │   ├── staging
    │   └── development
    ├── inventories/               # Environment-specific inventories
    │   ├── production/
    │   │   ├── hosts.yml          # Static inventory
    │   │   ├── gcp.yml           # Dynamic GCP inventory
    │   │   ├── group_vars/       # Group variables
    │   │   └── host_vars/        # Host-specific variables
    │   ├── staging/
    │   └── development/
    ├── playbooks/                # Main orchestration playbooks
    │   ├── site.yml              # Main site playbook
    │   ├── deploy.yml            # Application deployment
    │   ├── maintenance.yml       # Maintenance procedures
    │   └── disaster-recovery.yml # DR procedures
    ├── roles/                    # Custom roles
    │   ├── common/               # Base system configuration
    │   ├── security/             # Security hardening
    │   ├── monitoring/           # Observability setup
    │   ├── database/             # Database management
    │   ├── webserver/            # Web server configuration
    │   └── application/          # Application deployment
    ├── collections/              # Local collections
    ├── filter_plugins/           # Custom filters
    ├── callback_plugins/         # Custom callbacks
    ├── library/                  # Custom modules
    ├── scripts/                  # Helper scripts
    ├── tests/                    # Automated testing
    └── docs/                     # Documentation

**Environment-Specific Configuration:**

.. code-block:: yaml

    # inventories/production/group_vars/all/main.yml
    ---
    # Environment identification
    environment: production
    environment_tier: prod
    
    # Global settings
    ansible_user: ansible-prod
    ansible_ssh_private_key_file: ~/.ssh/production-key
    ansible_become: true
    ansible_become_method: sudo
    
    # Networking
    dns_servers:
      - 8.8.8.8
      - 8.8.4.4
    ntp_servers:
      - time1.google.com
      - time2.google.com
    
    # Security settings
    security_hardening: true
    audit_logging: true
    compliance_mode: true
    
    # Monitoring and observability
    monitoring_enabled: true
    log_aggregation: true
    metrics_collection: true
    
    # Application settings
    app_environment: production
    debug_mode: false
    log_level: warn
    
    # Resource limits
    max_connections: 1000
    memory_limit: "4GB"
    disk_threshold: 85

=========================================
Terraform + Ansible Integration Workflows
=========================================

The most powerful IaC implementations combine Terraform for infrastructure provisioning with Ansible for configuration management in automated workflows.

**Complete Infrastructure + Configuration Workflow:**

.. code-block:: bash

    #!/bin/bash
    # deploy-infrastructure.sh - Complete deployment script
    
    set -euo pipefail
    
    # Configuration
    ENVIRONMENT=${1:-staging}
    TERRAFORM_DIR="./terraform/${ENVIRONMENT}"
    ANSIBLE_DIR="./ansible"
    
    echo " Starting deployment for environment: ${ENVIRONMENT}"
    
    # Step 1: Provision infrastructure with Terraform
    echo " Provisioning infrastructure..."
    cd "${TERRAFORM_DIR}"
    
    terraform init -upgrade
    terraform validate
    terraform plan -out=tfplan
    terraform apply tfplan
    
    # Step 2: Extract Terraform outputs for Ansible
    echo " Extracting infrastructure information..."
    terraform output -json > ../outputs/${ENVIRONMENT}.json
    
    # Step 3: Generate Ansible inventory from Terraform state
    cd "${ANSIBLE_DIR}"
    python3 scripts/terraform-to-inventory.py \
        --terraform-output="../terraform/outputs/${ENVIRONMENT}.json" \
        --output="inventories/${ENVIRONMENT}/terraform.yml"
    
    # Step 4: Wait for instances to be ready
    echo " Waiting for instances to be accessible..."
    ansible-playbook \
        -i "inventories/${ENVIRONMENT}" \
        playbooks/wait-for-ready.yml \
        --extra-vars "environment=${ENVIRONMENT}"
    
    # Step 5: Configure infrastructure with Ansible
    echo " Configuring infrastructure..."
    ansible-playbook \
        -i "inventories/${ENVIRONMENT}" \
        site.yml \
        --extra-vars "environment=${ENVIRONMENT}" \
        --vault-password-file="vault-password-files/${ENVIRONMENT}"
    
    # Step 6: Deploy applications
    echo " Deploying applications..."
    ansible-playbook \
        -i "inventories/${ENVIRONMENT}" \
        playbooks/deploy.yml \
        --extra-vars "environment=${ENVIRONMENT}" \
        --vault-password-file="vault-password-files/${ENVIRONMENT}"
    
    # Step 7: Run post-deployment tests
    echo " Running post-deployment tests..."
    ansible-playbook \
        -i "inventories/${ENVIRONMENT}" \
        playbooks/test.yml \
        --extra-vars "environment=${ENVIRONMENT}"
    
    echo " Deployment completed successfully!"

**Terraform Output Integration:**

.. code-block:: text

    # terraform/outputs.tf
    output "ansible_inventory" {
      description = "Ansible inventory data"
      value = {
        web_servers = {
          hosts = {
            for instance in google_compute_instance.web_servers :
            instance.name => {
              ansible_host = instance.network_interface[0].access_config[0].nat_ip
              internal_ip  = instance.network_interface[0].network_ip
              zone         = instance.zone
              instance_id  = instance.instance_id
              machine_type = instance.machine_type
              labels       = instance.labels
            }
          }
          vars = {
            role               = "webserver"
            nginx_port        = var.nginx_port
            ssl_enabled       = var.ssl_enabled
            backup_enabled    = true
          }
        }
        
        databases = {
          hosts = {
            for instance in google_compute_instance.databases :
            instance.name => {
              ansible_host = instance.network_interface[0].access_config[0].nat_ip
              internal_ip  = instance.network_interface[0].network_ip
              zone         = instance.zone
              instance_id  = instance.instance_id
            }
          }
          vars = {
            role               = "database"
            mysql_port        = var.mysql_port
            backup_schedule   = var.backup_schedule
            replication_mode  = var.replication_mode
          }
        }
        
        load_balancers = {
          hosts = {
            for lb in google_compute_instance.load_balancers :
            lb.name => {
              ansible_host = lb.network_interface[0].access_config[0].nat_ip
              internal_ip  = lb.network_interface[0].network_ip
            }
          }
          vars = {
            role = "loadbalancer"
            backend_servers = [
              for instance in google_compute_instance.web_servers :
              instance.network_interface[0].network_ip
            ]
          }
        }
      }
    }
    
    # Output network information for Ansible templates
    output "network_info" {
      value = {
        vpc_name     = google_compute_network.main.name
        subnet_cidr  = google_compute_subnetwork.main.ip_cidr_range
        firewall_rules = [
          for rule in google_compute_firewall.rules :
          {
            name   = rule.name
            ports  = rule.allow[0].ports
            ranges = rule.source_ranges
          }
        ]
      }
    }

**Inventory Generation Script:**

.. code-block:: python

    #!/usr/bin/env python3
    # scripts/terraform-to-inventory.py
    
    import json
    import yaml
    import argparse
    from pathlib import Path
    
    def terraform_to_ansible_inventory(terraform_output: dict) -> dict:
        """Convert Terraform output to Ansible inventory format"""
        
        inventory = {
            'all': {
                'children': {}
            },
            '_meta': {
                'hostvars': {}
            }
        }
        
        # Extract Terraform outputs
        tf_inventory = terraform_output.get('ansible_inventory', {}).get('value', {})
        network_info = terraform_output.get('network_info', {}).get('value', {})
        
        # Process each group from Terraform output
        for group_name, group_data in tf_inventory.items():
            inventory['all']['children'][group_name] = {
                'hosts': list(group_data['hosts'].keys()),
                'vars': group_data.get('vars', {})
            }
            
            # Add network information to group vars
            if network_info:
                inventory['all']['children'][group_name]['vars'].update({
                    'vpc_name': network_info.get('vpc_name'),
                    'subnet_cidr': network_info.get('subnet_cidr'),
                    'firewall_rules': network_info.get('firewall_rules', [])
                })
            
            # Add host variables
            for hostname, host_vars in group_data['hosts'].items():
                inventory['_meta']['hostvars'][hostname] = host_vars
        
        return inventory
    
    def main():
        parser = argparse.ArgumentParser(description='Convert Terraform output to Ansible inventory')
        parser.add_argument('--terraform-output', required=True, help='Path to Terraform JSON output file')
        parser.add_argument('--output', required=True, help='Path to output Ansible inventory file')
        
        args = parser.parse_args()
        
        # Read Terraform output
        with open(args.terraform_output, 'r') as f:
            terraform_data = json.load(f)
        
        # Convert to Ansible inventory
        inventory = terraform_to_ansible_inventory(terraform_data)
        
        # Write Ansible inventory
        output_path = Path(args.output)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        
        with open(output_path, 'w') as f:
            yaml.dump(inventory, f, default_flow_style=False, sort_keys=False)
        
        print(f"✅ Generated Ansible inventory: {output_path}")
    
    if __name__ == '__main__':
        main()

**Integration Playbook:**

.. code-block:: yaml

    ---
    # playbooks/terraform-integration.yml
    - name: Terraform + Ansible Integration
      hosts: localhost
      gather_facts: false
      
      vars:
        terraform_dir: "../terraform/{{ environment }}"
        
      tasks:
        - name: Check Terraform state
          stat:
            path: "{{ terraform_dir }}/terraform.tfstate"
          register: tf_state
          
        - name: Fail if Terraform state not found
          fail:
            msg: "Terraform state not found. Run terraform apply first."
          when: not tf_state.stat.exists
        
        - name: Get Terraform outputs
          shell: terraform output -json
          args:
            chdir: "{{ terraform_dir }}"
          register: tf_outputs
          changed_when: false
        
        - name: Parse Terraform outputs
          set_fact:
            terraform_data: "{{ tf_outputs.stdout | from_json }}"
        
        - name: Display infrastructure summary
          debug:
            msg: |
              Infrastructure Summary:
              - Web Servers: {{ terraform_data.ansible_inventory.value.web_servers.hosts | length }}
              - Databases: {{ terraform_data.ansible_inventory.value.databases.hosts | length }}
              - Load Balancers: {{ terraform_data.ansible_inventory.value.load_balancers.hosts | length }}
              - VPC: {{ terraform_data.network_info.value.vpc_name }}
        
        - name: Wait for all instances to be accessible
          wait_for:
            host: "{{ hostvars[item]['ansible_host'] }}"
            port: 22
            timeout: 300
          loop: "{{ groups['all'] }}"
          when: hostvars[item]['ansible_host'] is defined

==========================
CI/CD Pipeline Integration
==========================

Modern DevOps requires Ansible to integrate seamlessly with continuous integration and deployment pipelines.

**GitHub Actions Workflow:**

.. code-block:: yaml

    # .github/workflows/infrastructure-deployment.yml
    name: Infrastructure Deployment
    
    on:
      push:
        branches: [main]
        paths: 
          - 'terraform/**'
          - 'ansible/**'
      pull_request:
        branches: [main]
        paths:
          - 'terraform/**'
          - 'ansible/**'
    
    env:
      ENVIRONMENT: ${{ github.ref == 'refs/heads/main' && 'production' || 'staging' }}
      
    jobs:
      validate:
        name: Validate Infrastructure Code
        runs-on: ubuntu-latest
        
        steps:
          - name: Checkout code
            uses: actions/checkout@v3
          
          - name: Setup Terraform
            uses: hashicorp/setup-terraform@v2
            with:
              terraform_version: 1.5.0
          
          - name: Setup Python
            uses: actions/setup-python@v4
            with:
              python-version: '3.9'
          
          - name: Install Ansible
            run: |
              pip install ansible google-auth requests
              ansible-galaxy collection install google.cloud community.general
          
          - name: Validate Terraform
            run: |
              cd terraform/${{ env.ENVIRONMENT }}
              terraform init -backend=false
              terraform validate
              terraform fmt -check
          
          - name: Lint Ansible
            run: |
              cd ansible
              ansible-lint site.yml
              ansible-playbook --syntax-check site.yml
          
          - name: Test Ansible roles
            run: |
              cd ansible
              molecule test
    
      deploy-staging:
        name: Deploy to Staging
        runs-on: ubuntu-latest
        needs: validate
        if: github.event_name == 'pull_request'
        environment: staging
        
        steps:
          - name: Checkout code
            uses: actions/checkout@v3
          
          - name: Configure GCP credentials
            uses: google-github-actions/auth@v1
            with:
              credentials_json: ${{ secrets.GCP_SERVICE_ACCOUNT_KEY }}
          
          - name: Setup Terraform
            uses: hashicorp/setup-terraform@v2
            with:
              terraform_version: 1.5.0
          
          - name: Deploy infrastructure
            run: |
              cd terraform/staging
              terraform init
              terraform plan
              terraform apply -auto-approve
          
          - name: Setup Ansible
            run: |
              pip install ansible google-auth
              ansible-galaxy collection install google.cloud
          
          - name: Configure infrastructure
            run: |
              cd ansible
              ansible-playbook \
                -i inventories/staging \
                site.yml \
                --vault-password-file <(echo "${{ secrets.ANSIBLE_VAULT_PASSWORD }}")
          
          - name: Run integration tests
            run: |
              cd ansible
              ansible-playbook \
                -i inventories/staging \
                playbooks/test.yml
    
      deploy-production:
        name: Deploy to Production
        runs-on: ubuntu-latest
        needs: validate
        if: github.ref == 'refs/heads/main'
        environment: production
        
        steps:
          - name: Checkout code
            uses: actions/checkout@v3
          
          - name: Configure GCP credentials
            uses: google-github-actions/auth@v1
            with:
              credentials_json: ${{ secrets.GCP_SERVICE_ACCOUNT_KEY }}
          
          - name: Deploy with approval
            run: |
              echo "Deploying to production requires manual approval"
              ./scripts/deploy-infrastructure.sh production
            env:
              VAULT_PASSWORD: ${{ secrets.ANSIBLE_VAULT_PASSWORD_PROD }}

**GitLab CI/CD Pipeline:**

.. code-block:: yaml

    # .gitlab-ci.yml
    stages:
      - validate
      - test
      - deploy-staging
      - deploy-production
    
    variables:
      TERRAFORM_VERSION: "1.5.0"
      ANSIBLE_VERSION: "6.0.0"
    
    before_script:
      - apt-get update -qq && apt-get install -y -qq python3-pip
      - pip3 install ansible==$ANSIBLE_VERSION google-auth requests
      - ansible-galaxy collection install google.cloud community.general
    
    validate-terraform:
      stage: validate
      image: hashicorp/terraform:$TERRAFORM_VERSION
      script:
        - cd terraform/staging
        - terraform init -backend=false
        - terraform validate
        - terraform fmt -check
      only:
        changes:
          - terraform/**/*
    
    validate-ansible:
      stage: validate
      image: python:3.9
      script:
        - cd ansible
        - ansible-lint site.yml
        - ansible-playbook --syntax-check site.yml
      only:
        changes:
          - ansible/**/*
    
    test-ansible-roles:
      stage: test
      image: python:3.9
      services:
        - docker:dind
      script:
        - pip3 install molecule[docker] docker
        - cd ansible
        - molecule test
      only:
        changes:
          - ansible/roles/**/*
    
    deploy-staging:
      stage: deploy-staging
      image: python:3.9
      environment:
        name: staging
        url: https://staging.example.com
      script:
        - ./scripts/deploy-infrastructure.sh staging
      only:
        - merge_requests
      when: manual
    
    deploy-production:
      stage: deploy-production
      image: python:3.9
      environment:
        name: production
        url: https://example.com
      script:
        - ./scripts/deploy-infrastructure.sh production
      only:
        - main
      when: manual

**Testing Integration:**

.. code-block:: yaml

    # ansible/playbooks/test.yml
    ---
    - name: Post-deployment testing
      hosts: all
      gather_facts: true
      
      tasks:
        - name: Test SSH connectivity
          ping:
          tags: [connectivity]
        
        - name: Verify required services are running
          systemd:
            name: "{{ item }}"
            state: started
          check_mode: yes
          register: service_status
          failed_when: service_status.failed
          loop:
            - nginx
            - mysql
            - redis
          tags: [services]
        
        - name: Test web server response
          uri:
            url: "https://{{ ansible_host }}"
            method: GET
            status_code: 200
            timeout: 10
          delegate_to: localhost
          when: "'web_servers' in group_names"
          tags: [web]
        
        - name: Test database connectivity
          mysql_db:
            name: "{{ app_database_name }}"
            state: present
          check_mode: yes
          when: "'databases' in group_names"
          tags: [database]
        
        - name: Verify SSL certificates
          openssl_certificate:
            path: "/etc/ssl/certs/{{ domain_name }}.crt"
            provider: assertonly
            valid_in: 2592000  # 30 days
          when: ssl_enabled | default(false)
          tags: [ssl]

=======================
Security and Compliance
=======================

Production Ansible deployments must implement comprehensive security and compliance measures.

**Security Hardening Playbook:**

.. code-block:: yaml

    ---
    # roles/security/tasks/main.yml
    - name: Apply security hardening
      hosts: all
      become: true
      
      vars:
        security_audit: true
        compliance_standard: "CIS"  # CIS, SOC2, PCI-DSS
        
      tasks:
        - name: Include OS-specific security tasks
          include_tasks: "{{ ansible_os_family | lower }}.yml"
        
        - name: Configure SSH hardening
          include_tasks: ssh-hardening.yml
          tags: [ssh, security]
        
        - name: Configure firewall rules
          include_tasks: firewall.yml
          tags: [firewall, security]
        
        - name: Configure audit logging
          include_tasks: audit.yml
          tags: [audit, compliance]
        
        - name: Install security tools
          include_tasks: security-tools.yml
          tags: [tools, security]
        
        - name: Configure file permissions
          include_tasks: file-permissions.yml
          tags: [permissions, security]

**SSH Hardening Tasks:**

.. code-block:: yaml

    # roles/security/tasks/ssh-hardening.yml
    ---
    - name: Configure secure SSH settings
      lineinfile:
        path: /etc/ssh/sshd_config
        regexp: "{{ item.regexp }}"
        line: "{{ item.line }}"
        backup: yes
      loop:
        - { regexp: '^#?PermitRootLogin', line: 'PermitRootLogin no' }
        - { regexp: '^#?PasswordAuthentication', line: 'PasswordAuthentication no' }
        - { regexp: '^#?PubkeyAuthentication', line: 'PubkeyAuthentication yes' }
        - { regexp: '^#?Protocol', line: 'Protocol 2' }
        - { regexp: '^#?X11Forwarding', line: 'X11Forwarding no' }
        - { regexp: '^#?MaxAuthTries', line: 'MaxAuthTries 3' }
        - { regexp: '^#?ClientAliveInterval', line: 'ClientAliveInterval 300' }
        - { regexp: '^#?ClientAliveCountMax', line: 'ClientAliveCountMax 2' }
        - { regexp: '^#?LoginGraceTime', line: 'LoginGraceTime 60' }
      notify: restart sshd
    
    - name: Configure SSH allowed users
      lineinfile:
        path: /etc/ssh/sshd_config
        line: "AllowUsers {{ ssh_allowed_users | join(' ') }}"
        regexp: '^AllowUsers'
      when: ssh_allowed_users is defined
      notify: restart sshd
    
    - name: Configure SSH key algorithms
      blockinfile:
        path: /etc/ssh/sshd_config
        block: |
          # Strong crypto
          KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group14-sha256,diffie-hellman-group16-sha512
          Ciphers aes256-gcm@openssh.com,chacha20-poly1305@openssh.com,aes256-ctr
          MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,hmac-sha2-256,hmac-sha2-512
        marker: "# {mark} ANSIBLE MANAGED BLOCK - SSH CRYPTO"
      notify: restart sshd

**Compliance Reporting:**

.. code-block:: yaml

    # roles/security/tasks/compliance-report.yml
    ---
    - name: Generate compliance report
      block:
        - name: Check SSH configuration compliance
          shell: |
            sshd -T | grep -E "(permitrootlogin|passwordauthentication|protocol|maxauthtries)"
          register: ssh_compliance
          changed_when: false
        
        - name: Check firewall status
          systemd:
            name: ufw
            state: started
          check_mode: yes
          register: firewall_status
          failed_when: false
        
        - name: Check audit daemon
          systemd:
            name: auditd
            state: started
          check_mode: yes
          register: audit_status
          failed_when: false
        
        - name: Generate compliance report
          template:
            src: compliance-report.j2
            dest: "/var/log/compliance-{{ ansible_date_time.iso8601_basic_short }}.json"
          vars:
            compliance_data:
              hostname: "{{ inventory_hostname }}"
              timestamp: "{{ ansible_date_time.iso8601 }}"
              ssh_config: "{{ ssh_compliance.stdout_lines }}"
              firewall_enabled: "{{ firewall_status.state == 'started' }}"
              audit_enabled: "{{ audit_status.state == 'started' }}"
              os_info:
                distribution: "{{ ansible_distribution }}"
                version: "{{ ansible_distribution_version }}"
                kernel: "{{ ansible_kernel }}"
        
        - name: Upload compliance report
          uri:
            url: "{{ compliance_reporting_url }}"
            method: POST
            headers:
              Authorization: "Bearer {{ compliance_api_token }}"
            body_format: json
            body: "{{ compliance_data }}"
          when: compliance_reporting_url is defined

**Secrets Management with Vault:**

.. code-block:: yaml

    # group_vars/production/vault.yml (encrypted)
    ---
    vault_database_credentials:
      master_password: "super_secure_master_password"
      replication_password: "replication_password_123"
      backup_password: "backup_password_456"
    
    vault_ssl_certificates:
      private_key: |
        -----BEGIN PRIVATE KEY-----
        MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDXyZ...
        -----END PRIVATE KEY-----
      certificate: |
        -----BEGIN CERTIFICATE-----
        MIIDXTCCAkWgAwIBAgIJAKoK/heBjcOuMA0GCSqGSIb3DQEBBQUAMEUx...
        -----END CERTIFICATE-----
    
    vault_api_keys:
      monitoring: "mon_1234567890abcdef"
      logging: "log_abcdef1234567890"
      backup: "bak_567890abcdef1234"
    
    vault_service_accounts:
      gcp_service_account: |
        {
          "type": "service_account",
          "project_id": "my-project",
          "private_key_id": "key123",
          "private_key": "-----BEGIN PRIVATE KEY-----\n...",
          "client_email": "service@my-project.iam.gserviceaccount.com",
          "client_id": "123456789",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token"
        }

============================
Monitoring and Observability
============================

Production Ansible environments require comprehensive monitoring and observability to ensure reliability and performance.

**Ansible Callback Plugin for Monitoring:**

.. code-block:: python

    # callback_plugins/monitoring.py
    from ansible.plugins.callback import CallbackBase
    import json
    import requests
    import time
    from datetime import datetime
    
    class CallbackModule(CallbackBase):
        """Send Ansible execution metrics to monitoring system"""
        
        CALLBACK_VERSION = 2.0
        CALLBACK_TYPE = 'notification'
        CALLBACK_NAME = 'monitoring'
        
        def __init__(self):
            super(CallbackModule, self).__init__()
            self.start_time = None
            self.monitoring_url = "https://monitoring.example.com/api/ansible"
            self.api_token = "your-monitoring-api-token"
            
        def v2_playbook_on_start(self, playbook):
            self.start_time = time.time()
            self.playbook_name = playbook._file_name
            
            # Send playbook start event
            self._send_metric({
                'event': 'playbook_started',
                'playbook': self.playbook_name,
                'timestamp': datetime.utcnow().isoformat(),
                'environment': self._get_var('environment')
            })
        
        def v2_playbook_on_stats(self, stats):
            end_time = time.time()
            duration = end_time - self.start_time
            
            # Collect execution statistics
            summary = {}
            for host in stats.processed:
                summary[host] = stats.summarize(host)
            
            # Send completion metrics
            self._send_metric({
                'event': 'playbook_completed',
                'playbook': self.playbook_name,
                'duration': duration,
                'summary': summary,
                'timestamp': datetime.utcnow().isoformat(),
                'environment': self._get_var('environment')
            })
        
        def v2_runner_on_failed(self, result, ignore_errors=False):
            # Send failure alerts
            self._send_metric({
                'event': 'task_failed',
                'playbook': self.playbook_name,
                'host': result._host.get_name(),
                'task': result._task.get_name(),
                'error': str(result._result.get('msg', 'Unknown error')),
                'timestamp': datetime.utcnow().isoformat(),
                'environment': self._get_var('environment')
            })
        
        def _send_metric(self, data):
            try:
                requests.post(
                    self.monitoring_url,
                    json=data,
                    headers={'Authorization': f'Bearer {self.api_token}'},
                    timeout=5
                )
            except Exception as e:
                self._display.warning(f"Failed to send monitoring data: {e}")
        
        def _get_var(self, var_name):
            return getattr(self, f'_options', {}).get(var_name, 'unknown')

**Logging Configuration:**

.. code-block:: yaml

    # roles/monitoring/tasks/logging.yml
    ---
    - name: Configure centralized logging
      block:
        - name: Install logging agent
          package:
            name: "{{ logging_agent_package }}"
            state: present
        
        - name: Configure log forwarding
          template:
            src: "{{ logging_config_template }}"
            dest: "{{ logging_config_path }}"
            backup: yes
          notify: restart logging agent
          vars:
            log_server: "{{ centralized_log_server }}"
            log_port: "{{ centralized_log_port }}"
            environment: "{{ environment }}"
            service_name: "{{ inventory_hostname }}"
        
        - name: Configure Ansible log rotation
          template:
            src: ansible-logrotate.j2
            dest: /etc/logrotate.d/ansible
          vars:
            log_retention_days: 30
            max_log_size: "100M"
        
        - name: Create Ansible log directory
          file:
            path: /var/log/ansible
            state: directory
            owner: ansible
            group: ansible
            mode: '0750'
        
        - name: Configure Ansible logging
          lineinfile:
            path: /etc/ansible/ansible.cfg
            regexp: '^#?log_path'
            line: 'log_path = /var/log/ansible/ansible.log'
            create: yes

**Performance Monitoring Playbook:**

.. code-block:: yaml

    # playbooks/performance-monitoring.yml
    ---
    - name: Monitor Ansible performance
      hosts: localhost
      gather_facts: false
      
      tasks:
        - name: Start performance monitoring
          debug:
            msg: "Starting performance monitoring for {{ ansible_play_name }}"
        
        - name: Record start time
          set_fact:
            monitoring_start_time: "{{ ansible_date_time.epoch }}"
        
        - name: Monitor system resources during execution
          shell: |
            top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1
          register: cpu_usage
          changed_when: false
        
        - name: Monitor memory usage
          shell: |
            free | grep Mem | awk '{printf "%.2f", ($3/$2) * 100.0}'
          register: memory_usage
          changed_when: false
        
        - name: Record resource usage
          set_fact:
            resource_metrics:
              cpu_usage: "{{ cpu_usage.stdout }}"
              memory_usage: "{{ memory_usage.stdout }}"
              timestamp: "{{ ansible_date_time.iso8601 }}"
        
        - name: Send metrics to monitoring system
          uri:
            url: "{{ monitoring_api_url }}/metrics"
            method: POST
            headers:
              Authorization: "Bearer {{ monitoring_api_token }}"
            body_format: json
            body:
              service: "ansible"
              environment: "{{ environment }}"
              metrics: "{{ resource_metrics }}"
          when: monitoring_api_url is defined

=======================
Scaling and Performance
=======================

Large-scale Ansible deployments require specific patterns and optimizations for performance and reliability.

**High-Performance Ansible Configuration:**

.. code-block:: ini

    # ansible.cfg for production scale
    [defaults]
    # Increase parallel execution
    forks = 100
    
    # Optimize SSH connections
    host_key_checking = False
    ssh_args = -o ControlMaster=auto -o ControlPersist=600s -o UserKnownHostsFile=/dev/null
    pipelining = True
    
    # Performance optimizations
    gathering = smart
    fact_caching = redis
    fact_caching_connection = redis-cluster.example.com:6379:0
    fact_caching_timeout = 86400
    
    # Reduce output verbosity in production
    stdout_callback = minimal
    bin_ansible_callbacks = True
    
    # Connection settings
    timeout = 30
    
    # Retry settings
    retry_files_enabled = True
    retry_files_save_path = ~/.ansible-retry
    
    [ssh_connection]
    # SSH multiplexing
    ssh_args = -o ControlMaster=auto -o ControlPersist=600s
    control_path_dir = ~/.ansible/cp
    control_path = %(directory)s/%%h-%%p-%%r
    
    # Connection pooling
    ssh_executable = /usr/bin/ssh
    scp_if_ssh = smart
    transfer_method = smart

**Scaling Patterns:**

.. code-block:: yaml

    # playbooks/scaled-deployment.yml
    ---
    - name: Scaled deployment with batching
      hosts: web_servers
      serial: "25%"  # Deploy to 25% of hosts at a time
      max_fail_percentage: 10  # Allow 10% failure rate
      
      pre_tasks:
        - name: Remove host from load balancer
          uri:
            url: "{{ load_balancer_api }}/remove/{{ inventory_hostname }}"
            method: POST
          delegate_to: localhost
          
      tasks:
        - name: Deploy application
          include_role:
            name: application
          vars:
            app_version: "{{ new_app_version }}"
        
        - name: Verify deployment
          uri:
            url: "http://{{ ansible_default_ipv4.address }}:8080/health"
            status_code: 200
          retries: 5
          delay: 10
      
      post_tasks:
        - name: Add host back to load balancer
          uri:
            url: "{{ load_balancer_api }}/add/{{ inventory_hostname }}"
            method: POST
          delegate_to: localhost

**Async Operations for Scale:**

.. code-block:: yaml

    - name: Large-scale async operations
      hosts: all
      
      tasks:
        - name: Start large file downloads asynchronously
          get_url:
            url: "{{ item.url }}"
            dest: "{{ item.dest }}"
          async: 1800  # 30 minutes timeout
          poll: 0      # Fire and forget
          loop: "{{ large_files }}"
          register: download_jobs
          
        - name: Continue with other tasks while downloads happen
          package:
            name: "{{ required_packages }}"
            state: present
        
        - name: Check download progress
          async_status:
            jid: "{{ item.ansible_job_id }}"
          register: download_results
          until: download_results.finished
          retries: 180
          delay: 10
          loop: "{{ download_jobs.results }}"

============================
Disaster Recovery and Backup
============================

Production environments require comprehensive disaster recovery and backup strategies implemented through Ansible.

**Backup Automation:**

.. code-block:: yaml

    # roles/backup/tasks/main.yml
    ---
    - name: Create backup directories
      file:
        path: "{{ item }}"
        state: directory
        owner: backup
        group: backup
        mode: '0750'
      loop:
        - /backup/database
        - /backup/application
        - /backup/system
    
    - name: Database backup
      mysql_db:
        name: "{{ item }}"
        state: dump
        target: "/backup/database/{{ item }}-{{ ansible_date_time.date }}.sql"
      loop: "{{ databases_to_backup }}"
      when: "'databases' in group_names"
    
    - name: Application data backup
      archive:
        path: "{{ app_data_path }}"
        dest: "/backup/application/app-data-{{ ansible_date_time.date }}.tar.gz"
        remove: false
      when: "'web_servers' in group_names"
    
    - name: System configuration backup
      archive:
        path:
          - /etc
          - /var/lib
        dest: "/backup/system/system-config-{{ ansible_date_time.date }}.tar.gz"
        exclude_path:
          - /etc/shadow
          - /etc/passwd
        remove: false
    
    - name: Upload backups to cloud storage
      gcp_storage_object:
        bucket: "{{ backup_bucket }}"
        src: "{{ item }}"
        dest: "{{ inventory_hostname }}/{{ item | basename }}"
      loop:
        - "/backup/database/*.sql"
        - "/backup/application/*.tar.gz"
        - "/backup/system/*.tar.gz"

**Disaster Recovery Playbook:**

.. code-block:: yaml

    # playbooks/disaster-recovery.yml
    ---
    - name: Disaster recovery procedures
      hosts: localhost
      gather_facts: false
      
      vars_prompt:
        - name: recovery_type
          prompt: "Recovery type (full|partial|data-only)"
          private: false
          default: "partial"
        
        - name: backup_date
          prompt: "Backup date to restore (YYYY-MM-DD)"
          private: false
      
      tasks:
        - name: Validate recovery parameters
          assert:
            that:
              - recovery_type in ['full', 'partial', 'data-only']
              - backup_date | regex_search('^\d{4}-\d{2}-\d{2}$')
            fail_msg: "Invalid recovery parameters"
        
        - name: Provision new infrastructure (full recovery)
          include: ../terraform/emergency-provision.yml
          when: recovery_type == 'full'
        
        - name: Restore from backups
          include_tasks: restore-from-backup.yml
          vars:
            restore_date: "{{ backup_date }}"
        
        - name: Verify system functionality
          include_tasks: verify-recovery.yml
        
        - name: Update DNS and load balancer
          include_tasks: update-traffic-routing.yml
          when: recovery_type == 'full'


.. note::

    The patterns and practices in this chapter represent years of production experience with Infrastructure as Code. While the examples use Google Cloud Platform, the principles apply to any cloud provider or hybrid environment. Focus on understanding the patterns rather than memorizing specific syntax.
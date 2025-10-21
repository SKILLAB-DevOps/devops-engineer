#######################################
10.6 Ansible - Configuration Management
#######################################

===================
Learning Objectives
===================

By the end of this chapter, you will be able to:

• **Define** configuration management and understand its role in the IaC ecosystem
• **Install** and configure Ansible for managing Google Cloud Platform resources
• **Write** Ansible playbooks using YAML syntax and best practices
• **Manage** inventory files for different environments and cloud deployments
• **Implement** Ansible roles for modular and reusable configuration management
• **Apply** Ansible security practices including Ansible Vault for secrets management
• **Integrate** Ansible with Terraform workflows for complete infrastructure automation
• **Troubleshoot** common Ansible issues and connectivity problems
• **Design** scalable Ansible architectures for production environments

**Prerequisites:** Understanding of basic Linux administration, SSH connectivity, and familiarity with YAML syntax. Knowledge of Terraform from previous chapters is recommended.

**Chapter Focus:** This chapter focuses on **Ansible for configuration management** with practical examples using Google Cloud Platform infrastructure provisioned by Terraform.

==================================
What is Configuration Management?
==================================

Configuration management is the practice of handling changes to a system in a way that maintains integrity over time. In the context of infrastructure, it ensures that servers and applications are configured consistently and remain in their desired state.

**The Configuration Management Problem**

After infrastructure is provisioned (using tools like Terraform), you need to:

- Install and configure software packages
- Set up application services and dependencies
- Configure security settings and user accounts
- Deploy applications and manage their lifecycle
- Ensure configurations remain consistent over time

**Without Configuration Management:**

.. code-block:: bash

    # Manual approach - error-prone and not scalable
    ssh user@server1 "sudo apt update && sudo apt install nginx"
    ssh user@server2 "sudo apt update && sudo apt install nginx"
    ssh user@server3 "sudo apt update && sudo apt install nginx"
    
    # Different results on each server:
    # - Server1: nginx 1.18.0, different config
    # - Server2: nginx 1.20.1, default config  
    # - Server3: nginx failed to install

**With Ansible Configuration Management:**

.. code-block:: yaml

    # Declarative approach - consistent and scalable
    - name: Configure web servers
      hosts: web_servers
      become: true
      
      tasks:
        - name: Install Nginx
          apt:
            name: nginx
            state: present
            update_cache: yes
        
        - name: Configure Nginx
          template:
            src: nginx.conf.j2
            dest: /etc/nginx/nginx.conf
          notify: restart nginx
    
    # Result: All servers have identical configuration

================
What is Ansible?
================

Ansible is an open-source automation tool that automates software provisioning, configuration management, and application deployment. Created by Michael DeHaan in 2012 and acquired by Red Hat in 2015.

**Core Ansible Principles:**

1. **Simple**: Uses YAML syntax that's easy to read and write
2. **Agentless**: No agents to install or manage on target systems
3. **Powerful**: Can manage everything from packages to complex deployments
4. **Flexible**: Works with any system that can run Python and accept SSH connections
5. **Efficient**: Push-based model with parallel execution

**Key Ansible Characteristics:**

+-------------------------+----------------------------------------+
| **Characteristic**      | **Description**                        |
+=========================+========================================+
| **Communication**       | SSH for Linux/Unix, WinRM for Windows  |
+-------------------------+----------------------------------------+
| **Language**            | YAML for playbooks, Python for modules |
+-------------------------+----------------------------------------+
| **Architecture**        | Push-based (control node pushes)       |
+-------------------------+----------------------------------------+
| **State**               | Stateless (no central database)        |
+-------------------------+----------------------------------------+
| **Execution**           | Sequential task execution              |
+-------------------------+----------------------------------------+
| **Idempotency**         | Tasks can be run multiple times safely |
+-------------------------+----------------------------------------+

**Ansible vs Other Configuration Management Tools:**

+-------------------+-------------+----------+----------+---------------+
| **Feature**       | **Ansible** | **Chef** | **Puppet** | **Salt**    |
+===================+=============+==========+============+=============+
| **Agent Required**| No          | Yes      | Yes        | Yes         |
+-------------------+-------------+----------+----------+---------------+
| **Language**      | YAML        | Ruby     | Puppet DSL | YAML/Python |
+-------------------+-------------+----------+----------+---------------+  
| **Architecture**  | Push        | Pull     | Pull       | Push/Pull   |
+-------------------+-------------+----------+----------+---------------+
| **Learning Curve**| Easy        | Steep    | Moderate   | Moderate    |
+-------------------+-------------+----------+----------+---------------+
| **Setup Time**    | Minutes     | Hours    | Hours      | Hours       |
+-------------------+-------------+----------+----------+---------------+

.. note::

    For a detailed comparison between Ansible and Puppet, including architectural differences, configuration syntax examples, and decision criteria, see **Chapter 10.0: Infrastructure as Code Introduction**, section "Configuration Management: Ansible vs Puppet".

===================================
Ansible Architecture and Components
===================================

**Ansible Control Node**

The machine where Ansible is installed and from which automation is executed:

.. code-block:: text

    Control Node (Your laptop/CI server)
    ├── Ansible Core Engine
    ├── Inventory Files (defines target hosts)
    ├── Playbooks (automation scripts)
    ├── Roles (reusable automation)
    └── Configuration (ansible.cfg)

**Managed Nodes**

The target machines that Ansible manages:

.. code-block:: text

    Managed Nodes (GCP Compute Engine instances)
    ├── SSH Server (for connectivity)
    ├── Python (for module execution)
    └── Target Applications/Services

**Core Ansible Components:**

1. **Inventory**: Defines which machines to manage

.. code-block:: ini

    [web_servers]
    web1.example.com
    web2.example.com
    
    [databases]
    db1.example.com
    
    [production:children]
    web_servers
    databases

2. **Playbooks**: YAML files that define automation workflows

.. code-block:: yaml

    ---
    - name: Configure web servers
      hosts: web_servers
      become: true
      
      tasks:
        - name: Install packages
          apt:
            name: "{{ item }}"
            state: present
          loop:
            - nginx
            - git
            - curl

3. **Modules**: Reusable units of code that perform specific tasks

.. code-block:: yaml

    - name: Manage files
      file:
        path: /var/www/html
        state: directory
        owner: www-data
        group: www-data
        mode: '0755'

4. **Roles**: Organized collections of playbooks, variables, and files

.. code-block:: text

    roles/
    └── webserver/
        ├── tasks/main.yml      # Main task list
        ├── handlers/main.yml   # Event handlers
        ├── templates/          # Jinja2 templates
        ├── files/             # Static files
        ├── vars/main.yml      # Role variables
        └── defaults/main.yml  # Default variables

======================================
Ansible in the Modern DevOps Toolchain
======================================

Ansible fits into the broader DevOps ecosystem as the configuration management layer:

.. code-block:: text

    DevOps Toolchain Integration:
    
    1. Version Control (Git)
       ├── Infrastructure code (Terraform)
       ├── Configuration code (Ansible)
       └── Application code
    
    2. CI/CD Pipeline
       ├── Test infrastructure code
       ├── Apply infrastructure changes (Terraform)
       ├── Configure infrastructure (Ansible)
       └── Deploy applications (Ansible)
    
    3. Monitoring & Observability
       ├── Infrastructure monitoring
       ├── Application monitoring
       └── Configuration drift detection

**Typical Workflow: Terraform + Ansible**

.. code-block:: bash

    # 1. Developer commits infrastructure changes
    git add infrastructure/ configuration/
    git commit -m "Add load balancer and update web server config"
    git push origin main
    
    # 2. CI/CD pipeline triggers
    # 2a. Provision infrastructure
    terraform init
    terraform plan
    terraform apply
    
    # 2b. Configure infrastructure  
    ansible-playbook -i gcp_inventory.yml site.yml
    
    # 2c. Deploy applications
    ansible-playbook -i gcp_inventory.yml deploy.yml

**Example: Complete Web Application Setup**

**Step 1: Terraform provisions the infrastructure**

.. code-block:: hcl

    # Create GCP compute instances
    resource "google_compute_instance" "web_servers" {
      count        = 3
      name         = "web-${count.index + 1}"
      machine_type = "e2-standard-2"
      zone         = "us-central1-a"
      
      boot_disk {
        initialize_params {
          image = "ubuntu-os-cloud/ubuntu-2204-lts"
        }
      }
      
      network_interface {
        network = google_compute_network.main.id
        access_config {}
      }
      
      metadata = {
        ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
      }
    }

**Step 2: Ansible configures the servers**

.. code-block:: yaml

    ---
    - name: Configure web application stack
      hosts: web_servers
      become: true
      
      roles:
        - common        # Basic server setup
        - security      # Security hardening
        - nginx         # Web server configuration
        - application   # App deployment
        - monitoring    # Observability setup

**Step 3: Ansible deploys and manages applications**

.. code-block:: yaml

    - name: Deploy web application
      hosts: web_servers
      
      tasks:
        - name: Pull latest application code
          git:
            repo: https://github.com/company/webapp.git
            dest: /var/www/html
            version: "{{ app_version | default('main') }}"
          notify: restart nginx
        
        - name: Install application dependencies
          pip:
            requirements: /var/www/html/requirements.txt
            virtualenv: /var/www/html/venv
        
        - name: Update application configuration
          template:
            src: app_config.py.j2
            dest: /var/www/html/config.py
            owner: www-data
            group: www-data
            mode: '0644'
          notify: restart application

====================================
Ansible Use Cases and When to Use It
====================================

**Primary Ansible Use Cases:**

1. **Configuration Management**
   
   - Installing and configuring software packages
   - Managing system configurations and settings
   - Ensuring configuration consistency across environments

2. **Application Deployment**
   
   - Deploying web applications and services
   - Managing application lifecycle (start, stop, restart)
   - Rolling updates and blue-green deployments

3. **Orchestration**
   
   - Complex multi-step procedures
   - Coordinating actions across multiple systems
   - Managing dependencies between services

4. **Continuous Delivery**
   
   - Automated deployment pipelines
   - Integration with CI/CD systems
   - Environment promotion workflows

**When to Use Ansible:**

+---------------------------+---------------------------------+
| **Use Ansible When**      | **Example Scenarios**           |
+===========================+=================================+
| Infrastructure**          | • Configure SSL certificates    |
|                           | • Set up monitoring agents      |
+---------------------------+---------------------------------+
| **Application Deployment**| • Deploy web applications       |
|                           | • Update database schemas       |
|                           | • Manage application configs    |
+---------------------------+---------------------------------+
| **Operational Tasks**     | • Backup procedures             |
|                           | • Security patching             |
|                           | • Log rotation and cleanup      |
+---------------------------+---------------------------------+
| **Multi-step Workflows**  | • Blue-green deployments        |
|                           | • Database migration workflows  |
|                           | • Disaster recovery procedures  |
+---------------------------+---------------------------------+

**When NOT to Use Ansible:**

+----------------------------+----------------------------------+
| **Don't Use Ansible For**  | **Use Instead**                  |
+============================+==================================+
| **Infrastructure           | • Terraform/OpenTofu             |
| Provisioning**             | • CloudFormation                 |
|                            | • Google Cloud Deployment Mgr    |
+----------------------------+----------------------------------+
| **Real-time Monitoring**   | • Prometheus + Grafana           |
|                            | • Google Cloud Monitoring        |
|                            | • Datadog, New Relic             |
+----------------------------+----------------------------------+
| **Container Orchestration**| • Kubernetes                     |
|                            | • Docker Swarm                   |
|                            | • Google Kubernetes Engine       |
+----------------------------+----------------------------------+
| **Secrets Management**     | • HashiCorp Vault                |
|                            | • Google Secret Manager          |
|                            | • AWS Secrets Manager            |
+---------------------------+-----------------------------------+

==============================
Ansible Installation and Setup
==============================

**Installation Options:**

.. code-block:: bash

    # Option 1: Using pip (recommended)
    pip3 install ansible
    
    # Option 2: Using package manager (Ubuntu/Debian)
    sudo apt update
    sudo apt install ansible
    
    # Option 3: Using package manager (macOS)
    brew install ansible
    
    # Verify installation
    ansible --version
    ansible-playbook --version

**Initial Configuration:**

.. code-block:: bash

    # Create Ansible configuration file
    mkdir -p ~/.ansible
    cat > ~/.ansible/ansible.cfg << EOF
    [defaults]
    inventory = ./inventory
    remote_user = ubuntu
    private_key_file = ~/.ssh/id_rsa
    host_key_checking = False
    timeout = 30
    
    [privilege_escalation]
    become = True
    become_method = sudo
    become_user = root
    EOF

**Google Cloud Platform Integration:**

.. code-block:: bash

    # Install GCP collection
    ansible-galaxy collection install google.cloud
    
    # Install required Python libraries
    pip3 install requests google-auth

**Testing Ansible Installation:**

.. code-block:: bash

    # Test with localhost
    echo "localhost" > inventory
    ansible localhost -m ping
    
    # Expected output:
    localhost | SUCCESS => {
        "changed": false,
        "ping": "pong"
    }

=======================
Ansible Ad Hoc Commands
=======================

Ad hoc commands are one-time commands you run against your hosts without writing a playbook. They're perfect for quick tasks, troubleshooting, and getting immediate results.

**Ad Hoc Command Syntax:**

.. code-block:: bash

    ansible <host-pattern> -m <module-name> -a "<module-arguments>"
    
    # Basic structure:
    # ansible: The command
    # host-pattern: Which hosts to target
    # -m: Module to use
    # -a: Module arguments

**Basic Ad Hoc Commands**

**1. Connectivity and System Information:**

.. code-block:: bash

    # Test connectivity to all hosts
    ansible all -m ping
    
    # Check uptime on web servers
    ansible web_servers -m command -a "uptime"
    
    # Get system facts (detailed system information)
    ansible all -m setup
    
    # Get specific fact (like IP address)
    ansible all -m setup -a "filter=ansible_default_ipv4"
    
    # Check disk space
    ansible all -m command -a "df -h"
    
    # Check memory usage
    ansible all -m command -a "free -h"
    
    # Get OS information
    ansible all -m setup -a "filter=ansible_distribution*"

**2. Package Management:**

.. code-block:: bash

    # Update package cache (Ubuntu/Debian)
    ansible all -m apt -a "update_cache=yes" --become
    
    # Install a package
    ansible web_servers -m apt -a "name=nginx state=present" --become
    
    # Install multiple packages
    ansible all -m apt -a "name=htop,vim,curl state=present" --become
    
    # Remove a package
    ansible all -m apt -a "name=apache2 state=absent" --become
    
    # Upgrade all packages
    ansible all -m apt -a "upgrade=dist" --become
    
    # Check if a package is installed
    ansible all -m command -a "dpkg -l | grep nginx"

**3. Service Management:**

.. code-block:: bash

    # Start a service
    ansible web_servers -m service -a "name=nginx state=started" --become
    
    # Stop a service
    ansible web_servers -m service -a "name=apache2 state=stopped" --become
    
    # Restart a service
    ansible web_servers -m service -a "name=nginx state=restarted" --become
    
    # Enable service at boot
    ansible web_servers -m service -a "name=nginx enabled=yes" --become
    
    # Check service status
    ansible all -m command -a "systemctl status nginx"
    
    # List all running services
    ansible all -m command -a "systemctl list-units --type=service --state=running"

**4. File Operations:**

.. code-block:: bash

    # Create a directory
    ansible all -m file -a "path=/opt/myapp state=directory mode=0755" --become
    
    # Create a file with content
    ansible all -m copy -a "content='Hello World' dest=/tmp/hello.txt"
    
    # Copy a local file to remote hosts
    ansible all -m copy -a "src=./config.txt dest=/etc/myapp/config.txt backup=yes" --become
    
    # Change file ownership
    ansible all -m file -a "path=/var/www/html owner=www-data group=www-data" --become
    
    # Change file permissions
    ansible all -m file -a "path=/opt/scripts/backup.sh mode=0755"
    
    # Remove a file
    ansible all -m file -a "path=/tmp/oldfile.txt state=absent"
    
    # Create a symbolic link
    ansible all -m file -a "src=/opt/app/current dest=/opt/app/latest state=link"
    
    # Check if file exists
    ansible all -m stat -a "path=/etc/nginx/nginx.conf"

**5. User Management:**

.. code-block:: bash

    # Create a user
    ansible all -m user -a "name=deployuser shell=/bin/bash" --become
    
    # Create user with specific UID and home directory
    ansible all -m user -a "name=appuser uid=1001 home=/opt/appuser createhome=yes" --become
    
    # Add user to sudo group
    ansible all -m user -a "name=deployuser groups=sudo append=yes" --become
    
    # Set user password (encrypted)
    ansible all -m user -a "name=deployuser password={{ 'mypassword' | password_hash('sha512') }}" --become
    
    # Remove a user
    ansible all -m user -a "name=olduser state=absent remove=yes" --become
    
    # Lock a user account
    ansible all -m user -a "name=tempuser password_lock=yes" --become

**6. SSH Key Management:**

.. code-block:: bash

    # Add SSH public key to user
    ansible all -m authorized_key -a "user=ubuntu key='{{ lookup('file', '~/.ssh/id_rsa.pub') }}'"
    
    # Add SSH key from URL
    ansible all -m authorized_key -a "user=deployuser key=https://github.com/username.keys"
    
    # Remove SSH key
    ansible all -m authorized_key -a "user=ubuntu key='ssh-rsa AAAA...' state=absent"

**7. Process Management:**

.. code-block:: bash

    # List running processes
    ansible all -m command -a "ps aux"
    
    # Find processes by name
    ansible all -m command -a "pgrep -f nginx"
    
    # Kill a process by PID
    ansible all -m command -a "kill -9 1234" --become
    
    # Kill processes by name
    ansible all -m command -a "pkill -f 'old-service'" --become

**8. Network Operations:**

.. code-block:: bash

    # Test network connectivity
    ansible all -m command -a "ping -c 4 google.com"
    
    # Check open ports
    ansible all -m command -a "netstat -tlnp"
    
    # Check network interfaces
    ansible all -m command -a "ip addr show"
    
    # Download a file
    ansible all -m get_url -a "url=https://releases.ubuntu.com/22.04/ubuntu-22.04.3-live-server-amd64.iso dest=/tmp/"

**9. System Monitoring and Logs:**

.. code-block:: bash

    # Check system load
    ansible all -m command -a "cat /proc/loadavg"
    
    # View last few lines of log file
    ansible all -m command -a "tail -n 20 /var/log/syslog"
    
    # Check journal logs
    ansible all -m command -a "journalctl -n 10"
    
    # Find large files
    ansible all -m command -a "find /var/log -type f -size +100M"
    
    # Check CPU info
    ansible all -m command -a "cat /proc/cpuinfo | grep 'model name' | head -1"

**10. Archive and Compression:**

.. code-block:: bash

    # Create tar archive
    ansible all -m archive -a "path=/var/www/html dest=/tmp/website-backup.tar.gz"
    
    # Extract archive
    ansible all -m unarchive -a "src=/tmp/backup.tar.gz dest=/opt/ remote_src=yes"
    
    # Download and extract from URL
    ansible all -m unarchive -a "src=https://example.com/app.tar.gz dest=/opt/ remote_src=yes"

**Advanced Ad Hoc Patterns**

**1. Using Variables:**

.. code-block:: bash

    # Use extra variables
    ansible web_servers -m template -a "src=nginx.conf.j2 dest=/etc/nginx/nginx.conf" \
      --extra-vars "server_name=myapp.com worker_processes=4" --become
    
    # Use variables from file
    ansible all -m debug -a "var=ansible_hostname" --extra-vars "@vars.yml"

**2. Conditional Execution:**

.. code-block:: bash

    # Run only on Ubuntu systems
    ansible all -m apt -a "name=htop state=present" \
      --limit "ansible_distribution=='Ubuntu'" --become
    
    # Run on specific hosts
    ansible web_servers[0] -m service -a "name=nginx state=restarted" --become

**3. Parallel Execution:**

.. code-block:: bash

    # Run on 10 hosts in parallel (default is 5)
    ansible all -m ping -f 10
    
    # Run with increased timeout
    ansible all -m command -a "sleep 30" -T 60

**4. Output Formatting:**

.. code-block:: bash

    # One line output
    ansible all -m ping --one-line
    
    # Tree format output
    ansible all -m setup --tree /tmp/facts
    
    # JSON output
    ansible all -m setup | jq '.'

**5. Dry Run and Check Mode:**

.. code-block:: bash

    # Check what would change (dry run)
    ansible all -m apt -a "name=nginx state=present" --check --become
    
    # Show differences
    ansible all -m copy -a "src=config.txt dest=/etc/app/config.txt" --check --diff --become

**Practical Ad Hoc Workflows**

**Quick Server Health Check:**

.. code-block:: bash

    #!/bin/bash
    # health_check.sh - Quick server health assessment
    
    echo "=== Connectivity Check ==="
    ansible all -m ping --one-line
    
    echo -e "\n=== Disk Space ==="
    ansible all -m command -a "df -h /" --one-line
    
    echo -e "\n=== Memory Usage ==="
    ansible all -m command -a "free -h" --one-line
    
    echo -e "\n=== Load Average ==="
    ansible all -m command -a "uptime" --one-line
    
    echo -e "\n=== Service Status ==="
    ansible web_servers -m command -a "systemctl is-active nginx" --one-line

**Emergency Response Commands:**

.. code-block:: bash

    # Stop all web services immediately
    ansible web_servers -m service -a "name=nginx state=stopped" --become -f 20
    
    # Clear cache across all servers
    ansible all -m command -a "sync && echo 3 > /proc/sys/vm/drop_caches" --become
    
    # Restart all application servers
    ansible app_servers -m service -a "name=myapp state=restarted" --become
    
    # Check for security updates
    ansible all -m command -a "apt list --upgradable | grep -i security" --become

**Log Collection:**

.. code-block:: bash

    # Collect error logs from all servers
    ansible all -m fetch -a "src=/var/log/nginx/error.log dest=/tmp/logs/{{ inventory_hostname }}/ flat=yes"
    
    # Search for errors in logs
    ansible all -m command -a "grep -i error /var/log/syslog | tail -10"
    
    # Check log file sizes
    ansible all -m command -a "du -sh /var/log/*" --one-line

**Troubleshooting Ad Hoc Commands**

**Common Issues and Solutions:**

.. code-block:: bash

    # SSH connection issues
    ansible all -m ping -vvv  # Verbose output for debugging
    
    # Permission issues
    ansible all -m command -a "whoami"  # Check current user
    ansible all -m command -a "sudo whoami" --become  # Check sudo access
    
    # Python issues
    ansible all -m command -a "which python3"  # Check Python location
    
    # Module not found
    ansible all -m setup -a "filter=ansible_python*"  # Check Python interpreter

.. note::

    Ad hoc commands are powerful for immediate tasks, but for complex operations or repeated tasks, consider writing playbooks. They provide better documentation, error handling, and reusability.

.. note::

    The examples in this section assume you have infrastructure provisioned by Terraform from the previous chapters. If you haven't completed the Terraform chapters, you can still follow along by manually creating GCP compute instances for practice.

**Next Steps:**

Continue to **Chapter 10.7: Ansible Core Concepts** to start writing your first playbooks and learn essential Ansible patterns for configuration management.
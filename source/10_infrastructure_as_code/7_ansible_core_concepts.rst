##########################
10.7 Ansible Core Concepts
##########################

===================
Learning Objectives
===================

By the end of this chapter, you will be able to:

• **Create** and manage Ansible inventory files for different environments
• **Write** structured Ansible playbooks using proper YAML syntax and conventions
• **Use** Ansible modules effectively for common system administration tasks
• **Implement** variables, facts, and templating for dynamic configurations
• **Apply** conditionals and loops for flexible automation logic
• **Handle** errors and implement proper task flow control
• **Debug** playbooks and troubleshoot common execution issues
• **Organize** playbooks and tasks for maintainability and reusability

**Prerequisites:** Ansible installed and basic understanding of YAML syntax. Access to Google Cloud Platform for hands-on examples.

**Practical Focus:** This chapter provides hands-on experience with Ansible fundamentals using real Google Cloud Platform infrastructure.

============================
Ansible Inventory Management
============================

Inventory is how Ansible knows which machines to manage and how to connect to them. It defines your infrastructure in a structured way that Ansible can understand and act upon.

**Static Inventory Formats**

**INI Format (Traditional):**

.. code-block:: ini

    # inventory/production.ini
    
    # Web servers in production
    [web_servers]
    web1.example.com ansible_host=34.123.45.67
    web2.example.com ansible_host=34.123.45.68
    web3.example.com ansible_host=34.123.45.69
    
    # Database servers
    [databases]
    db1.example.com ansible_host=34.123.45.70 ansible_port=2222
    db2.example.com ansible_host=34.123.45.71
    
    # Load balancers
    [load_balancers]
    lb1.example.com ansible_host=34.123.45.72
    
    # Group of groups
    [production:children]
    web_servers
    databases
    load_balancers
    
    # Variables for all production hosts
    [production:vars]
    ansible_user=ubuntu
    ansible_ssh_private_key_file=~/.ssh/gcp-key
    environment=production

**YAML Format (Modern):**

.. code-block:: yaml

    # inventory/production.yml
    all:
      children:
        production:
          children:
            web_servers:
              hosts:
                web1.example.com:
                  ansible_host: 34.123.45.67
                web2.example.com:
                  ansible_host: 34.123.45.68
                web3.example.com:
                  ansible_host: 34.123.45.69
              vars:
                nginx_port: 80
                app_version: "1.2.3"
            
            databases:
              hosts:
                db1.example.com:
                  ansible_host: 34.123.45.70
                  ansible_port: 2222
                db2.example.com:
                  ansible_host: 34.123.45.71
              vars:
                mysql_port: 3306
                backup_enabled: true
            
            load_balancers:
              hosts:
                lb1.example.com:
                  ansible_host: 34.123.45.72
          
          vars:
            ansible_user: ubuntu
            ansible_ssh_private_key_file: ~/.ssh/gcp-key
            environment: production
            region: us-central1

**Dynamic Inventory for Google Cloud Platform**

For cloud environments, dynamic inventory automatically discovers and manages your infrastructure:

.. code-block:: yaml

    # inventory/gcp.yml (dynamic inventory)
    plugin: google.cloud.gcp_compute
    projects:
      - my-project-id
    regions:
      - us-central1
      - us-east1
    auth_kind: serviceaccount
    service_account_file: ~/.gcp/service-account.json
    
    # Group instances by labels
    groups:
      web_servers: "'web-server' in (labels.role | default(''))"
      databases: "'database' in (labels.role | default(''))"
      production: "'production' in (labels.env | default(''))"
      staging: "'staging' in (labels.env | default(''))"
    
    # Compose variables from instance metadata
    compose:
      ansible_host: networkInterfaces[0].accessConfigs[0].natIP | default(networkInterfaces[0].networkIP)
      instance_type: machineType.split('/')[-1]
      environment: labels.env | default('unknown')

**Testing Inventory:**

.. code-block:: bash

    # List all hosts
    ansible-inventory --list
    
    # List hosts in specific group
    ansible-inventory --list --group web_servers
    
    # Test connectivity
    ansible all -m ping
    ansible web_servers -m ping -i inventory/production.yml

==============================
Playbook Structure and Syntax
==============================

Playbooks are Ansible's configuration, deployment, and orchestration language. They describe the desired state of your systems in a human-readable YAML format.

**Basic Playbook Structure:**

.. code-block:: yaml

    ---
    # Basic playbook structure
    - name: Configure web servers
      hosts: web_servers
      become: true
      gather_facts: true
      
      vars:
        nginx_port: 80
        app_name: "my-web-app"
      
      tasks:
        - name: Update package cache
          apt:
            update_cache: yes
            cache_valid_time: 3600
        
        - name: Install required packages
          apt:
            name:
              - nginx
              - git
              - curl
              - vim
            state: present
        
        - name: Start and enable Nginx
          systemd:
            name: nginx
            state: started
            enabled: yes
        
        - name: Copy website files
          copy:
            src: ./website/
            dest: /var/www/html/
            owner: www-data
            group: www-data
            mode: '0644'
          notify: restart nginx
      
      handlers:
        - name: restart nginx
          systemd:
            name: nginx
            state: restarted

**Playbook Components Explained:**

1. **Play Definition**
   
   .. code-block:: yaml
   
       - name: Configure web servers    # Descriptive name
         hosts: web_servers             # Target hosts/groups
         become: true                   # Use sudo/privilege escalation
         gather_facts: true             # Collect system information

2. **Variables Section**
   
   .. code-block:: yaml
   
       vars:
         nginx_port: 80
         app_name: "my-web-app"
         packages:
           - nginx
           - git
           - curl

3. **Tasks Section**
   
   .. code-block:: yaml
   
       tasks:
         - name: Install packages       # Always provide descriptive names
           apt:                         # Module name
             name: "{{ packages }}"     # Module parameters
             state: present
           tags:                        # Optional tags for selective execution
             - packages
             - installation

4. **Handlers Section**
   
   .. code-block:: yaml
   
       handlers:
         - name: restart nginx         # Triggered by notify directive
           systemd:
             name: nginx
             state: restarted

**Multi-Play Playbooks:**

.. code-block:: yaml

    ---
    # Configure database servers first
    - name: Configure database servers
      hosts: databases
      become: true
      
      tasks:
        - name: Install MySQL
          apt:
            name: mysql-server
            state: present
        
        - name: Start MySQL service
          systemd:
            name: mysql
            state: started
            enabled: yes
    
    # Then configure web servers
    - name: Configure web servers
      hosts: web_servers
      become: true
      
      tasks:
        - name: Install Nginx
          apt:
            name: nginx
            state: present
        
        - name: Configure Nginx
          template:
            src: nginx.conf.j2
            dest: /etc/nginx/nginx.conf
          notify: restart nginx
      
      handlers:
        - name: restart nginx
          systemd:
            name: nginx
            state: restarted

=========================
Essential Ansible Modules
=========================

Modules are the building blocks of Ansible automation. Each module performs a specific task and returns structured data about what it did.

**System Modules:**

.. code-block:: yaml

    # Package management
    - name: Install packages (Ubuntu/Debian)
      apt:
        name: "{{ item }}"
        state: present
        update_cache: yes
      loop:
        - nginx
        - git
        - curl
    
    # Service management
    - name: Manage system services
      systemd:
        name: "{{ service_name }}"
        state: started
        enabled: yes
        daemon_reload: yes
    
    # User management
    - name: Create application user
      user:
        name: appuser
        system: yes
        shell: /bin/bash
        home: /var/www
        create_home: yes

**File and Directory Management:**

.. code-block:: yaml

    # Create directories
    - name: Create application directories
      file:
        path: "{{ item }}"
        state: directory
        owner: www-data
        group: www-data
        mode: '0755'
      loop:
        - /var/www/html
        - /var/www/logs
        - /var/www/config
    
    # Copy files
    - name: Copy static files
      copy:
        src: "{{ item.src }}"
        dest: "{{ item.dest }}"
        owner: www-data
        group: www-data
        mode: "{{ item.mode }}"
      loop:
        - { src: "./files/index.html", dest: "/var/www/html/", mode: "0644" }
        - { src: "./files/app.js", dest: "/var/www/html/", mode: "0644" }
    
    # Use templates for dynamic content
    - name: Generate configuration files
      template:
        src: nginx.conf.j2
        dest: /etc/nginx/sites-available/default
        backup: yes
      notify: restart nginx

**Command and Shell Modules:**

.. code-block:: yaml

    # Run shell commands (when no specific module exists)
    - name: Download and install custom software
      shell: |
        wget https://example.com/software.tar.gz -O /tmp/software.tar.gz
        tar -xzf /tmp/software.tar.gz -C /opt/
        /opt/software/install.sh
      args:
        creates: /opt/software/bin/app
        warn: false
    
    # Execute commands with specific environment
    - name: Run application setup
      command: /var/www/setup.py --initialize
      environment:
        PATH: "/var/www/venv/bin:{{ ansible_env.PATH }}"
        DATABASE_URL: "{{ database_connection_string }}"
      become_user: appuser
      register: setup_result
    
    # Check command output
    - name: Display setup results
      debug:
        var: setup_result.stdout_lines
      when: setup_result.changed

**Google Cloud Platform Modules:**

.. code-block:: yaml

    # Manage GCP compute instances
    - name: Create GCP compute instance
      google.cloud.gcp_compute_instance:
        name: web-server-01
        machine_type: e2-standard-2
        zone: us-central1-a
        project: "{{ gcp_project }}"
        auth_kind: serviceaccount
        service_account_file: "{{ gcp_service_account_file }}"
        
        disks:
          - auto_delete: true
            boot: true
            initialize_params:
              source_image: projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts
              disk_size_gb: 20
        
        network_interfaces:
          - network: "{{ gcp_network }}"
            access_configs:
              - name: External NAT
                type: ONE_TO_ONE_NAT
        
        tags:
          items:
            - web-server
            - production
        
        state: present
    
    # Manage firewall rules
    - name: Allow HTTP traffic
      google.cloud.gcp_compute_firewall:
        name: allow-http
        network: "{{ gcp_network }}"
        project: "{{ gcp_project }}"
        auth_kind: serviceaccount
        service_account_file: "{{ gcp_service_account_file }}"
        
        allowed:
          - ip_protocol: tcp
            ports:
              - '80'
              - '443'
        
        source_ranges:
          - 0.0.0.0/0
        
        target_tags:
          - web-server
        
        state: present

========================
Variables and Templating
========================

Variables make your playbooks flexible and reusable across different environments and configurations.

**Variable Precedence (highest to lowest):**

1. Command line values (ansible-playbook -e "var=value")
2. Role vars
3. Inventory file or script group vars
4. Inventory group_vars/*
5. Playbook group_vars/*
6. Inventory file or script host vars
7. Inventory host_vars/*
8. Playbook host_vars/*
9. Host facts / cached facts
10. Play vars
11. Play vars_prompt
12. Play vars_files
13. Role defaults
14. Inventory file or script default vars

**Variable Definition Examples:**

.. code-block:: yaml

    # In playbook
    - name: Deploy application
      hosts: web_servers
      vars:
        app_name: "my-web-app"
        app_version: "1.2.3"
        app_port: 8080
        
        # Complex variables
        database_config:
          host: "{{ hostvars['db1.example.com']['ansible_default_ipv4']['address'] }}"
          port: 3306
          name: "{{ app_name }}_production"
          
        # List variables
        required_packages:
          - nginx
          - python3
          - python3-pip
          - git

**Variable Files:**

.. code-block:: yaml

    # group_vars/web_servers.yml
    nginx_worker_processes: 4
    nginx_worker_connections: 1024
    nginx_keepalive_timeout: 65
    
    ssl_certificate_email: admin@example.com
    ssl_certificate_domains:
      - example.com
      - www.example.com
    
    # Environment-specific variables
    database_url: "postgresql://user:pass@db1.example.com:5432/myapp"
    redis_url: "redis://cache1.example.com:6379/0"
    secret_key: "{{ vault_secret_key }}"

**Jinja2 Templates:**

Templates allow you to create dynamic configuration files:

.. code-block:: jinja

    {# templates/nginx.conf.j2 #}
    user www-data;
    worker_processes {{ nginx_worker_processes }};
    pid /run/nginx.pid;
    
    events {
        worker_connections {{ nginx_worker_connections }};
        use epoll;
        multi_accept on;
    }
    
    http {
        include /etc/nginx/mime.types;
        default_type application/octet-stream;
        
        # Logging
        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;
        
        # Gzip compression
        gzip on;
        gzip_vary on;
        gzip_types text/plain text/css application/json application/javascript;
        
        # Virtual hosts
        {% for domain in ssl_certificate_domains %}
        server {
            listen 80;
            server_name {{ domain }};
            
            location / {
                proxy_pass http://127.0.0.1:{{ app_port }};
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;
            }
        }
        {% endfor %}
    }

**Using Templates in Playbooks:**

.. code-block:: yaml

    - name: Generate Nginx configuration
      template:
        src: nginx.conf.j2
        dest: /etc/nginx/nginx.conf
        owner: root
        group: root
        mode: '0644'
        backup: yes
      notify: restart nginx
      
    - name: Generate application configuration
      template:
        src: app_config.py.j2
        dest: /var/www/{{ app_name }}/config.py
        owner: www-data
        group: www-data
        mode: '0600'
      notify: restart application

======================
Conditionals and Loops
======================

Conditionals and loops make your playbooks dynamic and able to handle different scenarios and data structures.

**Conditionals:**

.. code-block:: yaml

    # Simple conditionals
    - name: Install Apache (RedHat family)
      yum:
        name: httpd
        state: present
      when: ansible_os_family == "RedHat"
    
    - name: Install Apache (Debian family)
      apt:
        name: apache2
        state: present
      when: ansible_os_family == "Debian"
    
    # Complex conditionals
    - name: Configure SSL
      template:
        src: ssl.conf.j2
        dest: /etc/nginx/ssl.conf
      when:
        - ssl_enabled | default(false)
        - ssl_certificate_path is defined
        - environment == "production"
    
    # Conditional based on command output
    - name: Check if application is installed
      command: which myapp
      register: app_check
      ignore_errors: yes
      changed_when: false
    
    - name: Install application
      shell: curl -sSL https://install.myapp.com | bash
      when: app_check.rc != 0

**Loops:**

.. code-block:: yaml

    # Simple loops
    - name: Install multiple packages
      apt:
        name: "{{ item }}"
        state: present
      loop:
        - nginx
        - git
        - curl
        - vim
    
    # Loop with dictionaries
    - name: Create multiple users
      user:
        name: "{{ item.name }}"
        groups: "{{ item.groups }}"
        shell: "{{ item.shell }}"
        state: present
      loop:
        - { name: "alice", groups: "sudo,developers", shell: "/bin/bash" }
        - { name: "bob", groups: "developers", shell: "/bin/zsh" }
        - { name: "charlie", groups: "operators", shell: "/bin/bash" }
    
    # Loop with conditionals
    - name: Install development tools
      apt:
        name: "{{ item }}"
        state: present
      loop:
        - nodejs
        - npm
        - python3-dev
        - build-essential
      when: 
        - install_dev_tools | default(false)
        - ansible_distribution == "Ubuntu"
    
    # Loop with complex data structures
    - name: Configure virtual hosts
      template:
        src: vhost.conf.j2
        dest: "/etc/nginx/sites-available/{{ item.name }}"
      loop: "{{ virtual_hosts }}"
      notify: restart nginx
      when: item.enabled | default(true)

**Advanced Loop Control:**

.. code-block:: yaml

    # Loop with index
    - name: Create numbered backup directories
      file:
        path: "/backup/daily-{{ ansible_loop.index }}"
        state: directory
      loop: "{{ range(1, 8) | list }}"
    
    # Loop until condition is met
    - name: Wait for service to be ready
      uri:
        url: "http://{{ inventory_hostname }}:8080/health"
        method: GET
      register: health_check
      until: health_check.status == 200
      retries: 10
      delay: 5
    
    # Loop with variable registration
    - name: Check disk usage on multiple mounts
      shell: "df -h {{ item }}"
      register: disk_usage
      loop:
        - /
        - /var
        - /tmp
    
    - name: Display disk usage results
      debug:
        msg: "{{ item.stdout }}"
      loop: "{{ disk_usage.results }}"

===============================
Error Handling and Task Control
===============================

Proper error handling ensures your playbooks are robust and provide meaningful feedback when things go wrong.

**Basic Error Handling:**

.. code-block:: yaml

    # Ignore errors for specific tasks
    - name: Try to install optional package
      apt:
        name: some-optional-package
        state: present
      ignore_errors: yes
    
    # Register task results for checking
    - name: Download application archive
      get_url:
        url: "https://releases.example.com/app-{{ app_version }}.tar.gz"
        dest: "/tmp/app-{{ app_version }}.tar.gz"
      register: download_result
      
    - name: Fail if download was unsuccessful
      fail:
        msg: "Failed to download application archive"
      when: download_result is failed
    
    # Continue on failure but register the error
    - name: Attempt service restart
      systemd:
        name: "{{ service_name }}"
        state: restarted
      register: restart_result
      failed_when: false
    
    - name: Handle restart failure
      debug:
        msg: "Service restart failed: {{ restart_result.msg }}"
      when: restart_result is failed

**Block and Rescue:**

.. code-block:: yaml

    # Handle errors with blocks
    - name: Deploy application with error handling
      block:
        - name: Stop application service
          systemd:
            name: myapp
            state: stopped
        
        - name: Backup current version
          command: "cp -r /var/www/myapp /var/www/myapp.backup.{{ ansible_date_time.epoch }}"
        
        - name: Deploy new version
          unarchive:
            src: "/tmp/app-{{ app_version }}.tar.gz"
            dest: /var/www/myapp
            remote_src: yes
        
        - name: Start application service
          systemd:
            name: myapp
            state: started
            
      rescue:
        - name: Restore previous version on failure
          command: "cp -r /var/www/myapp.backup.{{ ansible_date_time.epoch }} /var/www/myapp"
          
        - name: Restart application with old version
          systemd:
            name: myapp
            state: started
            
        - name: Notify about deployment failure
          mail:
            to: ops-team@example.com
            subject: "Deployment failed on {{ inventory_hostname }}"
            body: "Application deployment failed and was rolled back"
            
      always:
        - name: Clean up temporary files
          file:
            path: "/tmp/app-{{ app_version }}.tar.gz"
            state: absent

**Custom Failure Conditions:**

.. code-block:: yaml

    # Define custom failure conditions
    - name: Check application health
      uri:
        url: "http://{{ inventory_hostname }}:8080/health"
        method: GET
      register: health_response
      failed_when: 
        - health_response.status != 200
        - "'healthy' not in health_response.json.status"
    
    # Define when task should be considered changed
    - name: Update configuration file
      lineinfile:
        path: /etc/myapp/config.ini
        line: "environment={{ environment }}"
        regexp: "^environment="
      register: config_update
      changed_when: "'line replaced' in config_update.msg"

=========================
Debugging and Development
=========================

Effective debugging techniques help you develop and troubleshoot playbooks efficiently.

**Debug Module:**

.. code-block:: yaml

    # Display variable values
    - name: Debug variables
      debug:
        msg: |
          App Name: {{ app_name }}
          App Version: {{ app_version }}
          Environment: {{ environment }}
          Database URL: {{ database_url }}
    
    # Display complex data structures
    - name: Show all network interfaces
      debug:
        var: ansible_interfaces
        
    - name: Show specific interface details
      debug:
        var: ansible_default_ipv4
    
    # Conditional debugging
    - name: Debug only in development
      debug:
        msg: "Development mode enabled - extra logging active"
      when: environment == "development"

**Verbosity Control:**

.. code-block:: bash

    # Run playbook with different verbosity levels
    ansible-playbook site.yml                    # Standard output
    ansible-playbook site.yml -v                # Verbose
    ansible-playbook site.yml -vv               # More verbose
    ansible-playbook site.yml -vvv              # Debug
    ansible-playbook site.yml -vvvv             # Connection debug

**Check Mode (Dry Run):**

.. code-block:: bash

    # Preview changes without making them
    ansible-playbook site.yml --check
    
    # Show differences for template and file operations
    ansible-playbook site.yml --check --diff
    
    # Run specific tasks in check mode
    ansible-playbook site.yml --check --tags "configuration"

**Step Mode:**

.. code-block:: bash

    # Execute playbook step by step
    ansible-playbook site.yml --step

**Limiting Execution:**

.. code-block:: bash

    # Run only on specific hosts
    ansible-playbook site.yml --limit "web_servers"
    ansible-playbook site.yml --limit "web1.example.com,web2.example.com"
    
    # Skip specific hosts
    ansible-playbook site.yml --limit "all:!databases"
    
    # Run specific tags
    ansible-playbook site.yml --tags "installation,configuration"
    ansible-playbook site.yml --skip-tags "database"


.. note::

    The concepts in this chapter form the foundation for all Ansible automation. Practice with simple examples before moving to more complex scenarios in the following chapters.
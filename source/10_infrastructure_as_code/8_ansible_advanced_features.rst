##############################
10.8 Ansible Advanced Features
##############################

===================
Learning Objectives
===================

By the end of this chapter, you will be able to:

• **Design** and implement Ansible roles for modular and reusable automation
• **Organize** complex playbooks using role dependencies and inheritance
• **Secure** sensitive data using Ansible Vault for production environments
• **Master** advanced Jinja2 templating with filters, tests, and custom functions
• **Implement** dynamic inventories and advanced host targeting strategies
• **Optimize** playbook performance with parallel execution and caching
• **Integrate** Ansible with external systems and APIs
• **Apply** advanced error handling and workflow control patterns
• **Create** custom modules and plugins for specialized requirements

**Prerequisites:** Solid understanding of Ansible core concepts from Chapter 10.7, including inventory, playbooks, variables, and basic modules.

**Advanced Focus:** This chapter covers production-ready Ansible patterns and advanced techniques used in enterprise environments.

=================================
Ansible Roles: Modular Automation
=================================

Roles are Ansible's way of organizing and reusing automation code. They provide a structured approach to breaking down complex playbooks into manageable, reusable components.

**Role Directory Structure:**

.. code-block:: text

    roles/
    └── webserver/
        ├── tasks/
        │   ├── main.yml           # Main task list for the role
        │   ├── install.yml        # Package installation tasks
        │   ├── configure.yml      # Configuration tasks
        │   └── security.yml       # Security hardening tasks
        ├── handlers/
        │   └── main.yml           # Event handlers (restarts, reloads)
        ├── templates/
        │   ├── nginx.conf.j2      # Jinja2 configuration templates
        │   ├── ssl.conf.j2        # SSL configuration template
        │   └── logrotate.j2       # Log rotation configuration
        ├── files/
        │   ├── index.html         # Static files to copy
        │   └── ssl-cert.pem       # SSL certificates
        ├── vars/
        │   └── main.yml           # Role-specific variables
        ├── defaults/
        │   └── main.yml           # Default variables (lowest precedence)
        ├── meta/
        │   └── main.yml           # Role metadata and dependencies
        └── README.md              # Role documentation

**Creating a Web Server Role:**

**tasks/main.yml** - Main task orchestration:

.. code-block:: yaml

    ---
    # Main task file for webserver role
    - name: Include OS-specific variables
      include_vars: "{{ ansible_os_family }}.yml"
      tags: [always]
    
    # Include task files in logical order
    - name: Install web server packages
      include_tasks: install.yml
      tags: [installation, packages]
    
    - name: Configure web server
      include_tasks: configure.yml
      tags: [configuration]
    
    - name: Apply security hardening
      include_tasks: security.yml
      tags: [security, hardening]
      when: apply_security_hardening | default(true)
    
    - name: Verify web server is running
      include_tasks: verify.yml
      tags: [verification]

**tasks/install.yml** - Package installation:

.. code-block:: yaml

    ---
    - name: Update package cache (Debian/Ubuntu)
      apt:
        update_cache: yes
        cache_valid_time: 3600
      when: ansible_os_family == "Debian"
    
    - name: Install web server and dependencies
      package:
        name: "{{ webserver_packages }}"
        state: present
    
    - name: Install additional packages
      package:
        name: "{{ item }}"
        state: present
      loop: "{{ additional_packages | default([]) }}"
      when: additional_packages is defined
    
    - name: Create web server user
      user:
        name: "{{ webserver_user }}"
        system: yes
        shell: /bin/false
        home: "{{ webserver_home }}"
        create_home: no
      when: create_webserver_user | default(true)

**tasks/configure.yml** - Configuration management:

.. code-block:: yaml

    ---
    - name: Create web server directories
      file:
        path: "{{ item }}"
        state: directory
        owner: "{{ webserver_user }}"
        group: "{{ webserver_group }}"
        mode: '0755'
      loop:
        - "{{ webserver_document_root }}"
        - "{{ webserver_log_dir }}"
        - "{{ webserver_config_dir }}/sites-available"
        - "{{ webserver_config_dir }}/sites-enabled"
    
    - name: Generate main configuration file
      template:
        src: "{{ webserver_main_config_template }}"
        dest: "{{ webserver_config_dir }}/{{ webserver_main_config_file }}"
        owner: root
        group: root
        mode: '0644'
        backup: yes
      notify: restart webserver
    
    - name: Configure virtual hosts
      template:
        src: vhost.conf.j2
        dest: "{{ webserver_config_dir }}/sites-available/{{ item.name }}"
        owner: root
        group: root
        mode: '0644'
      loop: "{{ virtual_hosts | default([]) }}"
      notify: restart webserver
    
    - name: Enable virtual hosts
      file:
        src: "{{ webserver_config_dir }}/sites-available/{{ item.name }}"
        dest: "{{ webserver_config_dir }}/sites-enabled/{{ item.name }}"
        state: link
      loop: "{{ virtual_hosts | default([]) }}"
      when: item.enabled | default(true)
      notify: restart webserver
    
    - name: Remove default site
      file:
        path: "{{ webserver_config_dir }}/sites-enabled/default"
        state: absent
      notify: restart webserver
      when: remove_default_site | default(true)

**defaults/main.yml** - Default variables:

.. code-block:: yaml

    ---
    # Web server package and service names
    webserver_packages:
      - nginx
      - nginx-common
    
    webserver_service: nginx
    webserver_user: www-data
    webserver_group: www-data
    
    # Paths and directories
    webserver_config_dir: /etc/nginx
    webserver_document_root: /var/www/html
    webserver_log_dir: /var/log/nginx
    webserver_home: /var/www
    
    # Configuration files
    webserver_main_config_file: nginx.conf
    webserver_main_config_template: nginx.conf.j2
    
    # Default settings
    nginx_worker_processes: auto
    nginx_worker_connections: 1024
    nginx_keepalive_timeout: 65
    nginx_client_max_body_size: 64m
    
    # Security settings
    apply_security_hardening: true
    remove_default_site: true
    create_webserver_user: false  # User usually exists
    
    # SSL/TLS settings
    ssl_protocols: "TLSv1.2 TLSv1.3"
    ssl_ciphers: "ECDHE+AESGCM:ECDHE+AES256:ECDHE+AES128:!aNULL:!MD5:!DSS"
    ssl_prefer_server_ciphers: "off"

**handlers/main.yml** - Event handlers:

.. code-block:: yaml

    ---
    - name: restart webserver
      systemd:
        name: "{{ webserver_service }}"
        state: restarted
        daemon_reload: yes
      listen: restart webserver
    
    - name: reload webserver
      systemd:
        name: "{{ webserver_service }}"
        state: reloaded
      listen: reload webserver
    
    - name: restart webserver
      systemd:
        name: "{{ webserver_service }}"
        state: restarted
    
    - name: reload webserver
      systemd:
        name: "{{ webserver_service }}"
        state: reloaded

**Using Roles in Playbooks:**

.. code-block:: yaml

    ---
    - name: Configure web infrastructure
      hosts: web_servers
      become: true
      
      vars:
        virtual_hosts:
          - name: example.com
            document_root: /var/www/example.com
            enabled: true
          - name: api.example.com
            document_root: /var/www/api
            enabled: true
        
        additional_packages:
          - curl
          - htop
          - vim
      
      roles:
        - role: common
          tags: [common, base]
        
        - role: security
          tags: [security]
          
        - role: webserver
          tags: [webserver, nginx]
          nginx_worker_processes: 4
          apply_security_hardening: true
        
        - role: monitoring
          tags: [monitoring]
          when: environment == "production"

**Role Dependencies:**

**meta/main.yml** - Define role dependencies:

.. code-block:: yaml

    ---
    dependencies:
      - role: common
        vars:
          install_development_tools: false
      
      - role: security
        vars:
          configure_firewall: true
          ssh_hardening: true
        when: apply_security_hardening | default(true)
      
      - role: ssl-certificates
        vars:
          ssl_domains: "{{ virtual_hosts | map(attribute='name') | list }}"
        when: enable_ssl | default(false)
    
    galaxy_info:
      role_name: webserver
      author: DevOps Team
      description: Configures Nginx web server with security hardening
      company: Example Corp
      license: MIT
      min_ansible_version: 2.9
      
      platforms:
        - name: Ubuntu
          versions:
            - focal
            - jammy
        - name: Debian
          versions:
            - buster
            - bullseye
      
      galaxy_tags:
        - webserver
        - nginx
        - security
        - ssl

==================================
Ansible Vault: Secrets Management
==================================

Ansible Vault provides encryption for sensitive data like passwords, API keys, and certificates, allowing you to store secrets safely in version control.

**Creating Vault Files:**

.. code-block:: bash

    # Create a new encrypted file
    ansible-vault create secrets.yml
    
    # Create encrypted variable file for production
    ansible-vault create group_vars/production/vault.yml
    
    # Encrypt existing file
    ansible-vault encrypt existing-secrets.yml
    
    # Edit encrypted file
    ansible-vault edit secrets.yml

**Vault File Content:**

.. code-block:: yaml

    # group_vars/production/vault.yml (encrypted)
    ---
    vault_database_password: "super_secret_db_password_123"
    vault_api_key: "sk-1234567890abcdef..."
    vault_ssl_private_key: |
      -----BEGIN PRIVATE KEY-----
      MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDXyZ...
      -----END PRIVATE KEY-----
    
    vault_oauth_credentials:
      client_id: "oauth_client_123"
      client_secret: "oauth_secret_xyz789"
      
    vault_smtp_credentials:
      username: "notification@example.com"
      password: "smtp_password_456"

**Using Vault Variables:**

.. code-block:: yaml

    # group_vars/production/vars.yml (unencrypted)
    ---
    database_host: "db.production.example.com"
    database_port: 5432
    database_name: "myapp_production"
    database_user: "myapp_user"
    database_password: "{{ vault_database_password }}"
    
    api_key: "{{ vault_api_key }}"
    ssl_private_key: "{{ vault_ssl_private_key }}"
    
    oauth_config: "{{ vault_oauth_credentials }}"
    smtp_config: "{{ vault_smtp_credentials }}"

**Running Playbooks with Vault:**

.. code-block:: bash

    # Prompt for vault password
    ansible-playbook site.yml --ask-vault-pass
    
    # Use password file
    ansible-playbook site.yml --vault-password-file ~/.ansible/vault-pass
    
    # Use multiple vault passwords
    ansible-playbook site.yml --vault-id prod@~/.ansible/vault-prod-pass --vault-id stage@~/.ansible/vault-stage-pass
    
    # Environment variable for password
    export ANSIBLE_VAULT_PASSWORD_FILE=~/.ansible/vault-pass
    ansible-playbook site.yml

**Vault Best Practices:**

.. code-block:: yaml

    # Separate encrypted and unencrypted variables
    # group_vars/production/
    # ├── vars.yml          # Unencrypted variables
    # └── vault.yml         # Encrypted secrets (prefixed with vault_)
    
    # Use consistent naming convention
    database_password: "{{ vault_database_password }}"
    api_secret: "{{ vault_api_secret }}"
    ssl_key: "{{ vault_ssl_key }}"
    
    # Template usage with vault variables
    - name: Generate application configuration
      template:
        src: app_config.py.j2
        dest: /var/www/app/config.py
        mode: '0600'
      vars:
        db_connection_string: "postgresql://{{ database_user }}:{{ vault_database_password }}@{{ database_host }}/{{ database_name }}"

**Vault ID Management:**

.. code-block:: bash

    # Create separate vaults for different purposes
    ansible-vault create --vault-id database@prompt database_secrets.yml
    ansible-vault create --vault-id api@prompt api_secrets.yml
    
    # Use in playbooks
    ansible-playbook deploy.yml --vault-id database@~/.vault/db-pass --vault-id api@~/.vault/api-pass

==========================
Advanced Jinja2 Templating
==========================

Jinja2 is the templating engine used by Ansible for generating dynamic content. Advanced templating techniques enable sophisticated configuration management.

**Template Filters:**

.. code-block:: jinja

    {# templates/nginx.conf.j2 #}
    
    # String manipulation
    server_name {{ domain_name | lower }};
    root {{ document_root | default('/var/www/html') }};
    
    # List operations
    {% for upstream in backend_servers | list %}
    server {{ upstream.host }}:{{ upstream.port }} weight={{ upstream.weight | default(1) }};
    {% endfor %}
    
    # Dictionary operations
    {% for key, value in ssl_config | dictsort %}
    {{ key }} {{ value }};
    {% endfor %}
    
    # Numeric operations
    worker_connections {{ (ansible_processor_vcpus * 1024) | int }};
    client_max_body_size {{ max_upload_size | filesizeformat }};
    
    # Date and time
    # Generated on {{ ansible_date_time.iso8601 }}
    # Expires: {{ (ansible_date_time.epoch | int + 86400) | strftime('%a, %d %b %Y %H:%M:%S GMT') }}
    
    # JSON operations
    {% set config_json = app_config | to_nice_json %}
    var appConfig = {{ config_json }};
    
    # URL operations
    proxy_pass {{ backend_url | urlencode }};
    
    # Regular expressions
    {% if server_name | regex_match('^www\.') %}
    # WWW subdomain configuration
    {% endif %}

**Advanced Template Logic:**

.. code-block:: jinja

    {# Complex conditional logic #}
    {% if ssl_enabled and environment == 'production' %}
        {% set ssl_config = production_ssl_config %}
    {% elif ssl_enabled and environment == 'staging' %}
        {% set ssl_config = staging_ssl_config %}
    {% else %}
        {% set ssl_config = {} %}
    {% endif %}
    
    # SSL Configuration
    {% for directive, value in ssl_config.items() %}
    {{ directive }} {{ value }};
    {% endfor %}
    
    {# Loop controls and variables #}
    upstream backend {
        {% for server in backend_servers %}
            {% if loop.index0 == 0 %}
        # Primary server
            {% endif %}
        server {{ server.host }}:{{ server.port }}{% if server.backup | default(false) %} backup{% endif %};
            {% if loop.last %}
        # Total servers: {{ loop.length }}
            {% endif %}
        {% endfor %}
    }
    
    {# Macros for reusable template snippets #}
    {% macro ssl_block(domain, cert_path, key_path) %}
    ssl_certificate {{ cert_path }}/{{ domain }}.crt;
    ssl_certificate_key {{ key_path }}/{{ domain }}.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE+AESGCM:ECDHE+AES256:ECDHE+AES128;
    {% endmacro %}
    
    # Virtual hosts with SSL
    {% for vhost in virtual_hosts %}
    server {
        listen 443 ssl http2;
        server_name {{ vhost.domain }};
        
        {{ ssl_block(vhost.domain, ssl_cert_path, ssl_key_path) }}
        
        location / {
            root {{ vhost.document_root }};
            index index.html index.php;
        }
    }
    {% endfor %}

**Custom Filters and Tests:**

.. code-block:: python

    # filter_plugins/custom_filters.py
    def format_memory(value):
        """Convert bytes to human readable format"""
        for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
            if value < 1024.0:
                return f"{value:3.1f} {unit}"
            value /= 1024.0
        return f"{value:.1f} PB"
    
    def validate_ip(value):
        """Validate IP address format"""
        import ipaddress
        try:
            ipaddress.ip_address(value)
            return True
        except ValueError:
            return False
    
    class FilterModule(object):
        def filters(self):
            return {
                'format_memory': format_memory,
                'validate_ip': validate_ip,
            }

**Using Custom Filters:**

.. code-block:: yaml

    - name: Configure system with custom filters
      template:
        src: system.conf.j2
        dest: /etc/system.conf
      vars:
        memory_limit: "{{ ansible_memtotal_mb * 1024 * 1024 | format_memory }}"
        valid_servers: "{{ server_list | selectattr('ip', 'validate_ip') | list }}"

===============================
Dynamic Inventories and Plugins
===============================

Dynamic inventories allow Ansible to automatically discover and manage infrastructure from external sources like cloud providers, CMDBs, or custom APIs.

**Google Cloud Platform Dynamic Inventory:**

.. code-block:: yaml

    # inventory/gcp.yml
    plugin: google.cloud.gcp_compute
    projects:
      - my-project-id
      - my-other-project-id
    
    regions:
      - us-central1
      - us-east1
      - europe-west1
    
    zones:
      - us-central1-a
      - us-central1-b
    
    auth_kind: serviceaccount
    service_account_file: ~/.gcp/service-account.json
    
    # Group instances by labels and metadata
    groups:
      # Create groups based on instance labels
      web_servers: "'web' in (labels.role | default(''))"
      databases: "'db' in (labels.role | default(''))"
      
      # Environment-based groups
      production: "'prod' in (labels.env | default(''))"
      staging: "'stage' in (labels.env | default(''))"
      development: "'dev' in (labels.env | default(''))"
      
      # Location-based groups
      us_central: "zone.startswith('us-central')"
      us_east: "zone.startswith('us-east')"
      europe: "zone.startswith('europe')"
    
    # Compose host variables from instance data
    compose:
      ansible_host: networkInterfaces[0].accessConfigs[0].natIP | default(networkInterfaces[0].networkIP)
      internal_ip: networkInterfaces[0].networkIP
      instance_type: machineType.split('/')[-1]
      instance_zone: zone.split('/')[-1]
      environment: labels.env | default('unknown')
      role: labels.role | default('generic')
      
    # Create keyed groups for easier targeting
    keyed_groups:
      - key: labels.env | default('unknown')
        prefix: env
      - key: labels.role | default('generic')  
        prefix: role
      - key: zone.split('/')[-1]
        prefix: zone

**Custom Dynamic Inventory Script:**

.. code-block:: python

    #!/usr/bin/env python3
    # inventory/custom_inventory.py
    
    import json
    import argparse
    import requests
    from typing import Dict, List, Any
    
    class CustomInventory:
        def __init__(self):
            self.inventory = {
                '_meta': {
                    'hostvars': {}
                }
            }
            
        def fetch_from_api(self) -> List[Dict[str, Any]]:
            """Fetch server data from custom API or CMDB"""
            api_url = "https://cmdb.example.com/api/servers"
            headers = {"Authorization": "Bearer YOUR_API_TOKEN"}
            
            response = requests.get(api_url, headers=headers)
            response.raise_for_status()
            return response.json()
        
        def build_inventory(self):
            """Build Ansible inventory from API data"""
            servers = self.fetch_from_api()
            
            for server in servers:
                hostname = server['hostname']
                
                # Add to _meta hostvars
                self.inventory['_meta']['hostvars'][hostname] = {
                    'ansible_host': server['ip_address'],
                    'ansible_user': server.get('ssh_user', 'ubuntu'),
                    'server_id': server['id'],
                    'environment': server['environment'],
                    'role': server['role'],
                    'datacenter': server['datacenter']
                }
                
                # Create groups based on server attributes
                for attr in ['environment', 'role', 'datacenter']:
                    group_name = server[attr]
                    if group_name not in self.inventory:
                        self.inventory[group_name] = {
                            'hosts': [],
                            'vars': {}
                        }
                    self.inventory[group_name]['hosts'].append(hostname)
        
        def get_inventory(self) -> Dict[str, Any]:
            """Return complete inventory"""
            self.build_inventory()
            return self.inventory
        
        def get_host(self, hostname: str) -> Dict[str, Any]:
            """Return host-specific variables"""
            self.build_inventory()
            return self.inventory['_meta']['hostvars'].get(hostname, {})
    
    def main():
        parser = argparse.ArgumentParser(description='Custom Ansible Dynamic Inventory')
        parser.add_argument('--list', action='store_true', help='List all groups')
        parser.add_argument('--host', help='Get variables for specific host')
        
        args = parser.parse_args()
        inventory = CustomInventory()
        
        if args.list:
            print(json.dumps(inventory.get_inventory(), indent=2))
        elif args.host:
            print(json.dumps(inventory.get_host(args.host), indent=2))
        else:
            parser.print_help()
    
    if __name__ == '__main__':
        main()

**Using Dynamic Inventories:**

.. code-block:: bash

    # Test dynamic inventory
    ansible-inventory -i inventory/gcp.yml --list
    ansible-inventory -i inventory/custom_inventory.py --graph
    
    # Use with playbooks
    ansible-playbook -i inventory/gcp.yml site.yml
    ansible-playbook -i inventory/custom_inventory.py deploy.yml
    
    # Combine static and dynamic inventories
    mkdir inventory
    cp static_hosts.yml inventory/
    cp gcp.yml inventory/
    ansible-playbook -i inventory/ site.yml

========================
Performance Optimization
========================

Optimize Ansible performance for large-scale deployments and complex automation workflows.

**Parallel Execution Configuration:**

.. code-block:: ini

    # ansible.cfg
    [defaults]
    # Increase parallel processes
    forks = 50
    
    # Reduce SSH overhead
    host_key_checking = False
    ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o UserKnownHostsFile=/dev/null
    
    # Enable pipelining for faster execution
    pipelining = True
    
    # Timeout settings
    timeout = 30
    gather_timeout = 30
    
    # Fact caching for performance
    fact_caching = redis
    fact_caching_connection = localhost:6379:0
    fact_caching_timeout = 86400
    
    # Reduce output verbosity in production
    stdout_callback = minimal
    
    [ssh_connection]
    # SSH multiplexing for performance
    ssh_args = -o ControlMaster=auto -o ControlPersist=600s
    control_path_dir = ~/.ansible/cp
    control_path = %(directory)s/%%h-%%p-%%r

**Optimized Playbook Patterns:**

.. code-block:: yaml

    ---
    - name: High-performance deployment
      hosts: all
      gather_facts: false  # Skip fact gathering when not needed
      strategy: mitogen_linear  # Use mitogen for faster execution
      
      tasks:
        # Gather only required facts
        - setup:
            filter: "ansible_os_family"
          when: need_os_info | default(false)
        
        # Use async for long-running tasks
        - name: Download large files
          get_url:
            url: "{{ item.url }}"
            dest: "{{ item.dest }}"
          async: 300
          poll: 0
          loop: "{{ large_files }}"
          register: download_jobs
        
        # Batch operations efficiently  
        - name: Install packages in batch
          package:
            name: "{{ packages | list }}"
            state: present
          vars:
            packages:
              - nginx
              - git
              - curl
              - vim
        
        # Wait for async tasks to complete
        - name: Wait for downloads to complete
          async_status:
            jid: "{{ item.ansible_job_id }}"
          register: download_results
          until: download_results.finished
          retries: 30
          delay: 10
          loop: "{{ download_jobs.results }}"

**Caching Strategies:**

.. code-block:: yaml

    # Use fact caching to avoid repeated fact gathering
    - name: Cache expensive operations
      set_fact:
        expensive_computation: "{{ some_complex_calculation }}"
        cacheable: yes
      when: expensive_computation is not defined
    
    # Cache external API calls
    - name: Get API data
      uri:
        url: "https://api.example.com/data"
        return_content: yes
      register: api_response
      cache_for: "{{ 3600 }}"  # Cache for 1 hour
      run_once: true
      delegate_to: localhost

====================
Integration Patterns
====================

Integrate Ansible with external systems, APIs, and other DevOps tools for comprehensive automation workflows.

**Terraform Integration:**

.. code-block:: text

    # terraform/outputs.tf
    output "web_servers" {
      value = {
        for instance in google_compute_instance.web_servers :
        instance.name => {
          internal_ip = instance.network_interface[0].network_ip
          external_ip = instance.network_interface[0].access_config[0].nat_ip
          zone        = instance.zone
        }
      }
    }

.. code-block:: yaml

    # Generate Ansible inventory from Terraform state
    - name: Generate inventory from Terraform
      hosts: localhost
      gather_facts: false
      
      tasks:
        - name: Get Terraform outputs
          shell: terraform output -json
          register: tf_output
          changed_when: false
        
        - name: Parse Terraform outputs
          set_fact:
            terraform_data: "{{ tf_output.stdout | from_json }}"
        
        - name: Generate Ansible inventory
          template:
            src: inventory.yml.j2
            dest: ./inventory/terraform.yml
          vars:
            web_servers: "{{ terraform_data.web_servers.value }}"

**API Integration:**

.. code-block:: yaml

    # Integration with external APIs
    - name: Deploy with external service integration
      hosts: localhost
      
      tasks:
        - name: Notify deployment start
          uri:
            url: "https://api.slack.com/api/chat.postMessage"
            method: POST
            headers:
              Authorization: "Bearer {{ slack_bot_token }}"
              Content-Type: "application/json"
            body_format: json
            body:
              channel: "#deployments"
              text: "Starting deployment of {{ app_name }} version {{ app_version }}"
        
        - name: Update deployment status in monitoring system
          uri:
            url: "https://monitoring.example.com/api/deployments"
            method: POST
            headers:
              Authorization: "Bearer {{ monitoring_api_token }}"
            body_format: json
            body:
              application: "{{ app_name }}"
              version: "{{ app_version }}"
              status: "in_progress"
              environment: "{{ environment }}"
        
        - name: Register with service discovery
          uri:
            url: "https://consul.example.com/v1/agent/service/register"
            method: PUT
            body_format: json
            body:
              ID: "{{ service_id }}"
              Name: "{{ service_name }}"
              Address: "{{ ansible_default_ipv4.address }}"
              Port: "{{ service_port }}"
              Check:
                HTTP: "https://{{ ansible_default_ipv4.address }}:{{ service_port }}/health"
                Interval: "10s"

**CI/CD Pipeline Integration:**

.. code-block:: yaml

    # .github/workflows/deploy.yml
    name: Deploy with Ansible
    
    on:
      push:
        branches: [main]
    
    jobs:
      deploy:
        runs-on: ubuntu-latest
        
        steps:
          - uses: actions/checkout@v2
          
          - name: Setup Ansible
            run: |
              pip install ansible google-auth requests
              ansible-galaxy collection install google.cloud
          
          - name: Configure GCP credentials
            run: echo '${{ secrets.GCP_SERVICE_ACCOUNT }}' > ~/.gcp/service-account.json
          
          - name: Deploy infrastructure
            run: |
              cd infrastructure/
              terraform init
              terraform apply -auto-approve
          
          - name: Configure infrastructure
            run: |
              cd configuration/
              ansible-playbook -i inventory/gcp.yml site.yml
            env:
              ANSIBLE_VAULT_PASSWORD_FILE: ${{ secrets.VAULT_PASSWORD_FILE }}


.. note::

    The advanced features in this chapter form the foundation for enterprise-grade automation. Focus on understanding the concepts and patterns rather than memorizing syntax - the goal is to build maintainable, scalable automation that grows with your infrastructure needs.
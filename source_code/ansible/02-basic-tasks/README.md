# 02 - Basic Tasks

Learn fundamental Ansible modules for file operations, package management, and service control.

## Learning Objectives

- Master the core Ansible modules: `file`, `copy`, `template`, `apt/yum`, `service`
- Understand task anatomy and return values
- Learn to use conditional statements and error handling
- Practice idempotent operations

## Files in this Example

- `file-operations.yml` - File and directory management
- `package-management.yml` - Installing and removing packages  
- `service-management.yml` - Starting, stopping, and configuring services
- `complete-example.yml` - Combined example installing and configuring nginx
- `templates/nginx.conf.j2` - Example Jinja2 template
- `files/index.html` - Static file for deployment

## Core Modules Covered

### File Module
- Create/delete files and directories
- Set permissions, ownership
- Create symbolic links

### Copy Module  
- Copy files from control node to managed nodes
- Set permissions and ownership during copy
- Backup existing files

### Template Module
- Process Jinja2 templates with variables
- Dynamic configuration file generation

### Package Modules (apt/yum/package)
- Install, update, remove packages
- Handle package repositories
- Manage package caches

### Service Module
- Start, stop, restart services
- Enable/disable services at boot
- Check service status

## Running Examples

```bash
# Run individual examples
ansible-playbook file-operations.yml
ansible-playbook package-management.yml  
ansible-playbook service-management.yml

# Run complete nginx setup
ansible-playbook complete-example.yml

# Check mode (dry run)
ansible-playbook complete-example.yml --check

# Run on specific hosts
ansible-playbook complete-example.yml --limit web_servers
```

## Key Concepts

### 1. **Idempotency**
All tasks should be idempotent - running multiple times produces the same result without unwanted side effects.

### 2. **Task Results**
Tasks return information that can be captured with `register` and used in conditions.

### 3. **Error Handling**
Use `ignore_errors`, `failed_when`, and `changed_when` to control task behavior.

### 4. **Conditionals**
Use `when` conditions to run tasks only under specific circumstances.

## Testing Your Work

After running the playbooks, verify the results:

```bash
# Check if nginx is installed and running
ansible all -m command -a "systemctl status nginx"

# Verify nginx configuration
ansible all -m command -a "nginx -t"

# Check if custom index page is deployed
ansible all -m uri -a "url=http://localhost/ return_content=yes"

# View nginx access logs
ansible all -m command -a "tail -5 /var/log/nginx/access.log"
```

## Common Patterns

### Installing and Starting a Service
```yaml
- name: Install nginx
  apt:
    name: nginx
    state: present
    update_cache: yes

- name: Start and enable nginx
  service:
    name: nginx
    state: started
    enabled: yes
```

### Conditional Package Installation
```yaml
- name: Install packages on Ubuntu
  apt:
    name: "{{ item }}"
    state: present
  loop:
    - nginx
    - git
    - curl
  when: ansible_distribution == "Ubuntu"
```

### File Permission Management
```yaml
- name: Create application directory
  file:
    path: /var/www/myapp
    state: directory
    owner: www-data
    group: www-data
    mode: '0755'
```

## Next Steps

After mastering basic tasks:
1. Move to **03-variables-facts** to learn about data manipulation
2. Practice combining multiple modules in single playbooks
3. Experiment with different conditional statements
4. Learn about task delegation and connection types
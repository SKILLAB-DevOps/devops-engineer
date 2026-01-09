# Ansible Best Practices for Teaching and Production

This document summarizes the best practices demonstrated in our teaching examples and explains why they matter for real-world DevOps.

## Teaching Best Practices Applied

### 1. **Vault Usage**
Our examples build from simple to complex:
- Start with basic connectivity (ping)
- Move to single modules (file, package, service)
- Progress to complex templates and variables
- Culminate in real application deployment

**Why this matters**: Prevents overwhelming beginners while building solid foundations.

### 2. **Connection Security**
Every playbook starts with what you'll learn:
```yaml
- name: "Learning Objectives"
  debug:
    msg: |
      What you'll learn:
      - Specific skill 1
      - Specific skill 2
```

**Why this matters**: Students know what they're achieving and can track progress.

### 3. **Extensive Documentation**
- Inline comments explain every complex task
- READMEs provide context and next steps
- Examples show multiple approaches

**Why this matters**: Self-paced learning and reference material for later.

## Production Best Practices Demonstrated

### 1. **Idempotency**
**Good Practice**:
```yaml
- name: Create directory
  file:
    path: /opt/app
    state: directory
    mode: '0755'
```

**Bad Practice**:
```yaml
- name: Create directory
  command: mkdir /opt/app
```

**Teaching Point**: Always use appropriate modules that handle state correctly.

### 2. **Variable Management**
**Good Practice**:
```yaml
vars:
  app_name: "wordpress"
  app_port: 8080
  app_directory: "/opt/{{ app_name }}"
```

**Bad Practice**:
```yaml
- name: Create directory
  file:
    path: /opt/wordpress  # Hard-coded path
```

**Teaching Point**: Variables make playbooks reusable and maintainable.

### 3. **Error Handling**
**Good Practice**:
```yaml
- name: Check service status
  systemd:
    name: nginx
  register: nginx_status
  ignore_errors: true

- name: Handle service failure
  debug:
    msg: "Service not available"
  when: nginx_status is failed
```

**Teaching Point**: Always anticipate and handle potential failures gracefully.

### 4. **Security Practices**

#### File Permissions
✅ **Good Practice**:
```yaml
- name: Create config file
  copy:
    content: "{{ config_content }}"
    dest: /etc/app/config.conf
    mode: '0600'  # Only owner can read/write
    owner: app
    group: app
```

#### Password Management
**Good Practice** (Production):
```yaml
# Use ansible-vault for real passwords
wordpress_admin_password: "{{ vault_admin_password }}"
```

**Teaching Example** (Educational Only):
```yaml
# Clear text for learning - NEVER in production!
wordpress_admin_password: "SecurePassword123!"
```

### 5. **Service Management**
✅ **Good Practice**:
```yaml
- name: Start and enable service
  systemd:
    name: nginx
    state: started
    enabled: yes  # Start at boot
  notify: restart nginx  # Use handlers
```

### 6. **Template Usage**
✅ **Good Practice**:
```jinja2
# nginx.conf.j2
server {
    listen {{ app_port }};
    server_name {{ ansible_hostname }};
    
    {% if environment == 'production' %}
    # Production-specific settings
    ssl_certificate /etc/ssl/certs/app.crt;
    {% endif %}
}
```

**Teaching Point**: Templates allow dynamic, environment-specific configurations.

## Security Best Practices

### 1. **Privilege Escalation**
```yaml
- name: Install package
  package:
    name: nginx
    state: present
  become: true  # Only when needed
```

### 2. **SSH Key Management**
```bash
# Use SSH keys, not passwords
ssh-copy-id user@server
```

### 3. **Ansible Vault for Secrets**
```bash
# Encrypt sensitive data
ansible-vault encrypt_string 'secret_password' --name 'db_password'
```

### 4. **Least Privilege Principle**
```yaml
# Create application-specific users
- name: Create app user
  user:
    name: webapp
    shell: /bin/false  # No shell access
    system: yes        # System user
    home: /opt/webapp
```

## File Organization

### Directory Structure
```
ansible/
├── inventory/
│   ├── production.yml
│   ├── staging.yml
│   └── development.yml
├── group_vars/
│   ├── all.yml
│   └── production.yml
├── host_vars/
├── roles/
├── playbooks/
└── files/
```

### Naming Conventions
- **Playbooks**: Descriptive names (`deploy-wordpress.yml`)
- **Variables**: Clear, consistent naming (`app_name`, not `name`)
- **Files**: Organized by purpose (`templates/`, `files/`)

## Performance Optimization

### 1. **Fact Gathering**
```yaml
# Only gather facts when needed
- hosts: all
  gather_facts: false  # Faster execution
```

### 2. **Parallel Execution**
```yaml
# Use serial for rolling updates
- hosts: webservers  
  serial: 2  # Update 2 servers at a time
```

### 3. **Task Optimization**
```yaml
# Batch operations when possible
- name: Install multiple packages
  package:
    name: "{{ packages }}"  # Install all at once
    state: present
```

## 🐛 Debugging Best Practices

### 1. **Use Check Mode**
```bash
# See what would change without making changes
ansible-playbook playbook.yml --check
```

### 2. **Verbose Output**
```bash
# Get detailed output for troubleshooting
ansible-playbook playbook.yml -vvv
```

### 3. **Debug Tasks**
```yaml
- name: Debug variable
  debug:
    var: my_variable
    
- name: Debug with condition
  debug:
    msg: "Value is {{ my_var }}"
  when: debug_mode | default(false)
```

## Testing Best Practices

### 1. **Syntax Checking**
```bash
# Check playbook syntax
ansible-playbook playbook.yml --syntax-check
```

### 2. **Dry Run Testing**
```bash
# Test without making changes
ansible-playbook playbook.yml --check --diff
```

### 3. **Role Testing**
```bash
# Use molecule for role testing
molecule test
```

## 🎓 Teaching-Specific Practices

### 1. **Safe Examples**
- All examples use `localhost` or isolated VMs
- Dangerous operations use `tags: never`
- Clear warnings about production usage

### 2. **Interactive Learning**
- Examples encourage experimentation
- Multiple ways to run each example
- Clear success/failure indicators

### 3. **Real-World Relevance**
- Every example has practical applications
- Production considerations explained
- Security implications discussed

### 4. **Progressive Disclosure**
- Complex concepts introduced gradually
- Each example builds on previous ones
- Advanced features clearly marked

## Checklist for Production Readiness

Before using any playbook in production:

- [ ] All passwords managed with ansible-vault
- [ ] File permissions properly set
- [ ] Error handling implemented
- [ ] Backup procedures in place
- [ ] Testing procedures established
- [ ] Documentation updated
- [ ] Security review completed
- [ ] Performance tested
- [ ] Rollback procedures defined
- [ ] Monitoring implemented

## Next Level Practices

### Advanced Topics to Explore:
1. **Ansible Roles** - Modular, reusable automation
2. **Custom Modules** - Extend Ansible functionality
3. **Dynamic Inventory** - Cloud-native inventory management
4. **Ansible AWX/Tower** - Web UI and workflow orchestration
5. **Integration Testing** - Automated testing of infrastructure
6. **GitOps Workflows** - Version-controlled infrastructure

---

**Remember**: These practices aren't just rules - they're lessons learned from real production environments. Start with these patterns and you'll avoid common pitfalls while building robust, maintainable automation!
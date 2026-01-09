# Variables and Templates in Ansible

This example demonstrates how to use variables and Jinja2 templates in Ansible playbooks.

## Learning Objectives

- Understand different variable sources and precedence
- Master Jinja2 templating for dynamic configurations
- Learn to organize variables in files and directories
- Practice conditional templating and loops in templates

## Files Included

- `playbook.yml` - Main playbook demonstrating variable usage
- `vars/main.yml` - Variables file included in playbook
- `group_vars/all.yml` - Variables for all hosts
- `host_vars/localhost.yml` - Variables specific to localhost
- `templates/` - Jinja2 templates for configuration files
  - `app-config.j2` - Application configuration template
  - `index.html.j2` - Dynamic HTML page template
  - `nginx-site.j2` - Nginx virtual host template

## Variable Sources (in order of precedence)

1. **Command line variables** (`-e "var=value"`)
2. **Task variables** (`vars:` in tasks)
3. **Block variables** (`vars:` in blocks)
4. **Role and include variables**
5. **Play variables** (`vars:` in plays)
6. **Host variables** (`host_vars/`)
7. **Group variables** (`group_vars/`)
8. **Inventory variables**
9. **Default variables** (lowest precedence)

## Running the Example

### Basic execution:
```bash
# Use the parent directory inventory
ansible-playbook -i ../01-basic-setup/inventory.yml playbook.yml

# Or run against localhost
ansible-playbook -i localhost, playbook.yml --connection=local

# Override variables from command line
ansible-playbook -i localhost, playbook.yml --connection=local -e "app_name=my-custom-app" -e "app_port=9090"
```

### Testing different environments:
```bash
# Development environment (default)
ansible-playbook -i localhost, playbook.yml --connection=local

# Production environment
ansible-playbook -i localhost, playbook.yml --connection=local -e "environment=production"

# With custom variables
ansible-playbook -i localhost, playbook.yml --connection=local \
  -e "environment=production" \
  -e "database_host=prod-db.example.com" \
  -e "debug_mode=false"
```

## Key Concepts Demonstrated

### 1. Variable Declaration
```yaml
vars:
  app_name: "my-web-app"
  app_port: 8080
  packages_to_install:
    - nginx
    - curl
```

### 2. Template Usage
```yaml
- name: Generate config from template
  template:
    src: app-config.j2
    dest: /opt/app/config.conf
```

### 3. Variable Interpolation
```yaml
app_directory: "/opt/{{ app_name }}"  # Results in /opt/my-web-app
```

### 4. Conditional Variables
```jinja2
{% if environment == 'production' %}
ssl_enabled = true
{% else %}
ssl_enabled = false
{% endif %}
```

### 5. Loops in Templates
```jinja2
{% for package in packages_to_install %}
Package: {{ package }}
{% endfor %}
```

### 6. Facts Usage
```jinja2
Server: {{ ansible_hostname }}
Memory: {{ ansible_memtotal_mb }}MB
```

## Testing Your Deployment

After running the playbook, test the results:

```bash
# Check if the application is running
curl http://localhost:8080

# View generated configuration
cat /opt/my-web-app/config/app.conf

# Check nginx configuration
nginx -t

# View nginx logs
tail -f /opt/my-web-app/logs/access.log
```

## Template Best Practices

1. **Use filters for safety**:
   ```jinja2
   {{ variable | default('fallback_value') }}
   ```

2. **Indent consistently**:
   ```jinja2
   {% if condition %}
       indented content
   {% endif %}
   ```

3. **Comment complex logic**:
   ```jinja2
   {# This calculates cache size based on available memory #}
   {% if ansible_memtotal_mb > 2048 %}
   ```

4. **Validate templates**:
   ```bash
   ansible-playbook playbook.yml --check --diff
   ```

## Common Template Patterns

### Configuration files:
```jinja2
[database]
host = {{ database_host | default('localhost') }}
port = {{ database_port | default(3306) }}
```

### Conditional sections:
```jinja2
{% if environment == 'production' %}
[ssl]
enabled = true
cert_path = /etc/ssl/certs/app.crt
{% endif %}
```

### Dynamic lists:
```jinja2
{% for server in groups['web_servers'] %}
upstream {{ server }};
{% endfor %}
```

## Next Steps

1. Move to **04-handlers** to learn about event-driven tasks
2. Practice with more complex templates and variable structures
3. Experiment with filters and tests in Jinja2
4. Learn about encrypted variables with ansible-vault
# Ansible Learning Path - Quick Start Guide

This guide will get you from zero to WordPress deployment in the most educational way possible!

## Prerequisites Checklist

### On Your Control Machine (Your Laptop/Desktop):
- [ ] **Ansible installed** (pip install ansible or brew install ansible)
- [ ] **Git** for cloning repositories
- [ ] **SSH client** (built into Linux/macOS, use WSL on Windows)
- [ ] **Text editor** (VS Code, vim, nano, etc.)

### Target Machine Options (Choose ONE):
- [ ] **Option A - Localhost** (easiest): Your own machine
- [ ] **Option B - VM**: VirtualBox/VMware Ubuntu 22.04 VM  
- [ ] **Option C - Cloud**: AWS EC2, DigitalOcean, or Google Cloud instance
- [ ] **Option D - Docker**: Container for isolated testing

## Learning Path (30-60 minutes total)

### Phase 1: Foundation (10 minutes)
```bash
cd ansible/01-basic-setup
# Test basic connectivity
ansible-playbook -i ../inventory/localhost.yml ping-test.yml

# Gather system information
ansible-playbook -i ../inventory/localhost.yml system-info.yml
```

**What you learned**: Ansible basics, inventory, connectivity, facts

### Phase 2: Core Skills (15 minutes)
```bash
cd ../02-basic-tasks

# Learn file operations
ansible-playbook -i ../inventory/localhost.yml file-operations.yml

# Master package management  
ansible-playbook -i ../inventory/localhost.yml package-management.yml

# Control services
ansible-playbook -i ../inventory/localhost.yml service-management.yml
```

**What you learned**: File, package, and service modules - the Ansible essentials

### Phase 3: Advanced Concepts (10 minutes)
```bash
cd ../03-variables-templates

# Master variables and templates
ansible-playbook -i ../inventory/localhost.yml playbook.yml

# Try with custom variables
ansible-playbook -i ../inventory/localhost.yml playbook.yml \
  -e "app_name=my-custom-app" \
  -e "environment=production"
```

**What you learned**: Dynamic configurations, Jinja2 templating, variable precedence

### Phase 4: Real-World Application (20 minutes)
```bash
cd ../09-wordpress-deployment

# Deploy complete WordPress site
ansible-playbook -i inventory.yml wordpress-install.yml

# Add security hardening
ansible-playbook -i inventory.yml wordpress-security.yml

# Set up backups
ansible-playbook -i inventory.yml wordpress-backup.yml
```

**What you learned**: Complete application deployment, security, production practices

## Ultra-Quick Demo (5 minutes)

If you just want to see Ansible in action:

```bash
# Clone and enter directory
git clone <repo-url> && cd devops/source_code/ansible

# Test connectivity
ansible localhost -m ping -c local

# Install a package
ansible localhost -m package -a "name=htop state=present" -c local --become

# Check the result
htop --version
```

## Teaching Approach

Each example follows **progressive learning**:

1. **Clear Learning Objectives** - Know what you'll learn before starting
2. **Step-by-step Explanations** - Every task is documented
3. **Best Practices** - Industry-standard approaches from day one
4. **Safety First** - All examples are safe to run multiple times
5. **Real-World Relevance** - Skills you'll actually use in DevOps

## Troubleshooting Quick Reference

### Common Issues:

**"Permission denied"**
```bash
# Add --become for sudo access
ansible-playbook playbook.yml --become
```

**"Host unreachable"**
```bash
# Test basic connectivity
ansible all -m ping -vvv
```

**"Python not found"**
```bash
# Install Python on target
ansible all -m raw -a "apt update && apt install -y python3" --become
```

**"Service not found"**
```bash
# Check if package is installed first
ansible all -m package_facts
```

## Key Learning Outcomes

After completing this path, you'll be able to:

- **Automate server configuration** from scratch
- **Deploy complex applications** like WordPress  
- **Manage services and packages** across multiple servers
- **Use variables and templates** for dynamic configurations
- **Apply security best practices** in automation
- **Troubleshoot and debug** Ansible playbooks
- **Scale to production** environments

## Next Steps

1. **Practice with different applications** (databases, web servers)
2. **Learn Ansible Roles** for better organization
3. **Explore Ansible Galaxy** for community roles
4. **Try Ansible AWX/Tower** for web interface
5. **Integrate with CI/CD pipelines**
6. **Study Infrastructure as Code** patterns

## Pro Tips for Learning

- **Run playbooks multiple times** - understand idempotency
- **Use `--check` mode** to see what would change
- **Add `-v` for verbose output** when debugging
- **Read the generated files** to understand templates
- **Experiment with variables** to see dynamic behavior
- **Break things safely** - that's how you learn!

---

**Happy Learning!**

Remember: The best way to learn Ansible is by doing. Don't just read - run the playbooks and experiment!
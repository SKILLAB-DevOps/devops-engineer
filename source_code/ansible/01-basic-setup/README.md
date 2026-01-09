# 01 - Ansible Basic Setup

**Your first step into Ansible!** This example covers the absolute fundamentals you need to start using Ansible effectively.

## What You'll Learn

- **Ansible Architecture**: Control node (your laptop) vs managed nodes (servers)
- **Inventory Configuration**: How to tell Ansible which machines to manage
- **Connection Testing**: Verify Ansible can reach your machines
- **First Commands**: Run your first Ansible commands and playbooks
- **Best Practices**: Proper configuration and security from day one

## Files in this Example

- `inventory.yml` - Inventory file with host definitions
- `ansible.cfg` - Ansible configuration file
- `ping-test.yml` - Simple connectivity test playbook
- `system-info.yml` - Gather system information playbook

## Prerequisites

1. **Ansible installed** on control node (your machine)
2. **SSH access** to managed nodes
3. **Python** installed on managed nodes

## Setup Instructions

### 1. Configure Inventory

Edit `inventory.yml` with your target hosts. We keep it simple with just 1-2 machines:

```yaml
all:
  children:
    web_servers:
      hosts:
        web1:
          ansible_host: 192.168.1.10  # Your VM or cloud instance
          ansible_user: ubuntu
    
    local:
      hosts:
        localhost:
          ansible_connection: local    # Always available for testing
```

**Simple Test Setup Options:**
- **Local machine**: Use `localhost` for immediate testing
- **Single VM**: VirtualBox, VMware, or cloud instance
- **Docker container**: Quick disposable test environment

### 2. Test SSH Connectivity

```bash
# Test SSH access manually
ssh ubuntu@192.168.1.10

# Set up SSH key authentication (recommended)
ssh-copy-id ubuntu@192.168.1.10
```

### 3. Run Basic Commands

```bash
# Test connectivity with ping module
ansible all -m ping

# Check disk space on all hosts
ansible all -m shell -a "df -h"

# Get system information
ansible all -m setup --tree /tmp/facts
```

## Example Commands

### Ad-hoc Commands

```bash
# Ping all hosts
ansible all -m ping

# Ping specific group
ansible web_servers -m ping

# Ping specific host
ansible web1 -m ping

# Check uptime
ansible all -m command -a "uptime"

# Install package (requires sudo)
ansible all -m apt -a "name=htop state=present" --become

# Restart service
ansible web_servers -m service -a "name=nginx state=restarted" --become

# Copy file to hosts
ansible all -m copy -a "src=/etc/hosts dest=/tmp/hosts"

# Get disk usage
ansible all -m shell -a "df -h / | tail -1 | awk '{print $5}'"
```

### Information Gathering

```bash
# Gather all facts
ansible all -m setup

# Gather specific facts
ansible all -m setup -a "filter=ansible_distribution*"

# Get memory information
ansible all -m setup -a "filter=ansible_memory_mb"

# Check if file exists
ansible all -m stat -a "path=/etc/passwd"
```

## Running Playbooks

```bash
# Test connectivity
ansible-playbook ping-test.yml

# Gather system information
ansible-playbook system-info.yml

# Run with specific inventory
ansible-playbook -i inventory.yml ping-test.yml

# Run with verbose output
ansible-playbook ping-test.yml -v

# Check syntax without running
ansible-playbook ping-test.yml --syntax-check

# Dry run (check mode)
ansible-playbook ping-test.yml --check
```

## Key Concepts Learned

### 1. **Inventory Management**
- Static vs dynamic inventory
- Host groups and group variables
- Connection parameters

### 2. **Ansible Configuration**
- Configuration file precedence
- Common configuration options
- Environment variables

### 3. **SSH and Authentication**
- SSH key-based authentication
- Privilege escalation with `--become`
- Connection types and methods

### 4. **Ad-hoc Commands**
- Module usage and parameters
- Target selection patterns
- Command execution options

### 5. **Playbook Basics**
- YAML syntax and structure
- Task execution and output
- Syntax checking and dry runs

## Common Issues and Solutions

### SSH Connection Problems
```bash
# Test SSH connectivity
ansible all -m ping -vvv

# Check SSH agent
ssh-add -l

# Force password authentication
ansible all -m ping --ask-pass
```

### Permission Issues
```bash
# Use sudo for privileged tasks
ansible all -m apt -a "name=vim state=present" --become --ask-become-pass

# Check sudo permissions
ansible all -m command -a "sudo -l" --become
```

### Python Issues
```bash
# Check Python installation
ansible all -m raw -a "python3 --version"

# Install Python if missing
ansible all -m raw -a "apt update && apt install -y python3" --become
```

## Next Steps

After mastering basic setup:
1. Move to **02-basic-tasks** to learn file, package, and service management
2. Practice with different inventory formats
3. Experiment with various modules and ad-hoc commands
4. Set up SSH keys for passwordless authentication

## Best Practices Introduced

- Use SSH keys instead of passwords
- Group hosts logically in inventory
- Test connectivity before running complex playbooks  
- Use `--check` mode to validate changes
- Keep inventory files in version control
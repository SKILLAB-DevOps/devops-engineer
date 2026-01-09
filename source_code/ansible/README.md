# Ansible Examples - Teaching-Focused Learning Progression

This directory contains carefully crafted Ansible examples designed for **progressive learning in DevOps education**. Each example follows **teaching best practices** with simple setups (1-2 machines maximum) and clear educational objectives.

## Learning Path Overview

### **Foundation Level**
- **01-basic-setup** - Ansible installation, inventory, and first commands
- **02-basic-tasks** - Core modules: file, package, service operations
- **03-variables-templates** - Dynamic configurations with Jinja2

### **Advanced Application**
- **09-wordpress-deployment** - Complete real-world deployment (NGINX + PHP + MySQL + WordPress)

## Teaching Philosophy

These examples are specifically designed for **DevOps education** with:

- **Maximum Simplicity**: Each example uses 1-2 machines only
- **Progressive Complexity**: Concepts build on each other logically
- **Real-World Relevance**: Every example has practical applications
- **Best Practices**: Proper Ansible patterns and security considerations
- **Multiple Testing Options**: localhost, VM, or container deployment
- **Comprehensive Documentation**: Clear explanations and learning objectives

## Prerequisites

```bash
# Install Ansible
pip install ansible

# Or on Ubuntu/Debian
sudo apt update
sudo apt install ansible

# Or on macOS
brew install ansible
```

## Getting Started

1. **Start with `01-basic-setup`** to understand Ansible fundamentals
2. **Work through examples in order** - each builds on previous concepts
3. **Read the README in each directory** for detailed explanations
4. **Test on local VMs or containers** before production use

## Simple Test Setup (1-2 Machines Max)

These examples are designed for **simple learning environments** with just 1-2 machines:

### Option 1: Local Machine Only
```bash
# Test everything locally first
ansible-playbook -i inventory/local.yml playbook.yml
```

### Option 2: One Remote VM
```bash
# Single Ubuntu VM (VirtualBox, cloud instance, etc.)
# IP: 192.168.1.10, User: ubuntu
ansible-playbook -i inventory/simple.yml playbook.yml
```

### Option 3: Quick Docker Container
```bash
# Create simple test container
docker run -d --name ansible-test \
  -p 2222:22 \
  ubuntu:22.04 \
  /bin/bash -c "apt update && apt install -y openssh-server python3 sudo && \
                useradd -m -s /bin/bash ubuntu && \
                echo 'ubuntu:password' | chpasswd && \
                echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
                service ssh start && tail -f /dev/null"

# Test connection
ansible test-container -m ping
```

## Directory Structure

```
ansible/
├── README.md                    # This file
├── ansible.cfg                  # Global Ansible configuration
├── inventory/                   # Inventory files
├── group_vars/                  # Group variables
├── host_vars/                   # Host variables
├── 01-basic-setup/             # Basic Ansible concepts
├── 02-basic-tasks/             # File, package, service tasks
├── 03-variables-facts/         # Variables and templates
├── 04-handlers-loops/          # Advanced task control
├── 05-roles-structure/         # Ansible roles
├── 06-user-management/         # User and group management
├── 07-web-server/             # NGINX web server setup
├── 08-database-server/        # Database installation
└── 09-wordpress-deployment/   # Complete WordPress deployment
```

Each example includes:
- **Playbook files** (`.yml`)
- **README.md** with explanations and learning objectives
- **Templates** and **files** as needed
- **Testing instructions** and validation commands
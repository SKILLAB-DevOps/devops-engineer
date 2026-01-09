# Ansible Basic Tasks Examples

This directory contains examples of fundamental Ansible tasks that every DevOps engineer should know.

## Learning Examples

### 1. File Operations (`file-operations.yml`)
**Master the file module - Ansible's Swiss Army knife!**
- Create directories and files with proper permissions
- Use variables and dynamic content
- File status checking and validation
- Symbolic links and backups
- Understanding idempotency

### 2. Package Management (`package-management.yml`)
**Learn to install and manage software packages**
- Cross-platform package installation
- Package cache management
- Package verification and facts
- Safe package removal practices
- Different package managers (apt, yum, package)

### 3. Service Management (`service-management.yml`)
**Control system services like a pro**
- Start, stop, restart services
- Enable/disable services at boot
- Service status monitoring
- Configuration reloading
- Troubleshooting service issues

## Prerequisites

- Ansible installed on your control machine
- SSH access to target machines (or Docker for testing)
- Sudo privileges on target machines (for system operations)

## How to Run

1. First, ensure your inventory is properly configured in the parent directory
2. Test connectivity:
   ```bash
   ansible all -i ../01-basic-setup/inventory.yml -m ping
   ```

3. Run any of the playbooks:
   ```bash
   # File operations
   ansible-playbook -i ../01-basic-setup/inventory.yml file-operations.yml
   
   # Package management
   ansible-playbook -i ../01-basic-setup/inventory.yml package-management.yml
   
   # Service management
   ansible-playbook -i ../01-basic-setup/inventory.yml service-management.yml
   ```

4. Use tags to run specific tasks:
   ```bash
   # Only run file creation tasks
   ansible-playbook -i ../01-basic-setup/inventory.yml file-operations.yml --tags "file_creation"
   
   # Run tasks that were marked with "never" (like service restarts)
   ansible-playbook -i ../01-basic-setup/inventory.yml service-management.yml --tags "restart_services"
   ```

## Testing with Docker

For testing these examples, you can use a simple Docker container:

```bash
# Create a test container with systemd (needed for service management)
docker run -d --name ansible-test --privileged ubuntu:20.04 /sbin/init

# Install required packages in the container
docker exec -it ansible-test bash
apt update && apt install -y openssh-server python3 systemd

# Or use localhost for simple testing
ansible-playbook -i localhost, file-operations.yml --connection=local
```

## Learning Objectives

- Understand Ansible's core modules (file, package, service)
- Learn about idempotency in configuration management
- Practice with templates and variable substitution
- Explore conditional execution and loops
- Master tags for selective task execution

## Key Concepts Demonstrated

- **Idempotency**: Running playbooks multiple times safely
- **Conditionals**: Using `when` statements for OS-specific tasks
- **Loops**: Processing multiple items efficiently
- **Error Handling**: Using `ignore_errors` and error checking
- **Tags**: Organizing and selectively running tasks
- **Facts**: Gathering and using system information

## Next Steps

After mastering these basic tasks, move on to:
- Variables and templates (03-variables-templates)
- Handlers and notifications (04-handlers)
- Roles and organization (05-roles)
- Advanced patterns and WordPress deployment
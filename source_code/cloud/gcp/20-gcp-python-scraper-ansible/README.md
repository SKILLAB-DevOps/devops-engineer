# GCP Python Scraper with Ansible

This project demonstrates how to deploy a Python Reddit scraper application on Google Cloud Platform using **Terraform** for infrastructure provisioning and **Ansible** for configuration management.

## Architecture

- **Terraform**: Provisions a GCP VM instance with networking and firewall rules
- **Ansible**: Configures the VM and deploys the Python scraper application as a systemd service

## Prerequisites

1. **Google Cloud Platform**
   - GCP account with billing enabled
   - gcloud CLI installed and authenticated
   - Project created with Compute Engine API enabled

2. **Terraform**
   ```bash
   # Install Terraform
   wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
   echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
   sudo apt update && sudo apt install terraform
   ```

3. **Ansible**
   ```bash
   # Install Ansible
   sudo apt update
   sudo apt install -y ansible
   ```

4. **SSH Key**
   ```bash
   # Generate SSH key if you don't have one
   ssh-keygen -t rsa -b 4096 -C "ansible@example.com" -f ~/.ssh/id_rsa -N ""
   ```

## Project Structure

```
20-gcp-python-scraper-ansible/
├── main.tf              # Terraform configuration for GCP resources
├── playbook.yml         # Ansible playbook for application deployment
├── ansible.cfg          # Ansible configuration
├── inventory.ini        # Ansible inventory file
└── README.md           # This file
```

## Deployment Steps

### Step 1: Configure Terraform

Edit `main.tf` and update the project ID:

```hcl
provider "google" {
  project = "your-actual-gcp-project-id"  # Change this!
  region  = "us-central1"
  zone    = "us-central1-a"
}
```

### Step 2: Provision Infrastructure with Terraform

```bash
# Initialize Terraform
terraform init

# Preview the changes
terraform plan

# Apply the configuration
terraform apply
```

After applying, Terraform will output:
- `vm_instance_ip`: The public IP address of your VM
- `ssh_command`: Command to SSH into the VM
- `ansible_command`: Command to run Ansible (after updating inventory)

### Step 3: Update Ansible Inventory

Copy the VM IP from Terraform output and add it to `inventory.ini`:

```ini
[scraper_servers]
34.123.45.67 ansible_user=ansible

[scraper_servers:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

Or use the automated approach:

```bash
# Extract IP and update inventory
VM_IP=$(terraform output -raw vm_instance_ip)
echo "${VM_IP} ansible_user=ansible" >> inventory.ini
```

### Step 4: Test Ansible Connectivity

```bash
# Test connection to the VM
ansible scraper_servers -m ping

# Expected output:
# 34.123.45.67 | SUCCESS => {
#     "changed": false,
#     "ping": "pong"
# }
```

### Step 5: Deploy with Ansible

```bash
# Run the playbook
ansible-playbook playbook.yml

# Or with verbose output
ansible-playbook playbook.yml -vv
```

The playbook will:
1. Update system packages
2. Install dependencies (curl, git, python3-pip)
3. Install `uv` (modern Python package manager)
4. Install Python 3.13.8
5. Clone the Reddit scraper repository
6. Create a virtual environment and install dependencies
7. Create a systemd service
8. Start and enable the service

## Verification

### Check Service Status

```bash
# SSH into the VM
gcloud compute ssh devops-ansible-01 --zone us-central1-a

# Check service status
sudo systemctl status reddit_scrapper

# View logs
sudo journalctl -u reddit_scrapper -f
```

### Test the API

```bash
# Get the VM IP
VM_IP=$(terraform output -raw vm_instance_ip)

# Test the FastAPI endpoint
curl http://${VM_IP}:8000
```

## Ansible Playbook Explained

The `playbook.yml` contains several key tasks:

### Variables
```yaml
vars:
  app_directory: /opt/devops
  repo_url: https://github.com/SKILLAB-DevOps/devops_reddit_scrapper.git
  python_version: "3.13.8"
  service_name: reddit_scrapper
```

### Key Tasks

1. **System Updates**: Updates apt cache and installs base packages
2. **UV Installation**: Installs the modern Python package manager
3. **Python Installation**: Installs specific Python version using uv
4. **Repository Clone**: Clones the application code
5. **Dependencies**: Creates venv and installs Python packages
6. **Systemd Service**: Creates and manages the service
7. **Service Management**: Enables and starts the service

## Customization

### Change Python Version

Edit `playbook.yml`:

```yaml
vars:
  python_version: "3.12.0"  # Change to desired version
```

### Change Repository

Edit `playbook.yml`:

```yaml
vars:
  repo_url: https://github.com/your-username/your-repo.git
  repo_name: your-repo
```

### Change Service Configuration

Modify the systemd service template in the playbook:

```yaml
- name: Create systemd service file
  copy:
    content: |
      [Service]
      Environment="API_KEY=your-key"
      ExecStart={{ app_directory }}/{{ repo_name }}/.venv/bin/python main.py
```

## Advantages of Ansible Approach

1. **Idempotent**: Can run multiple times safely
2. **Reusable**: Same playbook works across multiple servers
3. **Version Control**: Configuration as code
4. **Separation of Concerns**: Infrastructure (Terraform) vs Configuration (Ansible)
5. **Testable**: Can test on different environments
6. **Maintainable**: Easy to update and modify

## Comparison: Bash Script vs Ansible

### Startup Script (Old Way)
```bash
sudo apt update
curl -LsSf https://astral.sh/uv/install.sh | sh
# ... more commands
```

**Issues:**
- Not idempotent (running twice causes issues)
- Hard to test
- No error handling
- Tightly coupled with Terraform

### Ansible Playbook (New Way)
```yaml
- name: Install required packages
  apt:
    name: curl
    state: present
```

**Benefits:**
- Idempotent (safe to run multiple times)
- Built-in error handling
- Testable independently
- Reusable across environments

## Troubleshooting

### SSH Connection Failed

```bash
# Ensure SSH key is added to GCP
gcloud compute config-ssh

# Test SSH manually
ssh -i ~/.ssh/id_rsa ansible@<VM_IP>
```

### Ansible Connection Timeout

```bash
# Check firewall rules
gcloud compute firewall-rules list

# Ensure SSH (port 22) is allowed
gcloud compute firewall-rules create allow-ssh \
  --allow tcp:22 \
  --source-ranges 0.0.0.0/0
```

### Service Failed to Start

```bash
# Check logs
ansible scraper_servers -m shell -a "sudo journalctl -u reddit_scrapper -n 50"

# Check if port is in use
ansible scraper_servers -m shell -a "sudo netstat -tlnp | grep 8000"
```

## Cleanup

```bash
# Destroy infrastructure
terraform destroy

# Type 'yes' when prompted
```

## Next Steps

1. **Add More Hosts**: Scale horizontally by adding more VMs to inventory
2. **Use Ansible Roles**: Refactor playbook into reusable roles
3. **Add Ansible Vault**: Secure sensitive variables (API keys, passwords)
4. **CI/CD Integration**: Automate with GitHub Actions or GitLab CI
5. **Dynamic Inventory**: Use GCP dynamic inventory plugin

## Learning Resources

- [Ansible Documentation](https://docs.ansible.com/)
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [GCP Compute Engine](https://cloud.google.com/compute/docs)

## Key Concepts Demonstrated

1. **Infrastructure as Code (IaC)**: Using Terraform
2. **Configuration Management**: Using Ansible
3. **Service Management**: Systemd services
4. **Python Package Management**: Using uv
5. **Security**: SSH key-based authentication
6. **Networking**: Firewall rules and access control

---

**Note**: This is a teaching example. For production use, consider:
- Using Ansible Vault for secrets
- Implementing proper monitoring
- Adding backup strategies
- Using GCP managed services
- Implementing proper logging

# GCP Compute Hello World

Learn how to deploy a virtual machine with a web server on Google Cloud Platform using OpenTofu.

## What You'll Build

A Ubuntu VM running Apache web server, accessible via the internet with a public IP address.

---

## Prerequisites

- **Google Cloud Account** with billing enabled ([Get $300 free credits](https://cloud.google.com))
- **GCP Project** - Note your Project ID (e.g., `my-project-123456`)
- **Command line basics** - You'll run a few terminal commands

---

## Quick Start

### 1. Install Tools

```bash
# Install OpenTofu (infrastructure-as-code tool)
brew install opentofu

# Install Google Cloud SDK
brew install google-cloud-sdk

# Verify installations
tofu version
gcloud version
```

### 2. Authenticate

```bash
# Login to Google Cloud
gcloud auth login

# Set up credentials for OpenTofu
gcloud auth application-default login

# Set your project (replace with YOUR project ID)
gcloud config set project YOUR_PROJECT_ID

# Enable required APIs
gcloud services enable compute.googleapis.com
```

### 3. Configure

Edit `main.tf` and update your Project ID:

```terraform
project = "your-project-id"  # Replace with YOUR project ID
```

**Optional:** Change the VM name or machine type if desired (default is `e2-micro` which is free-tier eligible).

### 4. Deploy

```bash
# Initialize OpenTofu
tofu init

# Preview what will be created
tofu plan

# Create your VM and web server
tofu apply
# Type 'yes' when prompted
```

**Note:** This takes 2-3 minutes as the VM boots and installs Apache.

### 5. View Your Website

```bash
# Get your website URL
tofu output website_url
```

Copy the URL and open it in your browser. You should see "Hello from Google Cloud!" with the server hostname.

**Tip:** It may take 30-60 seconds after `tofu apply` completes for the web server to be fully ready.

### 6. Clean Up

**Important:** VMs cost money while running. Delete when done:

```bash
tofu destroy
# Type 'yes' when prompted
```

---

## What Just Happened?

- Created a custom VPC network for your VM
- Deployed an Ubuntu VM (`e2-micro` instance)
- Configured a firewall rule to allow HTTP (port 80) traffic
- Installed Apache web server automatically via startup script
- Assigned a public IP address to access your server

All defined as code in `main.tf` - reproducible and version-controllable!

---

## Understanding the Components

### `main.tf`
- **VPC Network:** Isolated network for your VM
- **Firewall Rule:** Allows HTTP traffic from anywhere
- **Compute Instance:** The actual VM running Ubuntu + Apache
- **Startup Script:** Runs `install_apache.sh` when VM boots

### `install_apache.sh`
- Updates the system packages
- Installs Apache web server
- Creates a simple HTML page with server info

### Costs

- **e2-micro:** ~$7/month if running 24/7 (or free in free tier)
- **Network egress:** Small amount for data transfer
- **Always run `tofu destroy`** when learning to avoid charges!

---

## Troubleshooting

**"Permission denied"**
- Run `gcloud auth application-default login` again
- Verify your Project ID in `main.tf` is correct

**"API not enabled"**
- Run: `gcloud services enable compute.googleapis.com`

**Website not loading**
- Wait 1-2 minutes for Apache to finish installing
- Check the firewall rule allows port 80
- Verify the VM is running in GCP Console

**"Quota exceeded"**
- You may have hit your region's VM quota
- Try a different region or request a quota increase

---

## Next Steps

- SSH into your VM: `gcloud compute ssh hello-world-instance --zone=us-central1-a`
- Modify `install_apache.sh` to install different software
- Change the machine type to a larger instance
- Add HTTPS with SSL certificates
- Deploy multiple VMs with a load balancer

---

## File Overview

- **`main.tf`** - Infrastructure definition (network, VM, firewall)
- **`install_apache.sh`** - Startup script that configures the web server
- **`index.html`** - Alternative HTML file (not used by default script)
- **`terraform.tfstate`** - Tracks resources (don't delete!)

## Advanced: Service Account Setup

For production/CI environments, use a service account:

<details>
<summary>Click to expand</summary>

```bash
# Create service account
gcloud iam service-accounts create tf-deployer \
  --display-name="Terraform Deployer"

# Grant compute permissions
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:tf-deployer@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/compute.admin"

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:tf-deployer@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser"

# Create key
gcloud iam service-accounts keys create key.json \
  --iam-account=tf-deployer@YOUR_PROJECT_ID.iam.gserviceaccount.com

# Use key
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/key.json"
```
</details>
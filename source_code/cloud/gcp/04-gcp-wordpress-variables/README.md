# GCP WordPress with Variables

Learn how to use OpenTofu variables to create a configurable WordPress deployment on Google Cloud Platform.

## What You'll Build

A complete WordPress website running on a GCP VM with MySQL database, using variables for flexible configuration across different environments.

---

## Prerequisites

- **Google Cloud Account** with billing enabled ([Get $300 free credits](https://cloud.google.com))
- **GCP Project** - Note your Project ID (e.g., `my-project-123456`)
- **Command line basics** - You'll run a few terminal commands

---

## Quick Start

### 1. Install Tools

```bash
# Install OpenTofu
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

# Set your project
gcloud config set project YOUR_PROJECT_ID

# Enable required APIs
gcloud services enable compute.googleapis.com
```

### 3. Configure Variables

Edit `terraform.tfvars` with your settings:

```hcl
gcp_project  = "your-project-id"  # Replace with YOUR project ID
environment  = "dev"               # dev, staging, or prod
machine_type = "e2-medium"         # VM size
db_password  = "change-this-password"  # Use a strong password
```

**Important:** Choose a strong database password!

### 4. Deploy

```bash
# Initialize OpenTofu
tofu init

# Preview what will be created
tofu plan

# Create your WordPress site
tofu apply
# Type 'yes' when prompted
```

**Note:** This takes 3-5 minutes as WordPress and MySQL are installed.

### 5. Access Your WordPress Site

```bash
# Get your WordPress URL
tofu output wordpress_url
```

Copy the URL and open it in your browser. You'll see the WordPress installation wizard.

**Complete the WordPress setup:**
1. Choose your language
2. Create an admin account
3. Start building your site!

### 6. Clean Up

**Important:** VMs cost money while running (~$15-30/month for e2-medium). Delete when done:

```bash
tofu destroy
# Type 'yes' when prompted
```

---

## Understanding Variables

Variables make your infrastructure reusable across different environments. This example shows:

### Available Variables

**Required:**
- `gcp_project` - Your GCP project ID

**Optional (with defaults):**
- `environment` - Environment name (default: `"dev"`)
- `machine_type` - VM size (default: `"e2-medium"`)
- `db_password` - Database password (default: `"mypassword123"` - change this!)

### Three Ways to Set Variables

**Option 1: terraform.tfvars file** (Recommended)
```hcl
gcp_project  = "my-project-123456"
environment  = "dev"
machine_type = "e2-medium"
db_password  = "secure-password-here"
```

**Option 2: Command line**
```bash
tofu apply -var="gcp_project=my-project-123456" -var="environment=prod"
```

**Option 3: Environment variables**
```bash
export TF_VAR_gcp_project="my-project-123456"
export TF_VAR_environment="production"
tofu apply
```

---

## Multiple Environments Example

Create different configurations for dev and production:

### Development (terraform.tfvars.dev)
```hcl
gcp_project  = "your-project-id"
environment  = "dev"
machine_type = "e2-micro"      # Smaller, cheaper
db_password  = "dev-password"
```

### Production (terraform.tfvars.prod)
```hcl
gcp_project  = "your-project-id"
environment  = "prod"
machine_type = "e2-standard-2" # Larger, more powerful
db_password  = "prod-strong-password"
```

**Deploy specific environment:**
```bash
# Deploy dev
tofu apply -var-file="terraform.tfvars.dev"

# Deploy prod
tofu apply -var-file="terraform.tfvars.prod"
```

---

## What Just Happened?

- Created a VM with the machine type you specified
- Installed WordPress and MySQL automatically
- Used variables to make configuration flexible
- Named resources with environment prefix (e.g., `dev-wordpress`)
- Made the same code work for dev, staging, and production

**Key benefit:** Change one variable to deploy to different environments or VM sizes!

---

## Machine Type Guide

Choose based on your needs and budget:

| Type | vCPUs | Memory | Cost/Month* | Use Case |
|------|-------|--------|-------------|----------|
| e2-micro | 0.25-2 | 1 GB | ~$7 | Testing only |
| e2-small | 0.5-2 | 2 GB | ~$14 | Light blogs |
| e2-medium | 1-2 | 4 GB | ~$28 | Standard WordPress |
| e2-standard-2 | 2 | 8 GB | ~$50 | High traffic sites |

*Approximate monthly costs if running 24/7

---

## Troubleshooting

**"Variable not defined"**
- Make sure `terraform.tfvars` exists and has `gcp_project` set
- Or pass variables via command line

**"Permission denied"**
- Run `gcloud auth application-default login`
- Verify project ID is correct in `terraform.tfvars`

**WordPress not loading**
- Wait 5 minutes for installation to complete
- Check: `gcloud compute ssh dev-wordpress --zone=us-central1-a`
- View logs: `sudo tail -f /var/log/cloud-init-output.log`

**"Quota exceeded"**
- Try a smaller machine type (e2-micro, e2-small)
- Or change to a different region

---

## Security Best Practices

1. **Change default password** - Never use `mypassword123` in production
2. **Use strong passwords** - Mix uppercase, lowercase, numbers, symbols
3. **Restrict access** - Modify firewall rules to limit who can access your site
4. **Update regularly** - Keep WordPress and plugins updated
5. **Use secrets management** - Consider Google Secret Manager for passwords

---

## Next Steps

- Add more variables (disk size, region, zone)
- Create validation rules for variables
- Use `sensitive = true` for all passwords
- Add outputs for database connection info
- Deploy multiple environments simultaneously
- Learn about variable types (string, number, bool, list, map)

---

## File Overview

- **`main.tf`** - Infrastructure definition using variables
- **`variables.tf`** - Variable declarations and defaults
- **`terraform.tfvars`** - Your variable values (customize this)
- **`install_wordpress.sh`** - WordPress installation script
- **`terraform.tfstate`** - Tracks resources (don't delete!)

## Advanced: Service Account Setup

For production/CI environments, use a service account:

<details>
<summary>Click to expand</summary>

```bash
# Create service account
gcloud iam service-accounts create tf-deployer \
  --display-name="Terraform Deployer"

# Grant permissions
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
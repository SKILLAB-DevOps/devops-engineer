# GCP WordPress

Learn how to deploy a complete WordPress site on Google Cloud Platform using OpenTofu.

## What You'll Build

A fully functional WordPress website with Apache web server and MySQL database, all running on a single GCP VM.

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

**Note:** This takes 3-5 minutes as the LAMP stack (Linux, Apache, MySQL, PHP) and WordPress are installed.

### 5. Access Your WordPress Site

```bash
# Get your WordPress URL
tofu output wordpress_url
```

Copy the URL and open it in your browser. You'll see the WordPress installation wizard.

### 6. Complete WordPress Setup

Follow the 5-minute WordPress installer:

1. **Choose language** - Select your preferred language
2. **Site information:**
   - Site Title: Your site name
   - Username: Choose an admin username
   - Password: Create a strong password
   - Email: Your email address
3. Click **Install WordPress**
4. Login and start building your site!

**Note:** You don't need to manually enter database credentials - they're already configured in the installation script.

### 7. Clean Up

**Important:** e2-medium VMs cost ~$28/month if running 24/7. Delete when done:

```bash
tofu destroy
# Type 'yes' when prompted
```

---

## What Just Happened?

- Created a VM running Ubuntu 22.04 LTS
- Installed Apache web server
- Installed MySQL database server
- Installed PHP and required extensions
- Downloaded and configured WordPress
- Created database and user automatically
- Configured firewall to allow HTTP traffic
- Assigned a public IP address

All automated with a startup script!

---

## Pre-configured Database Details

The installation script automatically sets up:

- **Database Name:** `wordpress`
- **Database User:** `wpuser`
- **Database Password:** `password123`
- **Database Host:** `localhost`

**Security Warning:** These credentials are hardcoded in the installation script. For production, use strong passwords and consider Google Secret Manager.

---

## What's Installed

### Server Stack (LAMP)
- **Linux:** Ubuntu 22.04 LTS
- **Apache:** Web server (version 2.4)
- **MySQL:** Database server (version 8.0)
- **PHP:** Scripting language (version 8.1)

### WordPress
- Latest stable version
- Pre-configured with database connection
- Ready for the 5-minute installer

---

## Troubleshooting

**"Permission denied"**
- Run `gcloud auth application-default login` again
- Verify your Project ID in `main.tf` is correct

**"API not enabled"**
- Run: `gcloud services enable compute.googleapis.com`

**WordPress not loading**
- Wait 5 minutes for full installation
- Check installation status: `gcloud compute ssh wordpress-instance --zone=us-central1-a`
- View logs: `sudo tail -f /var/log/cloud-init-output.log`

**Seeing Apache default page**
- The installation may still be running
- Wait another 2-3 minutes and refresh

**Database connection error**
- SSH into the VM and check MySQL is running: `sudo systemctl status mysql`
- Check the logs: `sudo tail -f /var/log/syslog`

---

## Connecting to Your VM

```bash
# SSH into the instance
gcloud compute ssh wordpress-instance --zone=us-central1-a

# Check Apache status
sudo systemctl status apache2

# Check MySQL status
sudo systemctl status mysql

# View WordPress files
ls -la /var/www/html/

# Check installation logs
sudo tail -f /var/log/cloud-init-output.log
```

---

## Cost Information

**e2-medium VM:**
- ~$28/month if running 24/7
- ~$0.038/hour
- Includes 2 vCPUs and 4 GB RAM

**Ways to save:**
- Use `e2-micro` for testing (cheaper but slower)
- Stop the VM when not in use (you still pay for disk storage)
- Always `tofu destroy` when done learning

---

## Next Steps

Once your site is running:
1. **Install a theme** - Change your site's appearance
2. **Add plugins** - Extend functionality (SEO, backups, security)
3. **Create content** - Add posts and pages
4. **Configure permalinks** - Settings → Permalinks
5. **Set up SSL** - Add HTTPS for security (requires domain)
6. **Regular backups** - Use a backup plugin

---

## Security Improvements for Production

This setup is for learning. For production:

1. **Change database password** - Edit `install_wordpress.sh` before deploying
2. **Use HTTPS** - Add SSL certificate (Let's Encrypt)
3. **Restrict access** - Limit firewall to specific IPs
4. **Update regularly** - Keep WordPress, themes, and plugins updated
5. **Use strong credentials** - For WordPress admin
6. **Add security plugins** - Wordfence, iThemes Security, etc.
7. **Database backups** - Automate regular backups
8. **Use Cloud SQL** - Managed database instead of local MySQL

---

## File Overview

- **`main.tf`** - Infrastructure definition (VM, firewall)
- **`install_wordpress.sh`** - Startup script that installs everything
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
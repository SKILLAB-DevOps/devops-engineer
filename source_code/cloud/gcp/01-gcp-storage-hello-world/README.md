# GCP Storage Hello World

Learn how to host a simple static website on Google Cloud Storage using OpenTofu.

## What You'll Build

A "Hello World" webpage that's publicly accessible on the internet, hosted on Google Cloud Storage.

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

# Enable Cloud Storage API
gcloud services enable storage.googleapis.com
```

### 3. Configure

Edit `main.tf` and update two things:

**1. Your Project ID:**
```terraform
project = "your-project-id"  # Replace with YOUR project ID
```

**2. Your Bucket Name** (must be globally unique):
```terraform
name = "my-hello-world-website-bucket-12345"  # Change to something unique
```

**Tip:** Use your name + date, like `hello-world-sarah-20251007`

### 4. Deploy

```bash
# Initialize OpenTofu
tofu init

# Preview what will be created
tofu plan

# Create your website
tofu apply
# Type 'yes' when prompted
```

### 5. View Your Website

```bash
# Get your website URL
tofu output website_url
```

Copy the URL and open it in your browser. You should see "Hello, World!"

### 6. Clean Up

When done, delete everything to avoid charges:

```bash
tofu destroy
# Type 'yes' when prompted
```

---

## What Just Happened?

- Created a Cloud Storage bucket configured for website hosting
- Uploaded `index.html` and `error.html` to the bucket
- Made the files publicly readable
- Got a public URL to access your site

All defined as code in `main.tf` - no manual clicking in the console!

---

## Troubleshooting

**"Bucket name already exists"**
- Change the bucket name in `main.tf` to something more unique

**"Permission denied"**
- Run `gcloud auth application-default login` again
- Verify your Project ID in `main.tf` is correct

**"API not enabled"**
- Run: `gcloud services enable storage.googleapis.com`

---

## Next Steps

- Edit `index.html` and run `tofu apply` to see your changes
- Add CSS styling to your webpage
- Create additional pages
- Explore other GCP services with OpenTofu

---

## File Overview

- **`main.tf`** - Infrastructure definition (bucket, files, permissions)
- **`index.html`** - Your main webpage
- **`error.html`** - Custom 404 page
- **`terraform.tfstate`** - Tracks resources (don't delete!)

## Advanced: Service Account Setup

For production/CI environments, use a service account instead of user credentials:

<details>
<summary>Click to expand</summary>

```bash
# Create service account
gcloud iam service-accounts create tf-deployer \
  --display-name="Terraform Deployer"

# Grant permissions
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:tf-deployer@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/storage.admin"

# Create key
gcloud iam service-accounts keys create key.json \
  --iam-account=tf-deployer@YOUR_PROJECT_ID.iam.gserviceaccount.com

# Use key
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/key.json"
```
</details>
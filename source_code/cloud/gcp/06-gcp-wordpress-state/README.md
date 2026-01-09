# GCP WordPress with Remote State

Store Terraform state in Google Cloud Storage for team sharing.

## Setup

1. Edit `main.tf` and replace `"your-project-id"` with your GCP project ID
2. Change the bucket name to something unique: `"my-terraform-state-bucket-12345"`

## First time deployment

```bash
# Deploy with local state first
terraform init
terraform apply

# Then enable remote state (uncomment the backend block in main.tf)
# terraform init -migrate-state
```

## What this creates

- WordPress site (same as basic example)
- Cloud Storage bucket for storing Terraform state
- State versioning enabled (keeps backup copies)

## Why use remote state?

- **Team collaboration**: Multiple people can work on the same infrastructure
- **State locking**: Prevents conflicts when multiple people run Terraform
- **Backup**: State is safely stored in the cloud
- **Versioning**: Can recover from mistakes

## Access your site

```bash
terraform output wordpress_url
```

## Clean up

```bash
terraform destroy
```
# GCP WordPress with HTTPS

WordPress with SSL certificate (self-signed for demo).

## Setup

1. Edit `main.tf` and replace `"your-project-id"` with your GCP project ID
2. Run these commands:

```bash
terraform init
terraform apply
```

## What it creates

- WordPress with Apache and MySQL
- Static IP address (doesn't change)
- Self-signed SSL certificate
- HTTP redirects to HTTPS

## Access your site

```bash
# HTTPS (will show security warning - click "Advanced" -> "Proceed")
terraform output wordpress_url_https

# HTTP (redirects to HTTPS)
terraform output wordpress_url_http
```

## Note

The self-signed certificate will show a browser security warning. This is normal for demo purposes. In production, use a real SSL certificate from Let's Encrypt or a Certificate Authority.

## Clean up

```bash
terraform destroy
```
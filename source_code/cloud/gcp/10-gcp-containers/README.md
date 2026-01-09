# GCP Containers (Docker)

Learn containerization by running Docker containers on Google Cloud.

## Setup

1. Edit `main.tf` and replace `"your-project-id"` with your GCP project ID
2. Run these commands:

```bash
terraform init
terraform apply
```

## What this creates

- VM with Container-Optimized OS (designed for containers)
- Two Docker containers:
  - **NGINX container** serving web page (port 80)
  - **Node.js container** serving API (port 8080)
- Docker Compose to manage multiple containers

## Test the containerized app

1. **Visit the web app:**
   ```bash
   terraform output web_app_url
   ```

2. **Test the API directly:**
   ```bash
   terraform output api_url
   ```

3. **Check running containers (SSH into VM):**
   ```bash
   gcloud compute ssh container-vm --zone=us-central1-a
   docker ps
   docker-compose ps
   ```

## Learning concepts

- **Containerization**: Applications packaged with their dependencies
- **Microservices**: Web frontend and API backend as separate containers
- **Container Orchestration**: Docker Compose manages multiple containers
- **Isolation**: Each container runs independently
- **Portability**: Same containers work anywhere Docker runs

## Container commands to try

```bash
# SSH into the VM first
gcloud compute ssh container-vm --zone=us-central1-a

# View running containers
docker ps

# Check container logs
docker-compose logs web
docker-compose logs api

# Restart containers
docker-compose restart

# Scale the API container
docker-compose up -d --scale api=3
```

## Clean up

```bash
terraform destroy
```
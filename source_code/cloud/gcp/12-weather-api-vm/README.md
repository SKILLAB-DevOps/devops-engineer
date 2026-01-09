# Weather API - VM Deployment

Deploy the FastAPI Weather API on Google Compute Engine VM.

## Setup

1. **Edit `main.tf`** and replace `"your-project-id"` with your GCP project ID

2. **Deploy the VM:**
   ```bash
   terraform init
   terraform apply
   ```

## What this creates

- **Compute Engine VM** running Ubuntu 22.04
- **Firewall rule** allowing traffic on port 8000
- **Python environment** with FastAPI, uvicorn, and httpx
- **Systemd service** for automatic startup and restarts

## Test the API

1. **Get the VM IP:**
   ```bash
   terraform output vm_external_ip
   ```

2. **Test endpoints:**
   ```bash
   # Root endpoint
   curl $(terraform output -raw api_url)
   
   # Health check
   curl $(terraform output -raw health_check_url)
   
   # Weather for London
   curl $(terraform output -raw weather_example_url)
   
   # Weather for any city
   curl "$(terraform output -raw api_url)/weather/Tokyo"
   ```

## VM Management

```bash
# SSH into the VM
gcloud compute ssh weather-api-vm --zone=us-central1-a

# Check service status
sudo systemctl status weather-api

# View logs
sudo journalctl -u weather-api -f

# Restart service
sudo systemctl restart weather-api
```

## Pros of VM Deployment
- Full control over the environment
- Can install any dependencies
- Persistent storage
- Easy debugging and troubleshooting
- Cost-effective for steady workloads

## Cons of VM Deployment
- Manual scaling required
- No automatic failover
- OS maintenance required
- Always running (costs even when idle)

## Clean up

```bash
terraform destroy
```
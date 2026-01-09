# GCP Auto Scaling

Learn auto scaling - automatically add/remove servers based on demand.

## Setup

1. Edit `main.tf` and replace `"your-project-id"` with your GCP project ID
2. Run these commands:

```bash
terraform init
terraform apply  # This takes ~5 minutes to complete
```

## What this creates

- Instance template (blueprint for new servers)
- Managed instance group (starts with 2 servers)
- Auto scaler (scales 2-5 servers based on CPU)
- Global load balancer
- Health checks

## Test auto scaling

1. **Visit your site:**
   ```bash
   terraform output load_balancer_ip
   ```

2. **Check current instances:**
   ```bash
   gcloud compute instances list --filter="name~web-server"
   ```

3. **Trigger scaling (SSH into servers and run):**
   ```bash
   # This maxes out CPU to trigger scaling
   stress --cpu 2 --timeout 300s
   ```

4. **Watch scaling happen:**
   ```bash
   # Check again in 2-3 minutes
   gcloud compute instances list --filter="name~web-server"
   ```

## Learning concepts

- **Elastic Infrastructure**: Servers appear/disappear based on demand
- **Cost Optimization**: Only pay for what you need
- **High Availability**: Always have minimum number of servers
- **Performance**: Add capacity automatically during traffic spikes

## Clean up

```bash
terraform destroy
```
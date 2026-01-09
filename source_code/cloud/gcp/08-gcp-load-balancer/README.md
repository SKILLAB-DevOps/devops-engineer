# GCP Load Balancer

Learn load balancing by distributing traffic across multiple web servers.

## Setup

1. Edit `main.tf` and replace `"your-project-id"` with your GCP project ID
2. Run these commands:

```bash
terraform init
terraform apply
```

## What this creates

- 2 web server instances (identical)
- Health check to monitor server status
- Load balancer to distribute traffic
- Each server shows its ID so you can see load balancing

## Test load balancing

```bash
# Get the load balancer IP
terraform output load_balancer_ip

# Visit the IP in your browser and refresh multiple times
# You'll see different server IDs (Server #1, Server #2)
```

## Learning concepts

- **High Availability**: If one server fails, traffic goes to the other
- **Scalability**: Easy to add more servers
- **Health Checks**: Automatic detection of unhealthy servers
- **Traffic Distribution**: Requests spread across multiple servers

## Clean up

```bash
terraform destroy
```
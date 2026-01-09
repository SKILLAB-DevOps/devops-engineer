# Weather API - Container Deployment (GKE)

Deploy the FastAPI Weather API on Google Kubernetes Engine with auto-scaling and load balancing.

## Setup

1. **Edit `main.tf`** and replace `"your-project-id"` with your GCP project ID

2. **Make deploy script executable:**
   ```bash
   chmod +x deploy.sh
   ```

3. **Deploy everything:**
   ```bash
   ./deploy.sh
   ```

   This will:
   - Create GKE cluster (2 nodes)
   - Build and push container image
   - Deploy the application with 3 replicas
   - Set up auto-scaling (2-10 pods)
   - Create LoadBalancer service

## What this creates

### GKE Cluster:
- **2 e2-small nodes** in us-central1-a
- **Network policies** enabled for security

### Kubernetes Resources:
- **Deployment**: 3 replicas of the Weather API
- **Service**: LoadBalancer exposing the app on port 80
- **HorizontalPodAutoscaler**: Auto-scales based on CPU usage (70% threshold)
- **Resource limits**: 256Mi memory, 200m CPU per pod
- **Health checks**: Liveness and readiness probes

## Test the API

```bash
# Get the LoadBalancer IP
kubectl get service weather-api-service

# Test endpoints
EXTERNAL_IP=$(kubectl get service weather-api-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

curl http://$EXTERNAL_IP/
curl http://$EXTERNAL_IP/health
curl http://$EXTERNAL_IP/weather/London
curl http://$EXTERNAL_IP/weather/Tokyo
```

## Kubernetes Management

### View Resources:
```bash
# Check pods and their status
kubectl get pods -o wide

# Check services
kubectl get services

# Check auto-scaler status
kubectl get hpa

# View deployment details
kubectl describe deployment weather-api
```

### Scaling:
```bash
# Manual scaling
kubectl scale deployment weather-api --replicas=5

# Watch auto-scaling in action
kubectl get hpa weather-api-hpa -w

# Generate load to trigger auto-scaling
for i in {1..1000}; do curl http://$EXTERNAL_IP/weather/TestCity$i; done
```

### Logs and Debugging:
```bash
# View logs from all pods
kubectl logs -l app=weather-api

# View logs from specific pod
kubectl logs <pod-name>

# Execute commands in a pod
kubectl exec -it <pod-name> -- /bin/bash

# Port forward for local testing
kubectl port-forward service/weather-api-service 8080:80
```

### Updates and Rollbacks:
```bash
# Update the application (after code changes)
gcloud builds submit --tag gcr.io/$(gcloud config get-value project)/weather-api:v2
kubectl set image deployment/weather-api weather-api=gcr.io/$(gcloud config get-value project)/weather-api:v2

# Check rollout status
kubectl rollout status deployment/weather-api

# Rollback if needed
kubectl rollout undo deployment/weather-api
```

## Pros of Container Orchestration (GKE)
- ✅ **Auto-scaling**: Scales pods based on CPU/memory usage
- ✅ **Self-healing**: Automatically restarts failed containers
- ✅ **Load distribution**: Traffic balanced across healthy pods
- ✅ **Rolling updates**: Zero-downtime deployments
- ✅ **Resource management**: Guaranteed CPU/memory per pod
- ✅ **Service discovery**: Built-in DNS for inter-service communication
- ✅ **Health monitoring**: Automatic health checks and recovery

## Cons of Container Orchestration
- ❌ **Complexity**: More moving parts to manage
- ❌ **Learning curve**: Kubernetes concepts and kubectl commands
- ❌ **Cost**: Always-running cluster nodes (even when idle)
- ❌ **Overhead**: Management layer adds some performance overhead

## Architecture Overview

```
Internet → LoadBalancer → Service → Pods (3 replicas)
                                  ↓
                          HorizontalPodAutoscaler
                          (scales 2-10 pods based on CPU)
```

## Auto-scaling Configuration

- **Min replicas**: 2 (always running for high availability)
- **Max replicas**: 10 (prevents runaway scaling)
- **CPU threshold**: 70% (triggers scaling up/down)
- **Resource requests**: 100m CPU, 128Mi memory
- **Resource limits**: 200m CPU, 256Mi memory

## Clean up

```bash
# Delete Kubernetes resources
kubectl delete -f k8s-manifest.yaml

# Destroy the cluster
terraform destroy
```

**⚠️ Important**: GKE clusters cost money for the nodes even when idle. Always clean up when done learning!
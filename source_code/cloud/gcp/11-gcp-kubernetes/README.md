# GCP Kubernetes (GKE) - Final Step! 

Learn container orchestration at scale with Google Kubernetes Engine.

## Setup

1. **Edit `main.tf`** and replace `"your-project-id"` with your GCP project ID

2. **Create the cluster:**
   ```bash
   terraform init
   terraform apply
   ```

3. **Deploy the app:**
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

## What this creates

- **GKE Cluster**: Managed Kubernetes cluster on GCP  
- **2 Pod Replicas**: Your app runs on multiple containers automatically
- **Load Balancer**: Google Cloud Load Balancer distributes traffic
- **ConfigMap**: Configuration stored separately from application code
- **Service**: Exposes your app to the internet

## Test your Kubernetes app

1. **Visit your app:**
   ```bash
   kubectl get service web-app-service
   # Use the EXTERNAL-IP shown
   ```

2. **Watch your pods:**
   ```bash
   kubectl get pods -w
   ```

3. **Scale your app:**
   ```bash
   kubectl scale deployment web-app --replicas=5
   kubectl get pods
   ```

4. **View logs from all pods:**
   ```bash
   kubectl logs -l app=web-app
   ```

## Kubernetes concepts learned

- **Orchestration**: Kubernetes manages containers across multiple machines
- **Deployments**: Declarative way to manage application replicas
- **Services**: Stable network endpoint for your pods
- **ConfigMaps**: Store configuration separate from code
- **Load Balancing**: Traffic automatically distributed across healthy pods
- **Self-healing**: Kubernetes restarts failed containers automatically
- **Scaling**: Easy horizontal scaling with single commands

## Kubernetes commands to try

```bash
# View cluster info
kubectl cluster-info

# See all resources
kubectl get all

# Describe a pod (pick one from 'kubectl get pods')
kubectl describe pod <pod-name>

# Test self-healing (delete a pod, watch it recreate)
kubectl delete pod <pod-name>
kubectl get pods -w

# Update the app (change replicas)
kubectl patch deployment web-app -p '{"spec":{"replicas":3}}'

# Port forward to test locally
kubectl port-forward service/web-app-service 8080:80
# Then visit http://localhost:8080
```

## Learning Journey Complete! 🎉

You've now mastered the full DevOps progression:

1. **01-gcp-storage**: Static websites on Cloud Storage
2. **02-gcp-compute**: Virtual machines and basic web servers  
3. **03-gcp-wordpress**: Full web applications with databases
4. **04-gcp-wordpress-variables**: Infrastructure parameterization
5. **05-gcp-wordpress-https**: SSL certificates and security
6. **06-gcp-wordpress-state**: Remote state management
7. **07-gcp-wordpress-modules**: Modular infrastructure design
8. **08-gcp-load-balancer**: High availability with load balancing
9. **09-gcp-auto-scaling**: Elastic infrastructure that scales with demand
10. **10-gcp-containers**: Docker containerization
11. **11-gcp-kubernetes**: Container orchestration at scale ← You are here!

## Clean up

```bash
# Delete Kubernetes resources
kubectl delete -f app.yaml

# Destroy the cluster
terraform destroy
```

**⚠️ Important**: GKE clusters cost money even when idle. Always clean up when done learning!
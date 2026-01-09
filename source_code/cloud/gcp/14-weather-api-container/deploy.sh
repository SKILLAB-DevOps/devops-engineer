#!/bin/bash

echo "🚀 Deploying Weather API to Kubernetes..."

# Get project ID
PROJECT_ID=$(gcloud config get-value project)

if [ -z "$PROJECT_ID" ]; then
    echo "Error: No project ID found. Run 'gcloud config set project YOUR_PROJECT_ID'"
    exit 1
fi

echo "Using project: $PROJECT_ID"

# Step 1: Create GKE cluster with Terraform
echo "Creating GKE cluster..."
terraform init
terraform apply -auto-approve

if [ $? -ne 0 ]; then
    echo "❌ Cluster creation failed"
    exit 1
fi

# Step 2: Get cluster credentials
echo "Getting cluster credentials..."
CLUSTER_NAME=$(terraform output -raw cluster_name)
CLUSTER_LOCATION=$(terraform output -raw cluster_location)
gcloud container clusters get-credentials $CLUSTER_NAME --zone=$CLUSTER_LOCATION

# Step 3: Build and push container image
echo "Building container image..."
gcloud builds submit --tag gcr.io/$PROJECT_ID/weather-api:latest

if [ $? -ne 0 ]; then
    echo "❌ Container build failed"
    exit 1
fi

# Step 4: Update manifest with project ID
echo "Updating Kubernetes manifest..."
sed "s/PROJECT_ID/$PROJECT_ID/g" k8s-manifest.yaml > k8s-manifest-updated.yaml

# Step 5: Deploy to Kubernetes
echo "Deploying to Kubernetes..."
kubectl apply -f k8s-manifest-updated.yaml

# Step 6: Wait for deployment
echo "Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/weather-api

# Step 7: Wait for LoadBalancer IP
echo "Waiting for LoadBalancer IP (this may take a few minutes)..."
kubectl wait --for=jsonpath='{.status.loadBalancer.ingress}' service/weather-api-service --timeout=300s

# Get the external IP
EXTERNAL_IP=$(kubectl get service weather-api-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo ""
echo "🎉 Kubernetes deployment successful!"
echo ""
echo "🌍 Service URL: http://$EXTERNAL_IP"
echo "🏥 Health check: http://$EXTERNAL_IP/health"
echo "🌤️  Weather example: http://$EXTERNAL_IP/weather/London"
echo ""
echo "📊 View deployment:"
echo "  kubectl get pods"
echo "  kubectl get services"
echo "  kubectl get hpa"
echo ""
echo "🔍 Monitor scaling:"
echo "  kubectl get hpa weather-api-hpa -w"
echo ""

# Clean up temporary file
rm -f k8s-manifest-updated.yaml
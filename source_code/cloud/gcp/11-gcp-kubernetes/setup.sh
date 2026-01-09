#!/bin/bash

echo "🚀 Setting up Kubernetes cluster..."

# Get cluster credentials
gcloud container clusters get-credentials learning-cluster --zone=us-central1-a

echo "📦 Deploying application to Kubernetes..."

# Deploy the application
kubectl apply -f app.yaml

echo "⏳ Waiting for deployment to be ready..."

# Wait for deployment to be ready
kubectl wait --for=condition=available --timeout=300s deployment/web-app

echo "🌐 Getting external IP address..."

# Wait for LoadBalancer to get external IP
echo "Waiting for LoadBalancer IP (this may take a few minutes)..."
kubectl wait --for=jsonpath='{.status.loadBalancer.ingress}' service/web-app-service --timeout=300s

# Get the external IP
EXTERNAL_IP=$(kubectl get service web-app-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo ""
echo "✅ Kubernetes deployment complete!"
echo ""
echo "🌍 Your app is available at: http://$EXTERNAL_IP"
echo ""
echo "📊 Useful commands:"
echo "  kubectl get pods                 # See running pods"
echo "  kubectl get services             # See services"
echo "  kubectl logs -l app=web-app      # View app logs"
echo "  kubectl scale deployment web-app --replicas=5    # Scale to 5 pods"
echo ""
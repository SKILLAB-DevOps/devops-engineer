#!/bin/bash

echo "Building and deploying Weather API to Cloud Run..."

# Get project ID
PROJECT_ID=$(gcloud config get-value project)

if [ -z "$PROJECT_ID" ]; then
    echo "Error: No project ID found. Run 'gcloud config set project YOUR_PROJECT_ID'"
    exit 1
fi

echo "Using project: $PROJECT_ID"

# Enable required APIs
echo "Enabling required APIs..."
gcloud services enable run.googleapis.com
gcloud services enable cloudbuild.googleapis.com

# Build and submit the container image
echo "Building container image..."
gcloud builds submit --tag gcr.io/$PROJECT_ID/weather-api:latest

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "Container image built successfully!"
    
    # Now run terraform to deploy
    echo "Deploying to Cloud Run with Terraform..."
    terraform init
    terraform apply -auto-approve
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "Deployment successful!"
        echo ""
        echo "Service URL: $(terraform output -raw service_url)"
        echo "Health check: $(terraform output -raw health_check_url)"
        echo "Weather example: $(terraform output -raw weather_example_url)"
    else
        echo "Terraform deployment failed"
        exit 1
    fi
else
    echo "Container build failed"
    exit 1
fi
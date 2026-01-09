#!/bin/bash
# Easy deployment script for Star Wars API Data Collector

set -e

# Configuration - CHANGE THESE VALUES
PROJECT_ID="${1:-your-project-id}"
REGION="${2:-us-central1}"
SERVICE_NAME="star-wars-collector"
BUCKET_NAME="star-wars-data-${PROJECT_ID}"

echo "Deploying Star Wars API Data Collector to Cloud Run"
echo "=================================================="
echo "Project: ${PROJECT_ID}"
echo "Region: ${REGION}" 
echo "Service: ${SERVICE_NAME}"
echo "Bucket: ${BUCKET_NAME}"
echo ""

# Check if project ID was provided
if [ "$PROJECT_ID" = "your-project-id" ]; then
    echo "Error: Please provide your Google Cloud Project ID"
    echo "Usage: ./deploy.sh YOUR_PROJECT_ID [REGION]"
    echo "Example: ./deploy.sh my-gcp-project us-central1"
    exit 1
fi

# Set the project
echo "Setting up Google Cloud Project..."
gcloud config set project "${PROJECT_ID}"

# Enable required APIs
echo "Enabling required APIs..."
gcloud services enable run.googleapis.com
gcloud services enable storage.googleapis.com
gcloud services enable cloudbuild.googleapis.com

# Create Cloud Storage bucket
echo "Creating Cloud Storage bucket..."
gsutil mb -p "${PROJECT_ID}" -c STANDARD -l "${REGION}" "gs://${BUCKET_NAME}" 2>/dev/null || echo "Bucket already exists"

# Make bucket publicly readable for this demo (remove in production)
gsutil iam ch allUsers:objectViewer "gs://${BUCKET_NAME}" 2>/dev/null || echo "Bucket permissions already set"

# Deploy to Cloud Run
echo "Deploying to Cloud Run..."
gcloud run deploy "${SERVICE_NAME}" \
    --source . \
    --platform managed \
    --region "${REGION}" \
    --allow-unauthenticated \
    --port 8080 \
    --memory 512Mi \
    --cpu 1 \
    --concurrency 80 \
    --max-instances 10 \
    --timeout 300 \
    --set-env-vars "BUCKET_NAME=${BUCKET_NAME}" \
    --set-env-vars "GOOGLE_CLOUD_PROJECT=${PROJECT_ID}"

# Get the service URL
SERVICE_URL=$(gcloud run services describe "${SERVICE_NAME}" --platform managed --region "${REGION}" --format 'value(status.url)')

echo ""
echo "Deployment completed successfully!"
echo "================================="
echo "Service URL: ${SERVICE_URL}"
echo "API Docs: ${SERVICE_URL}/docs"
echo "Health Check: ${SERVICE_URL}/health"
echo "Storage Bucket: gs://${BUCKET_NAME}"
echo ""
echo "Star Wars API Tests:"
echo "curl ${SERVICE_URL}/star-wars/endpoints"
echo ""
echo "Quick collect Star Wars characters:"
echo "curl ${SERVICE_URL}/star-wars/people"
echo ""
echo "Comprehensive data collection:"
echo "curl -X POST ${SERVICE_URL}/star-wars/collect \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"endpoints\": [\"people\", \"planets\"], \"max_items\": 3}'"
echo ""
echo "View collected data:"
echo "gsutil ls gs://${BUCKET_NAME}/"
echo ""
echo "Download and explore data:"
echo "gsutil cp gs://${BUCKET_NAME}/collections/*.json ."
echo "  -d '{\"endpoints\": [\"people\", \"planets\", \"starships\"], \"max_items_per_endpoint\": 3}'"
echo ""
echo "Get latest collection:"
echo "curl ${SERVICE_URL}/star-wars/latest"
echo ""
echo "Save custom Star Wars data:"
echo "curl -X POST ${SERVICE_URL}/storage/save \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"favorite_jedi\": \"Yoda\", \"favorite_quote\": \"Do or do not, there is no try\"}'"
echo ""
echo "View collected Star Wars data:"
echo "gsutil ls -r gs://${BUCKET_NAME}/star-wars-collections/"
echo ""
echo "Download and explore data:"
echo "gsutil cp gs://${BUCKET_NAME}/star-wars-collections/*.json ."
echo "cat *.json | jq '.collection_info'"
echo ""
echo "Deployment completed successfully!"
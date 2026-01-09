#!/bin/bash
# Easy deployment script for Google Cloud Workflows - Star Wars API Data Collector

set -e

# Configuration - CHANGE THESE VALUES
PROJECT_ID="${1:-your-project-id}"
REGION="${2:-us-central1}"
WORKFLOW_NAME="star-wars-collector"
BUCKET_NAME="star-wars-data-${PROJECT_ID}"

echo "Deploying Star Wars API Data Collector to Google Cloud"
echo "====================================================="
echo "Project: ${PROJECT_ID}"
echo "Region: ${REGION}"
echo "Workflow: ${WORKFLOW_NAME}"
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
gcloud services enable workflows.googleapis.com
gcloud services enable storage.googleapis.com

# Create Cloud Storage bucket
echo "Creating Cloud Storage bucket..."
gsutil mb -p "${PROJECT_ID}" -c STANDARD -l "${REGION}" "gs://${BUCKET_NAME}" 2>/dev/null || echo "Bucket already exists"

# Deploy the workflow (using default service account)
echo "Deploying Star Wars data collector workflow..."
gcloud workflows deploy "${WORKFLOW_NAME}" \
    --source=simple-scraper-workflow.yaml \
    --location="${REGION}"

echo ""
echo "Deployment completed successfully!"
echo "================================="
echo "Workflow: ${WORKFLOW_NAME}"
echo "Location: ${REGION}"
echo "Storage Bucket: gs://${BUCKET_NAME}"
echo ""
echo "Test the workflow with Star Wars characters:"
echo "gcloud workflows run ${WORKFLOW_NAME} \\"
echo "    --location=${REGION} \\"
echo "    --data='{\"endpoints\": [\"people\"], \"bucket\": \"${BUCKET_NAME}\"}'"
echo ""
echo "Test with multiple Star Wars data types:"
echo "gcloud workflows run ${WORKFLOW_NAME} \\"
echo "    --location=${REGION} \\"
echo "    --data='{\"endpoints\": [\"people\", \"planets\"], \"bucket\": \"${BUCKET_NAME}\"}'"
echo ""
echo "View results:"
echo "gsutil ls gs://${BUCKET_NAME}/"
echo ""
echo "Download and explore data:"
echo "gsutil cp gs://${BUCKET_NAME}/star_wars_data_*.json ."
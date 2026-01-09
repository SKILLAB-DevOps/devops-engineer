#!/bin/bash
# Test script for Google Cloud Workflows - Star Wars API Data Collection

set -e

# Configuration - CHANGE THESE VALUES
PROJECT_ID="${1:-your-project-id}"
REGION="${2:-us-central1}"
WORKFLOW_NAME="star-wars-collector"
BUCKET_NAME="star-wars-data-${PROJECT_ID}"

echo "Testing Star Wars API Data Collection Workflow"
echo "================================================"
echo "Project: ${PROJECT_ID}"
echo "Region: ${REGION}"
echo "Workflow: ${WORKFLOW_NAME}"
echo "Bucket: ${BUCKET_NAME}"
echo ""

# Check if project ID was provided
if [ "$PROJECT_ID" = "your-project-id" ]; then
    echo "Error: Please provide your Google Cloud Project ID"
    echo "Usage: ./examples.sh YOUR_PROJECT_ID [REGION]"
    echo "Example: ./examples.sh my-gcp-project us-central1"
    exit 1
fi

# Function to run workflow and wait for completion
run_workflow_test() {
    local test_name="$1"
    local endpoints_json="$2"
    
    echo "Running Test: $test_name"
    echo "Star Wars Endpoints: $endpoints_json"
    
    EXECUTION_ID=$(gcloud workflows run "${WORKFLOW_NAME}" \
        --location="${REGION}" \
        --data="{\"endpoints\": $endpoints_json, \"bucket\": \"${BUCKET_NAME}\"}" \
        --format="value(name)" | sed 's/.*\///')
    
    echo "Execution ID: ${EXECUTION_ID}"
    echo "Waiting for completion..."
    
    # Wait for workflow to complete (max 60 seconds)
    for i in {1..12}; do
        STATUS=$(gcloud workflows executions describe "${EXECUTION_ID}" \
            --workflow="${WORKFLOW_NAME}" \
            --location="${REGION}" \
            --format="value(state)")
        
        if [ "$STATUS" = "SUCCEEDED" ]; then
            echo "Test completed successfully!"
            break
        elif [ "$STATUS" = "FAILED" ]; then
            echo "Test failed!"
            gcloud workflows executions describe "${EXECUTION_ID}" \
                --workflow="${WORKFLOW_NAME}" \
                --location="${REGION}"
            break
        else
            echo "Status: $STATUS (waiting...)"
            sleep 5
        fi
    done
    echo ""
}

echo "Running Star Wars API workflow tests..."
echo ""

# Test 1: People (Characters)
run_workflow_test "Star Wars Characters" '["people"]'

# Test 2: Multiple endpoints
run_workflow_test "Planets and Starships" '["planets", "starships"]'

# Test 3: Films data
run_workflow_test "Star Wars Films" '["films"]'

# Test 4: Complete dataset (all endpoints)
run_workflow_test "Full Star Wars Data" '["people", "planets", "starships", "films", "species", "vehicles"]'

echo "Checking stored Star Wars data..."
echo "Files in bucket:"
gsutil ls "gs://${BUCKET_NAME}/" | head -10

echo ""
echo "To download and explore Star Wars data:"
echo "gsutil cp gs://${BUCKET_NAME}/star_wars_data_*.json ."
echo "cat star_wars_data_*.json | jq '.summary'"
echo ""
echo "To explore specific data:"
echo "cat star_wars_data_*.json | jq '.results[] | select(.endpoint==\"people\") | .data[0].properties.name'"
echo "cat star_wars_data_*.json | jq '.results[] | select(.endpoint==\"planets\") | .data[].properties.name'"
echo ""

echo "To view workflow execution history:"
echo "gcloud workflows executions list --workflow=${WORKFLOW_NAME} --location=${REGION}"
echo ""

echo "All Star Wars data collection tests completed!"
echo ""
echo "Check the Cloud Console for detailed logs and results:"
echo "https://console.cloud.google.com/workflows/workflow/${REGION}/${WORKFLOW_NAME}"
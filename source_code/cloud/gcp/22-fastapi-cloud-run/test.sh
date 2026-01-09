#!/bin/bash
# Test script for Star Wars API Data Collector

set -e

SERVICE_URL="${1:-}"

if [ -z "$SERVICE_URL" ]; then
    echo "Error: Please provide the service URL"
    echo "Usage: ./test.sh https://your-service-url.run.app"
    exit 1
fi

echo "Testing Star Wars API Data Collector"
echo "==================================="
echo "Service URL: ${SERVICE_URL}"
echo ""

# Test function
test_endpoint() {
    local method=$1
    local endpoint=$2
    local data=$3
    local description=$4
    
    echo "Testing: $description"
    
    if [ -n "$data" ]; then
        curl -s -X "$method" "${SERVICE_URL}${endpoint}" \
            -H "Content-Type: application/json" \
            -d "$data" | jq '.' 2>/dev/null || echo "Response received"
    else
        curl -s "${SERVICE_URL}${endpoint}" | jq '.' 2>/dev/null || echo "Response received"
    fi
    
    echo ""
}

echo "Running tests..."
echo ""

# Basic tests
test_endpoint "GET" "/" "" "API Information"
test_endpoint "GET" "/health" "" "Health Check"
test_endpoint "GET" "/star-wars/endpoints" "" "Available Data Types"

# Star Wars data collection
test_endpoint "GET" "/star-wars/people" "" "Quick Collect: Characters"
test_endpoint "GET" "/star-wars/planets" "" "Quick Collect: Planets"

# Comprehensive collection
test_endpoint "POST" "/star-wars/collect" '{"endpoints": ["people", "planets"], "max_items": 2}' "Collect Multiple Types"

# Storage
sleep 2  # Wait for background tasks
test_endpoint "GET" "/storage/files" "" "List Storage Files"

echo "All tests completed!"
echo ""
echo "API Documentation: ${SERVICE_URL}/docs"
echo "Key endpoints:"
echo "  GET ${SERVICE_URL}/star-wars/endpoints"
echo "  POST ${SERVICE_URL}/star-wars/collect"
echo "  GET ${SERVICE_URL}/star-wars/people"
echo ""
echo "Check stored data:"
echo "  gsutil ls gs://star-wars-data-YOUR-PROJECT/"
#!/bin/bash

# FastAPI DevOps System Information API - Test Script
# This script tests all API endpoints using curl

API_BASE="http://localhost:8000"

echo "=== FastAPI DevOps System Information API Test ==="
echo "API Base URL: $API_BASE"
echo ""

# Function to make API call and format output
test_endpoint() {
    local endpoint="$1"
    local description="$2"
    
    echo "Testing: $description"
    echo "Endpoint: $endpoint"
    echo "Response:"
    
    response=$(curl -s -w "\nHTTP Status: %{http_code}\n" "$API_BASE$endpoint")
    
    if [[ $? -eq 0 ]]; then
        echo "$response" | jq . 2>/dev/null || echo "$response"
    else
        echo "Error: Failed to connect to API"
    fi
    
    echo ""
    echo "---"
    echo ""
}

# Check if API is running
echo "1. Checking if API is running..."
if curl -s "$API_BASE/health" > /dev/null; then
    echo "✅ API is running!"
else
    echo "❌ API is not running. Please start it first:"
    echo "   python -m uvicorn src.devops_api.main:app --reload"
    echo "   or"
    echo "   devops-api"
    exit 1
fi
echo ""

# Test all endpoints
test_endpoint "/" "API Information"
test_endpoint "/health" "Health Check"
test_endpoint "/system/cpu" "CPU Information"
test_endpoint "/system/memory" "Memory Information"
test_endpoint "/system/disk" "Disk Information"
test_endpoint "/system/network" "Network Information"
test_endpoint "/system/swap" "Swap Information"
test_endpoint "/system/sensors" "Temperature Sensors"
test_endpoint "/system/all" "Complete System Information"

echo "=== API Documentation ==="
echo "Interactive Docs (Swagger): $API_BASE/docs"
echo "Alternative Docs (ReDoc):   $API_BASE/redoc"
echo ""
echo "=== Test completed! ==="

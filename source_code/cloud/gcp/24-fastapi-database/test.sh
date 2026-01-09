#!/bin/bash

# Test script for Star Wars Database API

SERVICE_URL="${1}"

if [ -z "$SERVICE_URL" ]; then
    echo "Error: Please provide the service URL"
    echo "Usage: ./test.sh https://your-service-url"
    echo "Get URL from: gcloud run services list"
    exit 1
fi

echo "Testing Star Wars Database API"
echo "Service URL: $SERVICE_URL"
echo ""

# Test health endpoint
echo "Testing health check..."
curl -s "$SERVICE_URL/health" | jq '.'
echo ""

# Test root endpoint
echo "Testing root endpoint..."
curl -s "$SERVICE_URL/" | jq '.'
echo ""

# Test statistics (should be empty initially)
echo "Initial statistics..."
curl -s "$SERVICE_URL/stats" | jq '.'
echo ""

# Test data collection
echo "Collecting Star Wars data..."
COLLECTION_RESULT=$(curl -s -X POST "$SERVICE_URL/collect" \
    -H "Content-Type: application/json" \
    -d '{"endpoints": ["people", "planets", "starships"], "max_items_per_endpoint": 3}')
echo $COLLECTION_RESULT | jq '.'
echo ""

# Wait a moment for processing
echo "Waiting for data processing..."
sleep 2

# Test retrieving characters
echo "Retrieving characters..."
curl -s "$SERVICE_URL/characters" | jq '.'
echo ""

# Test retrieving planets
echo "Retrieving planets..."
curl -s "$SERVICE_URL/planets" | jq '.'
echo ""

# Test retrieving starships
echo "Retrieving starships..."
curl -s "$SERVICE_URL/starships" | jq '.'
echo ""

# Test collections history
echo "Collection history..."
curl -s "$SERVICE_URL/collections" | jq '.'
echo ""

# Test updated statistics
echo "Updated statistics..."
curl -s "$SERVICE_URL/stats" | jq '.'
echo ""

echo "All tests completed!"
echo ""
echo "Database queries to try:"
echo "Connect to database:"
echo "gcloud sql connect starwars-postgres --user=starwars --database=starwars_db"
echo ""
echo "Sample queries:"
echo "SELECT COUNT(*) FROM characters;"
echo "SELECT name, height, gender FROM characters WHERE gender = 'male' LIMIT 3;"
echo "SELECT name, climate, population FROM planets ORDER BY name;"
echo "SELECT name, model, starship_class FROM starships WHERE starship_class IS NOT NULL;"
echo "SELECT * FROM collections ORDER BY created_at DESC;"
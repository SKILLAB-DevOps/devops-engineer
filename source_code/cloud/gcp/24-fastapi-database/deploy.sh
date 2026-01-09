#!/bin/bash

echo "Deploying Star Wars Database API to Cloud Run with Cloud SQL..."

# Get project ID
PROJECT_ID="${1:-$(gcloud config get-value project)}"

if [ -z "$PROJECT_ID" ]; then
    echo "Error: No project ID found. Usage: ./deploy.sh YOUR_PROJECT_ID"
    exit 1
fi

echo "Project ID: $PROJECT_ID"

# Configuration
REGION="us-central1"
SERVICE_NAME="starwars-db-api"
DB_INSTANCE_NAME="starwars-postgres"
DATABASE_NAME="starwars_db"
DB_USER="starwars"
DB_PASSWORD=$(openssl rand -base64 12)
IMAGE_NAME="gcr.io/${PROJECT_ID}/${SERVICE_NAME}"

echo "Setting up Cloud SQL PostgreSQL instance..."

# Enable required APIs
gcloud services enable sqladmin.googleapis.com --project=$PROJECT_ID
gcloud services enable run.googleapis.com --project=$PROJECT_ID
gcloud services enable cloudbuild.googleapis.com --project=$PROJECT_ID

# Create Cloud SQL instance if it doesn't exist
if ! gcloud sql instances describe $DB_INSTANCE_NAME --project=$PROJECT_ID 2>/dev/null; then
    echo "Creating Cloud SQL PostgreSQL instance..."
    gcloud sql instances create $DB_INSTANCE_NAME \
        --database-version=POSTGRES_15 \
        --tier=db-f1-micro \
        --region=$REGION \
        --root-password=$DB_PASSWORD \
        --project=$PROJECT_ID
    
    echo "Waiting for instance to be ready..."
    sleep 30
else
    echo "Cloud SQL instance already exists"
fi

# Create database if it doesn't exist
if ! gcloud sql databases describe $DATABASE_NAME --instance=$DB_INSTANCE_NAME --project=$PROJECT_ID 2>/dev/null; then
    echo "Creating database..."
    gcloud sql databases create $DATABASE_NAME --instance=$DB_INSTANCE_NAME --project=$PROJECT_ID
else
    echo "Database already exists"
fi

# Create database user if it doesn't exist
if ! gcloud sql users describe $DB_USER --instance=$DB_INSTANCE_NAME --project=$PROJECT_ID 2>/dev/null; then
    echo "Creating database user..."
    gcloud sql users create $DB_USER --instance=$DB_INSTANCE_NAME --password=$DB_PASSWORD --project=$PROJECT_ID
else
    echo "Database user already exists"
fi

# Build and deploy container
echo "Building container image..."
gcloud builds submit --tag $IMAGE_NAME --project=$PROJECT_ID

if [ $? -eq 0 ]; then
    echo "Container image built successfully"
    
    # Get Cloud SQL connection name
    CONNECTION_NAME=$(gcloud sql instances describe $DB_INSTANCE_NAME --project=$PROJECT_ID --format="value(connectionName)")
    
    # Create database URL for Cloud SQL
    DATABASE_URL="postgresql://${DB_USER}:${DB_PASSWORD}@/${DATABASE_NAME}?host=/cloudsql/${CONNECTION_NAME}"
    
    echo "Deploying to Cloud Run..."
    gcloud run deploy $SERVICE_NAME \
        --image $IMAGE_NAME \
        --platform managed \
        --region $REGION \
        --allow-unauthenticated \
        --set-env-vars DATABASE_URL="$DATABASE_URL" \
        --add-cloudsql-instances $CONNECTION_NAME \
        --memory 1Gi \
        --cpu 1 \
        --max-instances 10 \
        --project=$PROJECT_ID
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "Deployment successful!"
        
        # Get service URL
        SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --platform managed --region $REGION --project=$PROJECT_ID --format="value(status.url)")
        
        echo ""
        echo "Star Wars Database API is ready!"
        echo "Service URL: $SERVICE_URL"
        echo ""
        echo "Health Check:"
        echo "curl $SERVICE_URL/health"
        echo ""
        echo "Collect Star Wars data:"
        echo "curl -X POST $SERVICE_URL/collect"
        echo ""
        echo "View characters:"
        echo "curl $SERVICE_URL/characters"
        echo ""
        echo "View planets:"
        echo "curl $SERVICE_URL/planets"
        echo ""
        echo "View starships:"
        echo "curl $SERVICE_URL/starships"
        echo ""
        echo "View statistics:"
        echo "curl $SERVICE_URL/stats"
        echo ""
        echo "Database Information:"
        echo "Instance: $DB_INSTANCE_NAME"
        echo "Database: $DATABASE_NAME"
        echo "User: $DB_USER"
        echo "Connection: $CONNECTION_NAME"
        echo ""
        echo "Connect to database directly:"
        echo "gcloud sql connect $DB_INSTANCE_NAME --user=$DB_USER --database=$DATABASE_NAME --project=$PROJECT_ID"
        echo ""
        echo "Query examples:"
        echo "SELECT COUNT(*) FROM characters;"
        echo "SELECT name, gender FROM characters LIMIT 5;"
        echo "SELECT name, climate FROM planets WHERE climate LIKE '%temperate%';"
        echo "SELECT name, starship_class FROM starships ORDER BY name;"
        echo ""
        echo "Deployment completed successfully!"
        
    else
        echo "Cloud Run deployment failed"
        exit 1
    fi
else
    echo "Container build failed"
    exit 1
fi
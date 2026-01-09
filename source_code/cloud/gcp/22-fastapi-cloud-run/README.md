# Star Wars API Data Collector

A FastAPI application that collects Star Wars universe data from the SWAPI (swapi.tech) and stores it in Google Cloud Storage. Demonstrates REST API integration, async data processing, and cloud storage management.

## Features

- Star Wars Data Collection: Fetch comprehensive data from swapi.tech API
- Multi-Endpoint Support: Collect characters, planets, starships, films, species, and vehicles
- Cloud Storage Integration: Automatic data storage with organized file structure
- Background Processing: Async data collection and storage without blocking responses
- Batch Operations: Collect multiple data types in a single API call
- Progress Tracking: Detailed collection summaries and statistics
- Quick Collections: Single-endpoint data collection for rapid testing
- Data Organization: Structured JSON output with metadata and summaries
- Storage Management: List, explore, and manage collected Star Wars data
- Health Monitoring: Service and storage status endpoints
- Auto Documentation: Interactive Swagger UI at `/docs`
- Legacy Support: Maintains user/task management for backward compatibility

## API Endpoints

### Core Endpoints
- `GET /` - API information, stats, and storage status
- `GET /health` - Health check for monitoring  
- `GET /docs` - Interactive API documentation (Swagger UI)

### Star Wars Data Collection
- `GET /star-wars/endpoints` - List available Star Wars data types and fields
- `POST /star-wars/collect` - Collect comprehensive Star Wars data from multiple endpoints
- `GET /star-wars/quick-collect/{endpoint}` - Quick collection from single endpoint (people, planets, etc.)
- `GET /star-wars/latest` - Get information about the latest data collection

### Cloud Storage Management
- `GET /storage/status` - Check Cloud Storage connection and bucket info
- `GET /storage/files` - List all files in Cloud Storage bucket
- `GET /storage/files?prefix=star-wars-collections/` - List Star Wars collections
- `POST /storage/save` - Save custom data to Cloud Storage

### Legacy Endpoints (Backward Compatibility)
- `GET /users` - List all users
- `POST /users` - Create new user (automatically saves to Cloud Storage) 
- `GET /tasks` - List tasks (with filtering)
- `POST /tasks` - Create new task (automatically saves to Cloud Storage)
- `POST /backup` - Create complete data backup
- `GET /stats` - API usage statistics

## Local Development

```bash
# Install dependencies
pip install -r requirements.txt

# Run locally
python main.py
# or
uvicorn main:app --reload --port 8080

# Access the API
curl http://localhost:8080
curl http://localhost:8080/docs  # Swagger UI
```

## Docker Deployment

```bash
# Build image
docker build -t fastapi-cloud-run .

# Run container
docker run -p 8080:8080 fastapi-cloud-run

# Test
curl http://localhost:8080/health
```

## Quick Deployment

### Easy Deployment (Recommended)

```bash
# Make the deployment script executable
chmod +x deploy.sh

# Deploy with your project ID
./deploy.sh YOUR_PROJECT_ID

# Example:
./deploy.sh my-gcp-project
```

The deployment script will:
- Set up your Google Cloud project  
- Enable required APIs (Cloud Run, Cloud Storage, Cloud Build)
- Create a Cloud Storage bucket for data
- Deploy the application to Cloud Run
- Configure environment variables
- Provide testing commands

### Manual Cloud Run Deployment

```bash
# Set your project ID
export PROJECT_ID="your-project-id"
export BUCKET_NAME="fastapi-demo-data-${PROJECT_ID}"

# Enable APIs
gcloud services enable run.googleapis.com storage.googleapis.com cloudbuild.googleapis.com

# Create storage bucket
gsutil mb -p "${PROJECT_ID}" -c STANDARD -l us-central1 "gs://${BUCKET_NAME}"

# Deploy to Cloud Run
gcloud run deploy fastapi-demo \
    --source . \
    --platform managed \
    --region us-central1 \
    --allow-unauthenticated \
    --port 8080 \
    --memory 512Mi \
    --cpu 1 \
    --max-instances 10 \
    --set-env-vars "BUCKET_NAME=${BUCKET_NAME}" \
    --set-env-vars "GOOGLE_CLOUD_PROJECT=${PROJECT_ID}"
```

## Testing

### Automated Testing

```bash
# Make test script executable
chmod +x test.sh

# Run all tests (replace with your actual service URL)
./test.sh https://your-service-url.run.app

# Example:
./test.sh https://star-wars-collector-xyz123-uc.a.run.app
```

The test script will:
- Test all Star Wars API endpoints
- Verify Cloud Storage integration
- Test quick and comprehensive data collection
- Test data backup functionality
- Verify file storage and retrieval

### Manual Testing

```bash
# Get service URL after deployment
SERVICE_URL=$(gcloud run services describe star-wars-collector --platform managed --region us-central1 --format 'value(status.url)')

# Test API info
curl $SERVICE_URL/

# Test storage status
curl $SERVICE_URL/storage/status

# Get available Star Wars endpoints
curl $SERVICE_URL/star-wars/endpoints

# Quick collect Star Wars characters
curl $SERVICE_URL/star-wars/quick-collect/people

# Comprehensive data collection
curl -X POST $SERVICE_URL/star-wars/collect \
  -H "Content-Type: application/json" \
  -d '{"endpoints": ["people", "planets"], "max_items_per_endpoint": 3}'

# Get latest collection info
curl $SERVICE_URL/star-wars/latest

# List storage files
curl $SERVICE_URL/storage/files
```

## Environment Variables

- `PORT`: Server port (default: 8080)
- `BUCKET_NAME`: Cloud Storage bucket name (default: fastapi-demo-data)
- `GOOGLE_CLOUD_PROJECT`: Google Cloud project ID (auto-set by Cloud Run)

## Sample Usage

```bash
# Get API info
curl https://your-service-url.run.app/

# List available Star Wars data types
curl https://your-service-url.run.app/star-wars/endpoints

# Quick collect characters
curl https://your-service-url.run.app/star-wars/quick-collect/people

# Comprehensive data collection
curl -X POST https://your-service-url.run.app/star-wars/collect \
  -H "Content-Type: application/json" \
  -d '{"endpoints": ["people", "planets", "starships"], "max_items_per_endpoint": 5}'

# Get collection statistics
curl https://your-service-url.run.app/star-wars/latest

# Get API statistics
curl https://your-service-url.run.app/stats
```

## Sample Use Cases

### Star Wars Data Research
```bash
# Collect character data for analysis
curl https://your-service-url.run.app/star-wars/quick-collect/people

# Get comprehensive universe data
curl -X POST $SERVICE_URL/star-wars/collect \
  -H "Content-Type: application/json" \
  -d '{"endpoints": ["people", "planets", "starships", "films"]}'
```

### API Integration Testing
```bash
# Test external API integration patterns
curl https://your-service-url.run.app/star-wars/endpoints

# Validate data collection and storage
curl $SERVICE_URL/storage/files?prefix=star-wars-collections/
```

### Data Storage Examples
```bash
# Save custom analysis results
curl -X POST $SERVICE_URL/storage/save \
  -H "Content-Type: application/json" \
  -d '{"analysis": "character_heights", "results": {"average": 175}}'
```

## Production Features

- Cloud Storage Integration: Persistent data storage across container restarts
- Background Processing: Non-blocking data saves using FastAPI background tasks
- Health Monitoring: Comprehensive health checks for service and storage
- Auto-scaling: Cloud Run automatically scales based on traffic
- Request Logging: Structured JSON logging for monitoring
- Error Handling: Robust error responses with detailed messages
- Pydantic Validation: Automatic request/response validation
- Security: Non-root container user and secure defaults
- Resource Optimization: Configured memory and CPU limits
- Storage Organization: Organized file structure for different data types

## Storage Structure

Your Cloud Storage bucket will be organized as:
```
gs://star-wars-data-PROJECT-ID/
├── star-wars-collections/    # Comprehensive data collections
│   └── collection_20251029_143022.json
├── star-wars-quick/          # Single endpoint collections  
│   └── people_20251029_143045.json
├── users/                    # Legacy user data
│   └── user_1234_20251029_143022.json
├── tasks/                    # Legacy task data
│   └── task_5678_20251029_143045.json
├── custom/                   # Custom data saves
│   └── data_9012_20251029_143105.json
└── backups/                  # Complete data backups
    └── backup_20251029_143200.json
```

## Monitoring

### View Application Logs
```bash
# View Cloud Run logs
gcloud logs read "resource.type=cloud_run_revision" --limit=50

# View specific service logs
gcloud logs read "resource.type=cloud_run_revision AND resource.labels.service_name=star-wars-collector" --limit=20
```

### Monitor Storage Usage
```bash
# List all files in bucket
gsutil ls -r gs://star-wars-data-YOUR-PROJECT/

# Check bucket size
gsutil du -sh gs://star-wars-data-YOUR-PROJECT/

# View Star Wars collections
gsutil ls -l gs://star-wars-data-YOUR-PROJECT/star-wars-collections/
```

### Service Metrics
```bash
# Get service details
gcloud run services describe star-wars-collector --region=us-central1

# Monitor service performance in Cloud Console
# https://console.cloud.google.com/run/detail/REGION/SERVICE-NAME/metrics
```
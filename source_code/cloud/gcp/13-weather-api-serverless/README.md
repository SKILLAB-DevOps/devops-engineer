# Weather API - Serverless Deployment (Cloud Run)

Deploy the FastAPI Weather API as a serverless application on Google Cloud Run.

## Setup

1. **Edit `main.tf`** and replace `"your-project-id"` with your GCP project ID

2. **Make deploy script executable:**
   ```bash
   chmod +x deploy.sh
   ```

3. **Build and deploy:**
   ```bash
   ./deploy.sh
   ```

   Or manually:
   ```bash
   # Build container image
   gcloud builds submit --tag gcr.io/$(gcloud config get-value project)/weather-api:latest
   
   # Deploy with Terraform
   terraform init
   terraform apply
   ```

## What this creates

- **Container image** built with Cloud Build
- **Cloud Run service** that auto-scales from 0 to 10 instances
- **Public HTTPS endpoint** (automatically provided)
- **IAM permissions** for public access

## Test the API

```bash
# Get the service URL
SERVICE_URL=$(terraform output -raw service_url)

# Root endpoint
curl $SERVICE_URL

# Health check
curl $SERVICE_URL/health

# Weather for London
curl $SERVICE_URL/weather/London

# Weather for any city
curl $SERVICE_URL/weather/Tokyo
```

## Serverless Features

```bash
# View service details
gcloud run services describe weather-api --region=us-central1

# View logs
gcloud logs read --filter="resource.type=cloud_run_revision AND resource.labels.service_name=weather-api" --limit=50

# Update the service (after code changes)
gcloud builds submit --tag gcr.io/$(gcloud config get-value project)/weather-api:latest
terraform apply
```

## Pros of Serverless (Cloud Run)
- **Auto-scaling**: Scales to 0 when no traffic (no cost when idle)
- **HTTPS by default**: Automatic SSL certificates
- **Managed infrastructure**: No server maintenance
- **Pay per request**: Only pay for actual usage
- **Fast cold starts**: Container starts in seconds
- **Global availability**: Automatically distributed

## Cons of Serverless
- **Cold starts**: First request after idle may be slower
- **Limited runtime**: 60-minute request timeout max
- **Stateless**: No persistent storage between requests
- **Memory limits**: Maximum 8GB RAM per instance

## Scaling Configuration

The service is configured to:
- **Min instances**: 0 (scales to zero when idle)
- **Max instances**: 10 (prevents runaway costs)
- **Concurrency**: 100 requests per instance
- **Memory**: 512MB per instance
- **CPU**: 1 vCPU per instance

## Clean up

```bash
terraform destroy
```
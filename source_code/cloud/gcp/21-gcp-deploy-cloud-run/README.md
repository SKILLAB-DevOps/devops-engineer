# DevOps Reddit Scraper - Cloud Run Deployment

Deploy a FastAPI Reddit scraper application to Google Cloud Run with multiple deployment options including VM, Kubernetes, and serverless Cloud Run.

## What You'll Build

A complete FastAPI application that:
- **Fetches Reddit posts** from the DevOps subreddit
- **Provides REST API** with automatic OpenAPI documentation
- **Containerized deployment** using Docker
- **Multiple deployment options** - VM, Kubernetes, Cloud Run
- **CI/CD pipeline** with GitHub Actions
- **Production-ready** with proper error handling and monitoring

---

## Application Overview

### **FastAPI Reddit Scraper**
- **Endpoint**: `/devops/top` - Get top posts from r/devops
- **Features**: Configurable post limit, error handling, structured response
- **Documentation**: Automatic Swagger UI at `/docs`
- **Health Check**: Root endpoint at `/`

### **Tech Stack**
- **Backend**: FastAPI + uvicorn + httpx + pydantic
- **Container**: Docker with Python 3.13
- **Package Manager**: uv (ultra-fast Python package installer)
- **Infrastructure**: Terraform for GCP resources
- **CI/CD**: GitHub Actions with Docker Hub
- **Kubernetes**: Helm charts for K8s deployment

---

## Prerequisites

- **Google Cloud Account** with billing enabled
- **GCP Project** with Cloud Run API enabled
- **Docker Hub Account** (for container registry)
- **GitHub Account** (for CI/CD pipeline)
- **Local Tools**:
  ```bash
  # Install required tools
  brew install terraform
  brew install google-cloud-sdk
  brew install docker
  ```

---

## Deployment Options

This project supports **3 different deployment methods**:

1. **Cloud Run (Serverless)** - Recommended for production
2. **Cloud Run (Direct Source)** - Deploy code without Docker
3. **Local Development** - Testing and development

---

## Option 1: Cloud Run Deployment (Recommended)

### **Step 1: Setup Google Cloud**

```bash
# 1. Authenticate with Google Cloud
gcloud auth login
gcloud auth application-default login
 
# 2. Set your project ID
export PROJECT_ID="your-gcp-project-id"
gcloud config set project $PROJECT_ID

# 3. Enable required APIs
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable artifactregistry.googleapis.com

# 4. Create Artifact Registry repository
gcloud artifacts repositories create devops-reddit \
    --repository-format=docker \
    --location=us-central1 \
    --description="Docker repository for Reddit scraper"
```

### **Step 2: Build and Deploy to Cloud Run**

```bash
# 1. Clone or navigate to the project
cd devops_reddit_scrapper

# 2. Build the container image
gcloud builds submit --tag us-central1-docker.pkg.dev/$PROJECT_ID/devops-reddit/reddit-scraper:latest

# 3. Deploy to Cloud Run
gcloud run deploy reddit-scraper \
    --image us-central1-docker.pkg.dev/$PROJECT_ID/devops-reddit/reddit-scraper:latest \
    --platform managed \
    --region us-central1 \
    --allow-unauthenticated \
    --port 8000 \
    --memory 512Mi \
    --cpu 1000m \
    --min-instances 0 \
    --max-instances 10 \
    --timeout 300s

# 4. Get the service URL
gcloud run services describe reddit-scraper \
    --region us-central1 \
    --format 'value(status.url)'
```

### **Step 3: Test the Cloud Run Service**

```bash
# Get the service URL
SERVICE_URL=$(gcloud run services describe reddit-scraper --region us-central1 --format 'value(status.url)')

# Test the API endpoints
curl "$SERVICE_URL/"
curl "$SERVICE_URL/devops/top?limit=5"

# Open API documentation
open "$SERVICE_URL/docs"
```

### **Step 4: Configure Custom Domain (Optional)**

```bash
# 1. Map a custom domain
gcloud run domain-mappings create \
    --service reddit-scraper \
    --domain api.yourdomain.com \
    --region us-central1

# 2. Update DNS records as shown in the output
# Add the CNAME record to your DNS provider
```

---

## Option 2: Cloud Run Direct Source Deployment (No Docker)

### **Step 1: Setup Google Cloud**

```bash
# 1. Authenticate with Google Cloud
gcloud auth login
gcloud auth application-default login

# 2. Set your project ID
export PROJECT_ID="your-gcp-project-id"
gcloud config set project $PROJECT_ID

# 3. Enable required APIs
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
```

### **Step 2: Prepare Source Code**

```bash
# 1. Navigate to your project directory
cd devops_reddit_scrapper

# 2. Create a .gcloudignore file (similar to .dockerignore)
cat > .gcloudignore << 'EOF'
.git
.gitignore
README.md
Dockerfile
.dockerignore
.venv/
__pycache__/
*.pyc
*.pyo
*.pyd
.pytest_cache/
.coverage
.env
node_modules/
EOF

# 3. Ensure your pyproject.toml is properly configured
cat pyproject.toml
```

### **Step 3: Deploy Directly from Source**

```bash
# Deploy directly from source code (no Dockerfile needed)
gcloud run deploy reddit-scraper-source \
    --source . \
    --platform managed \
    --region us-central1 \
    --allow-unauthenticated \
    --port 8000 \
    --memory 512Mi \
    --cpu 1000m \
    --min-instances 0 \
    --max-instances 10 \
    --timeout 300s \
    --set-env-vars "PORT=8000"
```

### **Step 4: Configure Buildpack Settings (Optional)**

```bash
# Create a .buildpacks file to specify Python buildpack
echo "gcr.io/buildpacks/python" > .buildpacks

# Or set buildpack via gcloud command
gcloud run deploy reddit-scraper-source \
    --source . \
    --platform managed \
    --region us-central1 \
    --allow-unauthenticated \
    --set-env-vars "GOOGLE_BUILDPACK=gcr.io/buildpacks/python"
```

### **Step 5: Test the Direct Source Service**

```bash
# Get the service URL
SOURCE_URL=$(gcloud run services describe reddit-scraper-source --region us-central1 --format 'value(status.url)')

# Test the API endpoints
curl "$SOURCE_URL/"
curl "$SOURCE_URL/devops/top?limit=5"

# Open API documentation
open "$SOURCE_URL/docs"
```

### **Step 6: Monitor Build Process**

```bash
# View build logs
gcloud builds log $(gcloud builds list --limit=1 --format="value(id)")

# Check service status
gcloud run services describe reddit-scraper-source --region us-central1

# View service logs
gcloud logs read --service=reddit-scraper-source --limit=20
```

### **Key Benefits of Direct Source Deployment:**

- **No Dockerfile needed** - Google Cloud Buildpacks automatically detect Python  
- **Automatic dependency detection** - Reads pyproject.toml/requirements.txt  
- **Faster iteration** - No local Docker build required  
- **Automatic optimization** - Google optimizes the container image  
- **Security patching** - Base images automatically updated by Google  

### **How It Works:**

1. **Source Upload**: Code is uploaded to Google Cloud Build
2. **Language Detection**: Buildpack detects Python project via pyproject.toml
3. **Dependency Installation**: uv/pip installs packages from pyproject.toml
4. **Container Creation**: Buildpack creates optimized container image
5. **Cloud Run Deployment**: Container deployed to Cloud Run service

### **Buildpack Environment Variables:**

```bash
# Configure Python version (if needed)
gcloud run deploy reddit-scraper-source \
    --source . \
    --region us-central1 \
    --set-env-vars "GOOGLE_PYTHON_VERSION=3.13"

# Configure uv package manager
gcloud run deploy reddit-scraper-source \
    --source . \
    --region us-central1 \
    --set-env-vars "GOOGLE_PYTHON_PIP_RUNNER=uv"

# Set custom start command
gcloud run deploy reddit-scraper-source \
    --source . \
    --region us-central1 \
    --set-env-vars "GOOGLE_PYTHON_EXEC=python main.py"
```

### **Troubleshooting Direct Source Deployment:**

```bash
# Check build configuration
gcloud builds describe $(gcloud builds list --limit=1 --format="value(id)")

# Verify Python project structure
ls -la pyproject.toml main.py

# Check if main.py is properly configured as entry point
grep -n "if __name__" main.py

# View detailed build logs
gcloud builds log --stream $(gcloud builds list --limit=1 --format="value(id)")
```

---

## Option 3: Local Development

### **Step 1: Local Setup**

```bash
# 1. Install uv package manager
curl -LsSf https://astral.sh/uv/install.sh | sh

# 2. Clone the repository
git clone https://github.com/SKILLAB-DevOps/devops_reddit_scrapper.git
cd devops_reddit_scrapper

# 3. Create virtual environment and install dependencies
uv venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
uv pip install .
```

### **Step 2: Run Locally**

```bash
# 1. Start the FastAPI server
python main.py

# 2. Or use uvicorn directly
uvicorn main:app --host 0.0.0.0 --port 8000 --reload

# 3. Access the application
open http://localhost:8000/docs
```

### **Step 3: Docker Development**

```bash
# 1. Build Docker image locally
docker build -t reddit-scraper:local .

# 2. Run the container
docker run -p 8000:8000 reddit-scraper:local

# 3. Test the containerized app
curl http://localhost:8000/devops/top?limit=3
```

---

## CI/CD Pipeline Setup

### **Step 1: GitHub Actions Configuration**

The project includes a GitHub Actions workflow (`.github/workflows/build.yaml`) that:
- Builds Docker images on code changes
- Pushes to Docker Hub
- Runs security scans with Trivy

### **Step 2: Setup Docker Hub Secrets**

```bash
# 1. Go to your GitHub repository settings
# 2. Navigate to Settings > Secrets and variables > Actions
# 3. Add the following secrets:

# DOCKER_USERNAME: your-dockerhub-username
# DOCKER_PAT: your-dockerhub-personal-access-token
```

### **Step 3: Trigger Pipeline**

```bash
# 1. Make changes to the code
git add .
git commit -m "Update FastAPI application"
git push origin main

# 2. Check the Actions tab in GitHub
# 3. Monitor the build and security scan results
```

---

## API Documentation

### **Endpoints**

#### **GET /**
Root endpoint with API information
```bash
curl https://your-service-url/
```

#### **GET /devops/top**
Fetch top posts from r/devops subreddit

**Parameters:**
- `limit` (optional): Number of posts to retrieve (1-25, default: 10)

```bash
# Get top 10 posts (default)
curl https://your-service-url/devops/top

# Get top 5 posts
curl https://your-service-url/devops/top?limit=5
```

**Response Format:**
```json
{
  "posts": [
    {
      "title": "Post title",
      "author": "username",
      "score": 123,
      "num_comments": 45,
      "url": "https://...",
      "created_utc": 1634567890.0,
      "permalink": "https://reddit.com/r/devops/...",
      "selftext": "Post content preview..."
    }
  ],
  "total_count": 10
}
```

#### **GET /docs**
Interactive API documentation (Swagger UI)
```bash
open https://your-service-url/docs
```

### **Error Handling**

The API includes comprehensive error handling:
- **400**: Invalid limit parameter (> 25)
- **504**: Reddit API timeout
- **500**: Internal server errors

---

## Monitoring and Observability

### **Cloud Run Monitoring**

```bash
# 1. View Cloud Run metrics in console
open "https://console.cloud.google.com/run/detail/us-central1/reddit-scraper/metrics"

# 2. Check logs
gcloud logs read --service=reddit-scraper --limit=50

# 3. Set up alerting
gcloud alpha monitoring policies create --policy-from-file=alerting-policy.yaml
```

### **Application Health Checks**

```bash
# Health check endpoint
curl https://your-service-url/

# Check response time
curl -w "@curl-format.txt" -o /dev/null https://your-service-url/devops/top
```

### **Performance Monitoring**

```bash
# Load testing with Apache Bench
ab -n 1000 -c 10 https://your-service-url/devops/top

# Monitor Cloud Run metrics
gcloud run services describe reddit-scraper \
    --region us-central1 \
    --format="table(metadata.name,status.url,status.conditions[0].type)"
```

---

## Troubleshooting

### **Common Issues**

#### **Cloud Run Deployment Issues**
```bash
# Check build logs
gcloud builds log $(gcloud builds list --limit=1 --format="value(id)")

# Check Cloud Run logs
gcloud logs read --service=reddit-scraper --limit=10

# Check service configuration
gcloud run services describe reddit-scraper --region us-central1
```



### **Application Issues**

#### **Reddit API Errors**
```bash
# Test Reddit API directly
curl -H "User-Agent: FastAPI-DevOps-Tutorial/1.0" \
     "https://www.reddit.com/r/devops/top.json?limit=5"

# Check if Reddit is accessible
ping reddit.com

# Test with different User-Agent
curl -H "User-Agent: MyBot/1.0" \
     "https://www.reddit.com/r/devops/top.json?limit=1"
```

#### **Performance Issues**
```bash
# Check memory usage
docker stats reddit-scraper

# Monitor response times
curl -w "Time: %{time_total}s\n" https://your-service-url/devops/top

# Check concurrent connections
netstat -an | grep :8000 | wc -l
```

---

## Security Best Practices

### **Container Security**

```bash
# 1. Run security scan with Trivy
trivy image reddit-scraper:latest

# 2. Use distroless images for production
# Update Dockerfile base image to:
# FROM gcr.io/distroless/python3-debian11

# 3. Run as non-root user
# Add to Dockerfile:
# RUN adduser --disabled-password --gecos '' appuser
# USER appuser
```

### **Cloud Run Security**

```bash
# 1. Enable authentication
gcloud run services update reddit-scraper \
    --region us-central1 \
    --no-allow-unauthenticated

# 2. Configure IAM
gcloud run services add-iam-policy-binding reddit-scraper \
    --region us-central1 \
    --member="user:your-email@gmail.com" \
    --role="roles/run.invoker"

# 3. Set up VPC connector for private access
gcloud compute networks vpc-access connectors create reddit-connector \
    --region us-central1 \
    --subnet default \
    --subnet-project $PROJECT_ID
```

---

## Cost Optimization

### **Cloud Run Pricing**

```bash
# Current pricing (as of 2024):
# - CPU: $0.00002400 per vCPU-second
# - Memory: $0.00000250 per GiB-second  
# - Requests: $0.40 per million requests
# - Free tier: 2 million requests/month

# Optimize costs:
# 1. Set minimum instances to 0
# 2. Use appropriate CPU and memory allocation
# 3. Implement request caching
# 4. Monitor usage with billing alerts
```

### **Resource Optimization**

```bash
# 1. Right-size resources
gcloud run services update reddit-scraper \
    --region us-central1 \
    --memory 256Mi \
    --cpu 500m

# 2. Set concurrency limits
gcloud run services update reddit-scraper \
    --region us-central1 \
    --concurrency 80

# 3. Configure timeouts
gcloud run services update reddit-scraper \
    --region us-central1 \
    --timeout 60s
```

---

## Scaling and Production

### **Auto Scaling Configuration**

```bash
# Configure Cloud Run auto-scaling
gcloud run services update reddit-scraper \
    --region us-central1 \
    --min-instances 1 \
    --max-instances 100 \
    --concurrency 80
```

### **Load Testing**

```bash
# Install Artillery for load testing
npm install -g artillery

# Create load test configuration
cat > load-test.yml << EOF
config:
  target: 'https://your-service-url'
  phases:
    - duration: 60
      arrivalRate: 10
      rampTo: 50
scenarios:
  - name: "Get DevOps posts"
    requests:
      - get:
          url: "/devops/top?limit=10"
EOF

# Run load test
artillery run load-test.yml
```

### **Monitoring and Alerting**

```bash
# Set up Cloud Monitoring alerts
gcloud alpha monitoring policies create --policy-from-file=- << EOF
{
  "displayName": "High Error Rate",
  "conditions": [
    {
      "displayName": "Error rate condition",
      "conditionThreshold": {
        "filter": "resource.type=\"cloud_run_revision\"",
        "comparison": "COMPARISON_GREATER_THAN",
        "thresholdValue": 0.05
      }
    }
  ],
  "notificationChannels": ["NOTIFICATION_CHANNEL_ID"]
}
EOF
```

---

## Next Steps

### **Feature Enhancements**
- **Add Authentication** - JWT tokens or OAuth
- **Add Caching** - Redis for API response caching
- **Add Database** - Store historical post data
- **Add Analytics** - Track API usage and popular posts
- **Add Search** - Full-text search across posts
- **Add Notifications** - Email/Slack alerts for trending posts

### **Infrastructure Improvements**
- **Multi-region** - Deploy across multiple regions
- **Blue-Green Deployment** - Zero-downtime deployments
- **Advanced Monitoring** - Custom metrics and dashboards
- **Security Hardening** - WAF, DDoS protection
- **Performance** - CDN integration, compression

### **DevOps Enhancements**
- **Testing** - Unit tests, integration tests
- **Code Quality** - SonarQube, code coverage
- **Dependency Management** - Automated security updates
- **Infrastructure as Code** - Complete Terraform modules
- **Documentation** - API versioning, changelog

---

## Cleanup

### **Cloud Run Cleanup**

```bash
# Delete Cloud Run service (Docker deployment)
gcloud run services delete reddit-scraper --region us-central1

# Delete Cloud Run service (Direct source deployment)
gcloud run services delete reddit-scraper-source --region us-central1

# Delete Artifact Registry repository
gcloud artifacts repositories delete devops-reddit --location us-central1
```

---

## File Structure

```
devops_reddit_scrapper/
├── main.py                    # FastAPI application
├── Dockerfile                 # Container configuration
├── pyproject.toml            # Python dependencies
├── README.md                 # This file
├── .python-version           # Python version specification
├── .gitignore                # Git ignore rules
├── .github/                  # GitHub Actions workflows
│   ├── dependabot.yaml       # Dependency updates
│   └── workflows/
│       └── build.yaml        # CI/CD pipeline
├── terraform/                # VM deployment (reference only)
│   ├── main.tf              # Terraform configuration
│   └── startup-script.sh    # VM initialization
└── k8s/                     # Kubernetes deployment (reference only)
    ├── Chart.yaml           # Helm chart metadata
    ├── values.yaml          # Helm values
    └── templates/           # Kubernetes manifests
        ├── deployment.yaml  # App deployment
        ├── service.yaml     # Service configuration
        ├── ingress.yaml     # Ingress rules
        └── hpa.yaml         # Horizontal Pod Autoscaler
```

This comprehensive deployment guide covers all aspects of deploying the DevOps Reddit Scraper application with multiple deployment options, monitoring, security, and production considerations.
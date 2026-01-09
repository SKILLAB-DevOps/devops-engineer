# Fullstack Application - VM Deployment

Deploy a complete fullstack application with frontend, backend, and database using Docker containers on Google Compute Engine VM.

## What You'll Build

A complete fullstack application featuring:
- **Frontend**: HTML/JavaScript served by Nginx
- **Backend**: FastAPI Python application with REST API
- **Database**: PostgreSQL with sample user data
- **Containerization**: Docker containers orchestrated with Docker Compose
- **User Management**: Complete CRUD operations for users

---

## Application Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │    Backend      │    │   Database      │
│   (Nginx:80)    │───▶│  (FastAPI:8000) │───▶│ (PostgreSQL:5432)│
│   HTML/JS/CSS   │    │   Python/uvicorn│    │   Sample Data   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Tech Stack
- **Frontend**: Nginx + HTML + JavaScript (Vanilla JS)
- **Backend**: FastAPI + uvicorn + psycopg2
- **Database**: PostgreSQL 15 Alpine
- **Orchestration**: Docker + Docker Compose
- **Infrastructure**: GCP Compute Engine VM

---

## Prerequisites

- **Google Cloud Account** with billing enabled
- **GCP Project** - Note your Project ID
- **Command line basics**

---

## Quick Start

### 1. Install Tools

```bash
# Install Terraform
brew install terraform

# Install Google Cloud SDK
brew install google-cloud-sdk

# Verify installations
terraform version
gcloud version
```

### 2. Authenticate

```bash
# Login to Google Cloud
gcloud auth login

# Set up credentials for Terraform
gcloud auth application-default login

# Set your project
gcloud config set project YOUR_PROJECT_ID

# Enable required APIs
gcloud services enable compute.googleapis.com
```

### 3. Configure

Edit `main.tf` and update your Project ID:

```terraform
project = "your-project-id"  # Replace with YOUR project ID
```

### 4. Deploy

```bash
# Initialize Terraform
terraform init

# Preview what will be created
terraform plan

# Create your fullstack application
terraform apply
# Type 'yes' when prompted
```

**Note:** This takes 5-7 minutes to install Docker, clone repository, build containers, and start services.

### 5. Access Your Application

```bash
# Get application URLs
terraform output frontend_url
terraform output backend_api_url
```

**Frontend Features:**
- 🌐 **User Interface** - Clean, responsive web interface
- 👥 **View Users** - List all users from database
- ➕ **Add Users** - Create new users with ID and name
- 🗑️ **Delete Users** - Remove users by ID
- 🔗 **Test Backend** - Check API connectivity
- 📊 **Real-time Updates** - Automatic refresh after operations

### 6. Test the API Directly

```bash
# Get backend URL
BACKEND_URL=$(terraform output -raw backend_api_url)

# Test root endpoint
curl $BACKEND_URL/

# Get all users
curl $BACKEND_URL/users

# Add a user
curl -X POST "$BACKEND_URL/users?user_id=10&name=John%20Doe"

# Delete a user
curl -X DELETE $BACKEND_URL/users/10
```

### 7. Clean Up

**Important:** e2-medium VMs cost ~$28/month if running 24/7:

```bash
terraform destroy
# Type 'yes' when prompted
```

---

## Application Features

### Frontend (Port 80)
- ✅ **Responsive Design** - Works on desktop and mobile
- ✅ **User Management UI** - Intuitive interface for CRUD operations
- ✅ **Real-time Feedback** - Success/error messages for all actions
- ✅ **API Integration** - Seamless backend communication
- ✅ **Connection Testing** - Backend health check functionality

### Backend API (Port 8000)
- ✅ **FastAPI Framework** - Modern, fast Python web framework
- ✅ **Automatic Documentation** - Built-in OpenAPI/Swagger docs
- ✅ **CORS Support** - Cross-origin requests enabled
- ✅ **Database Integration** - PostgreSQL connection with psycopg2
- ✅ **Error Handling** - Proper HTTP status codes and error messages

### Database (Port 5432)
- ✅ **PostgreSQL 15** - Reliable, feature-rich database
- ✅ **Persistent Storage** - Data survives container restarts
- ✅ **Sample Data** - Pre-loaded with 5 users for testing
- ✅ **Health Checks** - Container health monitoring

---

## API Endpoints

### Root Endpoint
```bash
GET /
```
Returns welcome message with API status.

### Users Management
```bash
GET /users
```
Returns all users from the database.

```bash
POST /users?user_id={id}&name={name}
```
Creates a new user with specified ID and name.

```bash
DELETE /users/{user_id}
```
Deletes the user with the specified ID.

### Sample API Usage
```bash
# Get all users
curl http://VM_IP:8000/users

# Add a user
curl -X POST "http://VM_IP:8000/users?user_id=6&name=Alice%20Smith"

# Delete a user
curl -X DELETE http://VM_IP:8000/users/6
```

---

## Default Data

The database comes pre-loaded with 5 sample users:

| ID | Name    |
|----|---------|
| 1  | Alice   |
| 2  | Bob     |
| 3  | Charlie |
| 4  | Diana   |
| 5  | Eve     |

---

## Docker Containers

The application runs three Docker containers:

### 1. Database Container
- **Image**: postgres:15-alpine
- **Port**: 5432
- **Environment**: 
  - POSTGRES_USER=fullstack
  - POSTGRES_PASSWORD=fullstack
  - POSTGRES_DB=fullstack
- **Initialization**: Runs init.sql on first start

### 2. Backend Container
- **Image**: python:3.13-slim + FastAPI
- **Port**: 8000
- **Dependencies**: fastapi, uvicorn, psycopg2-binary
- **Environment Variables**: Database connection settings

### 3. Frontend Container
- **Image**: nginx:latest
- **Port**: 80
- **Content**: Serves static HTML/CSS/JavaScript

---

## VM Management

```bash
# SSH into the VM
gcloud compute ssh fullstack-app-vm --zone=us-central1-a

# Check Docker containers
sudo docker-compose ps

# View container logs
sudo docker-compose logs frontend
sudo docker-compose logs backend
sudo docker-compose logs db

# Restart containers
sudo docker-compose restart

# Stop containers
sudo docker-compose down

# Start containers
sudo docker-compose up -d

# Rebuild containers (after code changes)
sudo docker-compose up -d --build
```

---

## Development & Customization

### Modify the Frontend
```bash
# SSH to VM and edit the frontend
cd /opt/fullstack-app
sudo nano index.html

# Rebuild frontend container
sudo docker-compose up -d --build frontend
```

### Modify the Backend API
```bash
# Edit the Python backend
sudo nano main.py

# Rebuild backend container
sudo docker-compose up -d --build backend
```

### Add Database Tables
```bash
# Connect to PostgreSQL
sudo docker-compose exec db psql -U fullstack -d fullstack

# Run SQL commands
CREATE TABLE products (id SERIAL PRIMARY KEY, name VARCHAR(100), price DECIMAL);
INSERT INTO products (name, price) VALUES ('Laptop', 999.99);
\q
```

### Monitor Container Resources
```bash
# Check container stats
sudo docker stats

# Check disk usage
sudo docker system df

# View container details
sudo docker inspect fullstack-app-backend-1
```

---

## Application URLs

After deployment, you'll have access to:

- **Frontend Application**: `http://VM_IP/`
- **Backend API Root**: `http://VM_IP:8000/`
- **Users API**: `http://VM_IP:8000/users`
- **API Documentation**: `http://VM_IP:8000/docs` (FastAPI auto-generated)
- **Database**: `VM_IP:5432` (PostgreSQL - internal access)

---

## Troubleshooting

### Application Not Loading
```bash
# Check container status
sudo docker-compose ps

# Check container logs
sudo docker-compose logs

# Restart all containers
sudo docker-compose restart
```

### Database Connection Issues
```bash
# Check database container health
sudo docker-compose exec db pg_isready -U fullstack

# View database logs
sudo docker-compose logs db

# Connect to database manually
sudo docker-compose exec db psql -U fullstack -d fullstack
```

### Frontend/Backend Communication Issues
```bash
# Test backend from VM
curl localhost:8000/users

# Check if ports are open
sudo netstat -tlnp | grep -E ':80|:8000|:5432'

# View backend logs
sudo docker-compose logs backend
```

### Docker Issues
```bash
# Check Docker service
sudo systemctl status docker

# Restart Docker
sudo systemctl restart docker

# Clean up Docker resources
sudo docker system prune -f
```

---

## Security Considerations

### For Production Use
- 🔒 **Change Database Passwords** - Use strong, unique passwords
- 🛡️ **Restrict Firewall Rules** - Limit access to specific IPs
- 🔐 **Add HTTPS** - Use SSL certificates for encrypted communication
- 🚫 **Remove Debug Mode** - Disable FastAPI debug mode
- 🔑 **Add Authentication** - Implement user authentication and authorization
- 📊 **Add Monitoring** - Set up logging and monitoring systems

### Environment Variables
```bash
# Example production environment variables
export DB_PASSWORD="your-secure-password"
export SECRET_KEY="your-secret-key"
export ALLOWED_HOSTS="your-domain.com"
```

---

## Cost Information

**e2-medium VM:**
- ~$28/month if running 24/7
- ~$0.038/hour
- 2 vCPUs, 4 GB RAM

**Disk:** 30 GB standard persistent disk (~$1.20/month)

**Network:** Minimal egress charges for API calls

**Ways to save:**
- Use `e2-small` for development/testing
- Stop VM when not in use (data persists)
- Always `terraform destroy` when learning

---

## Scaling & Production

### Horizontal Scaling
- **Load Balancer** - Multiple VM instances behind GCP Load Balancer
- **Cloud SQL** - Managed PostgreSQL database
- **Container Registry** - Store custom Docker images
- **Cloud Run** - Serverless container deployment

### Monitoring & Logging
- **Cloud Monitoring** - VM and application metrics
- **Cloud Logging** - Centralized log management
- **Health Checks** - Application health monitoring
- **Alerting** - Automated notifications for issues

---

## Next Steps

- 🔐 **Add Authentication** - User login and JWT tokens
- 📱 **Build Mobile App** - React Native or Flutter frontend
- 🛒 **Add More Features** - Products, orders, shopping cart
- 🔍 **Add Search** - Full-text search capabilities
- 📊 **Add Analytics** - User behavior and usage metrics
- 🚀 **CI/CD Pipeline** - Automated deployments
- ☁️ **Cloud Native** - Migrate to Kubernetes or Cloud Run
- 🌐 **Multi-region** - Deploy across multiple regions

---

## File Overview

- **`main.tf`** - Terraform infrastructure definition
- **`startup.sh`** - VM initialization and deployment script
- **Source Code** - Cloned from GitHub repository during deployment

### Original Repository Structure
- **`docker-compose.yaml`** - Container orchestration
- **`Dockerfile.backend`** - Backend container definition
- **`Dockerfile.frontend`** - Frontend container definition  
- **`Dockerfile.db`** - Database container definition
- **`main.py`** - FastAPI application code
- **`index.html`** - Frontend user interface
- **`init.sql`** - Database initialization script
- **`pyproject.toml`** - Python dependencies

---

## Pros of This Deployment
- ✅ **Complete Stack** - Frontend, backend, and database included
- ✅ **Containerized** - Portable and consistent across environments
- ✅ **Real Application** - Functional user management system
- ✅ **Modern Tech Stack** - FastAPI, PostgreSQL, Docker
- ✅ **Easy to Extend** - Add features and scale components
- ✅ **Educational Value** - Learn fullstack development patterns

## Cons of VM Deployment
- ❌ **Manual Scaling** - No auto-scaling capabilities
- ❌ **Single Point of Failure** - All components on one VM
- ❌ **OS Maintenance** - Manual updates and patches required
- ❌ **Resource Sharing** - All containers share VM resources
- ❌ **Always Running** - Costs even when not in use
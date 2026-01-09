# Native Fullstack Application - VM Deployment

Deploy a complete fullstack application with frontend, backend, and database running natively on the VM (no Docker containers).

## What You'll Build

A complete native fullstack application featuring:
- **Frontend**: HTML/JavaScript served by Nginx (native installation)
- **Backend**: FastAPI Python application (direct Python installation)
- **Database**: PostgreSQL (system service installation)
- **Services**: All components run as systemd services
- **User Management**: Complete CRUD operations for users

---

## Application Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │    Backend      │    │   Database      │
│   (Nginx:80)    │───▶│  (FastAPI:8000) │───▶│ (PostgreSQL:5432)│
│  Native Install │    │ Python venv     │    │ System Service  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Native Architecture Benefits
- **⚡ Better Performance** - No containerization overhead
- **🔧 Direct System Access** - Full control over services and configuration
- **💾 Lower Resource Usage** - No Docker daemon or container layers
- **🚀 Faster Startup** - Services start directly with the system
- **🛠️ Easier Debugging** - Direct access to logs and processes

---

## Tech Stack (Native Installation)

- **OS**: Ubuntu 22.04 LTS
- **Frontend**: Nginx + HTML + Vanilla JavaScript
- **Backend**: FastAPI + uvicorn (Python virtual environment)
- **Database**: PostgreSQL 14 (apt package)
- **Process Management**: systemd services
- **Proxy**: Nginx reverse proxy for API endpoints

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

# Create your native fullstack application
terraform apply
# Type 'yes' when prompted
```

**Note:** This takes 3-5 minutes to install all native components and configure services.

### 5. Access Your Application

```bash
# Get application URLs
terraform output frontend_url
terraform output backend_api_url
```

**Frontend Features:**
- 🌐 **Modern UI** - Responsive design with gradient styling
- 👥 **User Management** - View, add, and delete users
- 📊 **Real-time Stats** - Live backend and database status
- 🔗 **API Testing** - Built-in backend connectivity tests
- ❤️ **Health Monitoring** - System health checks
- 📱 **Mobile Responsive** - Works on all devices

### 6. Test the Native Services

```bash
# Get backend URL
BACKEND_URL=$(terraform output -raw backend_api_url)

# Test health endpoint
curl $BACKEND_URL/health

# Get all users
curl $BACKEND_URL/users

# Add a user
curl -X POST "$BACKEND_URL/users?user_id=10&name=John%20Doe"

# Delete a user
curl -X DELETE $BACKEND_URL/users/10

# Get API documentation
curl $BACKEND_URL/docs
```

### 7. Clean Up

**Important:** e2-medium VMs cost ~$28/month if running 24/7:

```bash
terraform destroy
# Type 'yes' when prompted
```

---

## Native Services Overview

### 🌐 Nginx Frontend Service
- **Installation**: `apt install nginx`
- **Configuration**: Custom site configuration in `/etc/nginx/sites-available/`
- **Service**: `systemctl status nginx`
- **Logs**: `journalctl -u nginx -f`
- **Features**: 
  - Serves static HTML/CSS/JavaScript
  - Reverse proxy for API endpoints
  - Custom error pages and headers

### 🐍 FastAPI Backend Service
- **Installation**: Python virtual environment with pip
- **Location**: `/opt/fullstack-backend/`
- **Service**: `systemctl status fullstack-backend`
- **Logs**: `journalctl -u fullstack-backend -f`
- **Features**:
  - FastAPI with automatic OpenAPI docs
  - PostgreSQL connection with connection pooling
  - CORS middleware for frontend integration
  - Comprehensive error handling

### 🗄️ PostgreSQL Database Service
- **Installation**: `apt install postgresql postgresql-contrib`
- **Service**: `systemctl status postgresql`
- **Logs**: `journalctl -u postgresql -f`
- **Configuration**:
  - Database: `fullstack`
  - User: `fullstack`
  - Pre-loaded with 5 sample users

---

## Service Management

### Check Service Status
```bash
# SSH into the VM
gcloud compute ssh fullstack-native-vm --zone=us-central1-a

# Check all services
sudo systemctl status nginx fullstack-backend postgresql

# Individual service status
sudo systemctl status nginx
sudo systemctl status fullstack-backend
sudo systemctl status postgresql
```

### View Service Logs
```bash
# Backend application logs
sudo journalctl -u fullstack-backend -f

# Nginx access and error logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# PostgreSQL logs
sudo journalctl -u postgresql -f
```

### Restart Services
```bash
# Restart individual services
sudo systemctl restart nginx
sudo systemctl restart fullstack-backend
sudo systemctl restart postgresql

# Restart all services
sudo systemctl restart nginx fullstack-backend postgresql
```

---

## API Endpoints

### Root & Health
```bash
GET /                 # API information and endpoints
GET /health          # System health check with DB status
```

### User Management
```bash
GET /users           # Get all users
POST /users          # Create user (query params: user_id, name)
DELETE /users/{id}   # Delete user by ID
```

### Interactive API Documentation
- **Swagger UI**: `http://VM_IP:8000/docs`
- **ReDoc**: `http://VM_IP:8000/redoc`
- **OpenAPI Schema**: `http://VM_IP:8000/openapi.json`

---

## Database Operations

### Connect to PostgreSQL
```bash
# Connect as fullstack user
sudo -u postgres psql -d fullstack

# Or from the VM
psql -h localhost -U fullstack -d fullstack
```

### Common SQL Operations
```sql
-- View all users
SELECT * FROM users;

-- Add a user
INSERT INTO users (id, name) VALUES (6, 'Frank');

-- Update a user
UPDATE users SET name = 'Franklin' WHERE id = 6;

-- Delete a user
DELETE FROM users WHERE id = 6;

-- Check table structure
\d users
```

### Database Backup & Restore
```bash
# Create backup
sudo -u postgres pg_dump fullstack > fullstack_backup.sql

# Restore from backup
sudo -u postgres psql fullstack < fullstack_backup.sql
```

---

## File Locations

### Application Files
```
/opt/fullstack-backend/          # Backend application
├── main.py                      # FastAPI application
├── venv/                        # Python virtual environment
└── requirements.txt             # Python dependencies

/var/www/fullstack/              # Frontend files
└── index.html                   # Main application UI

/etc/nginx/sites-available/      # Nginx configuration
└── fullstack                    # Site configuration

/etc/systemd/system/             # Service definitions
└── fullstack-backend.service    # Backend service
```

### Configuration Files
```bash
# Nginx site configuration
/etc/nginx/sites-available/fullstack

# Backend service definition
/etc/systemd/system/fullstack-backend.service

# PostgreSQL configuration
/etc/postgresql/14/main/postgresql.conf
```

---

## Performance & Monitoring

### Resource Usage
```bash
# Check memory usage
free -h

# Check disk usage
df -h

# Check CPU usage
top

# Check network connections
netstat -tlnp
```

### Application Metrics
```bash
# Backend process info
ps aux | grep python

# Nginx process info
ps aux | grep nginx

# PostgreSQL process info
ps aux | grep postgres

# Check open ports
sudo netstat -tlnp | grep -E ':80|:8000|:5432'
```

### Log Analysis
```bash
# Backend response times
sudo journalctl -u fullstack-backend | grep "GET\|POST\|DELETE"

# Nginx access patterns
sudo awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -nr

# Database connections
sudo -u postgres psql -c "SELECT * FROM pg_stat_activity;"
```

---

## Development & Customization

### Modify Backend API
```bash
# Edit the FastAPI application
sudo nano /opt/fullstack-backend/main.py

# Restart backend service
sudo systemctl restart fullstack-backend

# Check service status
sudo systemctl status fullstack-backend
```

### Update Frontend
```bash
# Edit the HTML interface
sudo nano /var/www/fullstack/index.html

# Nginx automatically serves updated files
# No restart needed for static content
```

### Add New API Endpoints
```python
# Add to /opt/fullstack-backend/main.py
@app.get("/api/stats")
def get_stats():
    with get_db_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM users")
        count = cursor.fetchone()[0]
    return {"total_users": count, "status": "active"}
```

### Database Schema Changes
```bash
# Connect to database
sudo -u postgres psql -d fullstack

# Add new table
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2)
);
```

---

## Security Considerations

### Production Hardening
- 🔒 **Change Database Password** - Use strong password for PostgreSQL
- 🛡️ **Firewall Rules** - Restrict access to specific IPs
- 🔐 **HTTPS Setup** - Add SSL certificates
- 🚫 **Disable Debug Mode** - Remove development features
- 🔑 **API Authentication** - Add JWT or API key authentication
- 📊 **Log Monitoring** - Set up log analysis and alerting

### Security Commands
```bash
# Change PostgreSQL password
sudo -u postgres psql -c "ALTER USER fullstack PASSWORD 'new-secure-password';"

# Check open ports
sudo ufw status
sudo netstat -tlnp

# Review service configurations
sudo systemctl show fullstack-backend
```

---

## Troubleshooting

### Backend Service Issues
```bash
# Check service status
sudo systemctl status fullstack-backend

# View detailed logs
sudo journalctl -u fullstack-backend -f

# Test Python application directly
cd /opt/fullstack-backend
source venv/bin/activate
python main.py
```

### Database Connection Issues
```bash
# Check PostgreSQL status
sudo systemctl status postgresql

# Test database connection
sudo -u postgres psql -c "SELECT version();"

# Check database exists
sudo -u postgres psql -l | grep fullstack
```

### Nginx Configuration Issues
```bash
# Test Nginx configuration
sudo nginx -t

# Check Nginx status
sudo systemctl status nginx

# View error logs
sudo tail -f /var/log/nginx/error.log
```

### Network Connectivity Issues
```bash
# Check if ports are listening
sudo netstat -tlnp | grep -E ':80|:8000'

# Test localhost connectivity
curl localhost:8000/health
curl localhost/

# Check firewall rules
sudo ufw status verbose
```

---

## Cost Information

**e2-medium VM:**
- ~$28/month if running 24/7
- ~$0.038/hour  
- 2 vCPUs, 4 GB RAM

**Disk:** 25 GB standard persistent disk (~$1/month)

**Native vs Docker Comparison:**
- **🚀 Lower CPU Usage** - No Docker daemon overhead
- **💾 Less Memory Usage** - No container runtime
- **📦 Smaller Disk Usage** - No Docker images
- **⚡ Faster Performance** - Direct system calls

---

## Scaling & Production

### Horizontal Scaling Options
- **Load Balancer** - Multiple VM instances with shared database
- **Database Separation** - Move to Cloud SQL for managed PostgreSQL
- **CDN Integration** - Use Cloud CDN for static assets
- **Auto Scaling** - Instance groups with auto-scaling

### Migration Paths
- **Containerization** - Convert to Docker containers later
- **Kubernetes** - Move to GKE for orchestration
- **Serverless** - Migrate to Cloud Run for backend
- **Microservices** - Split into separate services

---

## Next Steps

- 🔐 **Add Authentication** - User login and session management
- 📊 **Add Monitoring** - Prometheus/Grafana monitoring stack
- 🔍 **Add Logging** - Centralized logging with ELK stack
- 📱 **Mobile App** - React Native or Flutter frontend
- 🛒 **E-commerce Features** - Products, orders, payments
- 🚀 **CI/CD Pipeline** - Automated deployments
- ☁️ **Cloud Services** - Integrate with GCP services
- 🌐 **Multi-region** - Deploy across multiple regions

---

## Pros of Native Deployment
- ✅ **Maximum Performance** - No containerization overhead
- ✅ **Direct System Control** - Full access to OS and services
- ✅ **Lower Resource Usage** - Efficient memory and CPU usage
- ✅ **Simpler Debugging** - Direct access to processes and logs
- ✅ **Faster Startup** - Services start directly with system
- ✅ **Standard Tools** - Use familiar system administration tools

## Cons of Native Deployment
- ❌ **Environment Consistency** - Harder to replicate across environments
- ❌ **Dependency Management** - Manual handling of system dependencies
- ❌ **Scaling Complexity** - More complex to scale horizontally
- ❌ **Isolation** - Services share the same system resources
- ❌ **Migration Challenges** - Harder to move between different environments
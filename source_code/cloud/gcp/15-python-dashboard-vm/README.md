# Python Dashboard - VM Deployment

Deploy a comprehensive analytics dashboard with Flask, PostgreSQL, and Plotly on Google Compute Engine VM.

## What You'll Build

A full-featured business analytics dashboard with:
- **Interactive Charts** using Plotly.js
- **Real-time Data** with auto-refresh
- **PostgreSQL Database** for data persistence  
- **REST API** for data endpoints
- **Admin Panel** for data management

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

# Create your dashboard
terraform apply
# Type 'yes' when prompted
```

**Note:** This takes 3-5 minutes to install Python, PostgreSQL, and all dependencies.

### 5. Access Your Dashboard

```bash
# Get your dashboard URL
terraform output dashboard_url
```

Copy the URL and open it in your browser. You'll see a modern analytics dashboard with:
- 📊 Sales by Product (Bar Chart)
- 🌍 Sales by Region (Pie Chart)  
- 👥 User Activity Timeline
- 📈 Real-time Statistics

### 6. Explore Features

- **Dashboard:** Interactive charts with hover details
- **Admin Panel:** `/admin` - Add sample data
- **API Endpoints:** `/api/sales`, `/api/activity`, `/api/regions`
- **Health Check:** `/health` - System status

### 7. Clean Up

**Important:** e2-medium VMs cost ~$28/month if running 24/7:

```bash
terraform destroy
# Type 'yes' when prompted
```

---

## What's Installed

### Tech Stack
- **Python 3.10** with Flask web framework
- **PostgreSQL 14** database server
- **Plotly.js** for interactive charts
- **Bootstrap 5** for responsive UI
- **Gunicorn** WSGI server for production

### Database Schema
- **SalesData:** Product sales by region and date
- **UserActivity:** Hourly user and page view metrics

### Features
- ✅ **Interactive Charts** - Hover, zoom, pan
- ✅ **Real-time Updates** - Auto-refresh every 30 seconds  
- ✅ **Responsive Design** - Works on mobile and desktop
- ✅ **REST API** - JSON endpoints for all data
- ✅ **Admin Interface** - Add/manage sample data
- ✅ **Health Monitoring** - System status endpoint

---

## API Endpoints

```bash
# Get dashboard URL
DASHBOARD_URL=$(terraform output -raw dashboard_url)

# Sales data
curl $DASHBOARD_URL/api/sales

# User activity  
curl $DASHBOARD_URL/api/activity

# Regional breakdown
curl $DASHBOARD_URL/api/regions

# Health check
curl $DASHBOARD_URL/health
```

---

## VM Management

```bash
# SSH into the VM
gcloud compute ssh python-dashboard-vm --zone=us-central1-a

# Check application status
sudo systemctl status python-dashboard

# View application logs
sudo journalctl -u python-dashboard -f

# Restart application
sudo systemctl restart python-dashboard

# Check PostgreSQL status
sudo systemctl status postgresql

# Access PostgreSQL
sudo -u postgres psql dashboarddb
```

---

## Customization

### Add New Charts

1. **Extend the database model** in `app.py`
2. **Create API endpoint** for your data
3. **Add chart to frontend** in `dashboard.html`

### Sample: Add Revenue Chart

```python
# In app.py
@app.route('/api/revenue')
def api_revenue():
    # Your revenue calculation logic
    return jsonify({'chart': chart_json, 'total': total})
```

```javascript
// In dashboard.html
async function loadRevenueChart() {
    const response = await fetch('/api/revenue');
    const data = await response.json();
    Plotly.newPlot('revenue-chart', JSON.parse(data.chart));
}
```

---

## Production Considerations

### Security
- 🔒 Change default database passwords
- 🔐 Use environment variables for secrets
- 🛡️ Restrict firewall to specific IPs
- 🔑 Enable HTTPS with SSL certificates

### Scaling
- 📈 Use Cloud SQL for managed database
- ⚡ Add Redis for caching
- 🔄 Use multiple VM instances with load balancer
- 📊 Add monitoring and alerting

### Performance
- 🚀 Optimize database queries
- 💾 Add database indexing
- 🗜️ Enable gzip compression
- 📦 Use CDN for static assets

---

## Troubleshooting

**Dashboard not loading**
- Wait 5 minutes for full installation
- Check service status: `sudo systemctl status python-dashboard`
- View logs: `sudo journalctl -u python-dashboard -f`

**Database connection errors**
- Check PostgreSQL: `sudo systemctl status postgresql`
- Verify database exists: `sudo -u postgres psql -l`

**Charts not displaying**
- Check browser console for JavaScript errors
- Verify API endpoints return data: `curl localhost:5000/api/sales`

**"No data available" messages**
- Use Admin Panel to add sample data
- Or run: `python3 init_db.py` on the VM

---

## Cost Information

**e2-medium VM:**
- ~$28/month if running 24/7
- ~$0.038/hour
- 2 vCPUs, 4 GB RAM

**Disk:** 30 GB standard persistent disk (~$1.20/month)

**Ways to save:**
- Use `e2-small` for lighter workloads
- Stop VM when not in use
- Always `terraform destroy` when learning

---

## Next Steps

- 📊 **Add more data sources** (APIs, files, databases)
- 🔄 **Set up automated data pipelines**
- 📱 **Create mobile-responsive views**  
- 🚨 **Add alerting and notifications**
- 📈 **Implement machine learning predictions**
- 🔐 **Add user authentication**
- ☁️ **Migrate to Cloud Run for serverless**

---

## File Overview

- **`main.tf`** - Infrastructure definition
- **`startup.sh`** - VM setup script
- **`app.py`** - Flask application with API endpoints
- **`init_db.py`** - Database initialization
- **`templates/dashboard.html`** - Main dashboard UI
- **`templates/admin.html`** - Admin panel UI

---

## Pros of VM Deployment
- ✅ Full control over environment
- ✅ Can install any dependencies  
- ✅ Persistent data storage
- ✅ Easy debugging and monitoring
- ✅ Cost-effective for steady workloads
- ✅ Direct database access

## Cons of VM Deployment  
- ❌ Manual scaling required
- ❌ OS maintenance and updates
- ❌ Always running costs
- ❌ No automatic failover
- ❌ Manual backup management
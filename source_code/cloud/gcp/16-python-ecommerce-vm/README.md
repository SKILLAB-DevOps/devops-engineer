# Django E-commerce API - VM Deployment

Deploy a comprehensive e-commerce REST API with Django, SQLite, and Swagger documentation on Google Compute Engine VM.

## What You'll Build

A full-featured e-commerce API with:
- **RESTful API** with Django REST Framework
- **Product Management** with categories and inventory
- **Order Processing** with customer management
- **Admin Interface** with Django admin panel
- **API Documentation** with Swagger/OpenAPI
- **Database** with SQLite for simplicity

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

# Create your e-commerce API
terraform apply
# Type 'yes' when prompted
```

**Note:** This takes 3-5 minutes to install Python, Django, and all dependencies.

### 5. Access Your API

```bash
# Get your API URL
terraform output api_url

# Get admin panel URL
terraform output admin_url

# Get Swagger documentation URL
terraform output swagger_docs
```

### 6. Explore the API

**Default Admin Credentials:**
- Username: `admin`
- Password: `admin123`

**Key Endpoints:**
- **Root API:** `/` - API overview
- **Products:** `/api/products/` - Product management
- **Categories:** `/api/categories/` - Category management
- **Orders:** `/api/orders/` - Order management
- **Customers:** `/api/customers/` - Customer management
- **Admin:** `/admin/` - Django admin interface
- **API Docs:** `/swagger/` - Interactive API documentation

### 7. Test the API

```bash
# Get API URL
API_URL=$(terraform output -raw api_url)

# List all products
curl $API_URL/api/products/

# Get specific product
curl $API_URL/api/products/1/

# List categories
curl $API_URL/api/categories/

# Get featured products
curl $API_URL/api/products/featured/

# Get low stock products
curl $API_URL/api/products/low_stock/

# Get order statistics
curl $API_URL/api/orders/statistics/
```

### 8. Clean Up

**Important:** e2-medium VMs cost ~$28/month if running 24/7:

```bash
terraform destroy
# Type 'yes' when prompted
```

---

## API Features

### Product Management
- ✅ **CRUD Operations** - Create, read, update, delete products
- ✅ **Category Organization** - Products grouped by categories
- ✅ **Inventory Tracking** - Stock quantity management
- ✅ **Search & Filter** - Search by name, filter by category/price
- ✅ **Featured Products** - Highlight popular items
- ✅ **Stock Alerts** - Identify low-stock products

### Order Processing
- ✅ **Order Management** - Complete order lifecycle
- ✅ **Status Tracking** - Pending, processing, shipped, delivered
- ✅ **Customer Relations** - Link orders to customers
- ✅ **Order Statistics** - Revenue and order analytics
- ✅ **Order Items** - Detailed order composition

### API Documentation
- ✅ **OpenAPI/Swagger** - Interactive API documentation
- ✅ **Schema Export** - Machine-readable API schema
- ✅ **Try It Out** - Test endpoints directly from docs
- ✅ **Model Schemas** - Detailed request/response formats

---

## Sample Data Included

### Categories
- **Electronics** - Laptops, phones, tablets, headphones
- **Clothing** - T-shirts, jeans, shoes
- **Books** - Programming and technical books
- **Home & Garden** - Tools and supplies

### Products (12 items)
- Various price ranges ($29.99 - $1299.99)
- Different stock levels (0 - 100 items)
- Placeholder images
- Realistic descriptions

---

## API Endpoints Reference

### Products API
```bash
GET    /api/products/           # List all products
POST   /api/products/           # Create new product
GET    /api/products/{id}/      # Get specific product
PUT    /api/products/{id}/      # Update product
DELETE /api/products/{id}/      # Delete product
GET    /api/products/featured/  # Get featured products
GET    /api/products/low_stock/ # Get low stock products
```

### Categories API
```bash
GET    /api/categories/         # List all categories
POST   /api/categories/         # Create new category
GET    /api/categories/{id}/    # Get specific category
GET    /api/categories/{id}/products/ # Get category products
```

### Orders API
```bash
GET    /api/orders/             # List all orders
POST   /api/orders/             # Create new order
GET    /api/orders/{id}/        # Get specific order
PATCH  /api/orders/{id}/update_status/ # Update order status
GET    /api/orders/statistics/  # Get order statistics
```

### Query Parameters
```bash
# Product filtering
?category=1                     # Filter by category
?min_price=50&max_price=200     # Price range
?in_stock=true                  # Only in-stock items
?search=laptop                  # Search by name/description
?ordering=-created_at           # Sort by creation date (desc)

# Pagination
?page=2                         # Page number
?page_size=20                   # Items per page (default: 20)
```

---

## VM Management

```bash
# SSH into the VM
gcloud compute ssh django-ecommerce-vm --zone=us-central1-a

# Check application status
sudo systemctl status django-ecommerce

# View application logs
sudo journalctl -u django-ecommerce -f

# Restart application
sudo systemctl restart django-ecommerce

# Access Django shell
cd /opt/django-ecommerce
source venv/bin/activate
python manage.py shell

# Run database migrations
python manage.py migrate

# Create new superuser
python manage.py createsuperuser
```

---

## Development & Customization

### Add New Models

1. **Extend models** in `store/models.py`
2. **Create serializers** in `store/serializers.py`  
3. **Add viewsets** in `store/views.py`
4. **Update URLs** in `store/urls.py`
5. **Run migrations:**

```bash
python manage.py makemigrations
python manage.py migrate
```

### Sample: Add Reviews Model

```python
# In store/models.py
class Review(models.Model):
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    customer = models.ForeignKey(Customer, on_delete=models.CASCADE)
    rating = models.IntegerField(choices=[(i, i) for i in range(1, 6)])
    comment = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
```

### Custom API Endpoints

```python
# In store/views.py
@action(detail=True, methods=['get'])
def reviews(self, request, pk=None):
    product = self.get_object()
    reviews = product.review_set.all()
    # Return serialized reviews
```

---

## Tech Stack

### Backend
- **Python 3.10** - Programming language
- **Django 4.2** - Web framework
- **Django REST Framework** - API framework
- **SQLite** - Database (simple, file-based)
- **Gunicorn** - WSGI server for production

### API Features
- **drf-spectacular** - OpenAPI/Swagger documentation
- **django-cors-headers** - CORS support
- **django-filter** - Advanced filtering
- **Pagination** - Built-in REST framework pagination

---

## Production Considerations

### Security
- 🔒 **Change SECRET_KEY** - Use environment variable
- 🛡️ **Disable DEBUG** - Set DEBUG=False in production
- 🔐 **Use strong admin password** - Change default credentials
- 🚫 **Restrict ALLOWED_HOSTS** - Limit to your domain
- 🔑 **Add authentication** - JWT or session-based auth

### Database
- 🗄️ **Use PostgreSQL** - For production workloads
- 📊 **Add database indexes** - Optimize query performance
- 💾 **Setup backups** - Regular database backups
- 📈 **Monitor queries** - Use Django Debug Toolbar

### Scaling
- ⚡ **Use Redis** - For caching and sessions
- 🔄 **Load balancing** - Multiple VM instances
- 📦 **Static files** - Use Cloud Storage for media
- 📊 **Monitoring** - Add application monitoring

### Example Production Settings
```python
# settings_production.py
DEBUG = False
ALLOWED_HOSTS = ['your-domain.com']
SECRET_KEY = os.environ['SECRET_KEY']

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.environ['DB_NAME'],
        'USER': os.environ['DB_USER'],
        'PASSWORD': os.environ['DB_PASSWORD'],
        'HOST': os.environ['DB_HOST'],
        'PORT': '5432',
    }
}
```

---

## Troubleshooting

**API not accessible**
- Wait 5 minutes for full installation
- Check service status: `sudo systemctl status django-ecommerce`
- View logs: `sudo journalctl -u django-ecommerce -f`

**Database errors**
- Check if migrations ran: `python manage.py showmigrations`
- Run migrations manually: `python manage.py migrate`
- Check database file permissions

**Admin panel not working**
- Verify superuser exists: `python manage.py shell`
- Create new superuser: `python manage.py createsuperuser`
- Check static files: `python manage.py collectstatic`

**Swagger docs not loading**
- Verify drf-spectacular is installed
- Check API schema: `curl API_URL/api/schema/`
- Restart the service

---

## Cost Information

**e2-medium VM:**
- ~$28/month if running 24/7
- ~$0.038/hour
- 2 vCPUs, 4 GB RAM

**Disk:** 25 GB standard persistent disk (~$1/month)

**Ways to save:**
- Use `e2-small` for development/testing
- Stop VM when not in use
- Always `terraform destroy` when learning

---

## Next Steps

- 🔐 **Add Authentication** - JWT tokens or OAuth
- 📱 **Build Frontend** - React/Vue.js client
- 🛒 **Add Shopping Cart** - Session-based cart
- 💳 **Payment Integration** - Stripe/PayPal
- 📧 **Email Notifications** - Order confirmations
- 📊 **Analytics** - Sales and user analytics
- 🔍 **Full-text Search** - Elasticsearch integration
- ☁️ **Migrate to Cloud Run** - Serverless deployment

---

## File Overview

- **`main.tf`** - Infrastructure definition
- **`startup.sh`** - VM setup script
- **`ecommerce/`** - Django project directory
- **`store/`** - Main application with models, views, APIs
- **`sample_data.json`** - Initial data fixture
- **`manage.py`** - Django management script

---

## Pros of VM Deployment
- ✅ Full control over environment
- ✅ Can install any dependencies
- ✅ Direct database access
- ✅ Easy debugging and monitoring
- ✅ Persistent data storage
- ✅ Cost-effective for steady workloads

## Cons of VM Deployment
- ❌ Manual scaling required
- ❌ OS maintenance and updates
- ❌ Always running costs
- ❌ No automatic failover
- ❌ Manual backup management
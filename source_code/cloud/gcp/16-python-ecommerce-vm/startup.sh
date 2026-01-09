#!/bin/bash

echo " Installing Django E-commerce API on VM..."

# Update system
apt-get update
apt-get install -y python3 python3-pip python3-venv

# Create app directory
mkdir -p /opt/django-ecommerce
cd /opt/django-ecommerce

# Copy application files
cp -r /tmp/app-files/* /opt/django-ecommerce/

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install django djangorestframework django-cors-headers pillow drf-spectacular gunicorn

# Set up Django project
export DJANGO_SETTINGS_MODULE=ecommerce.settings
export SECRET_KEY='django-insecure-vm-demo-key-change-in-production'

# Run migrations
python manage.py makemigrations
python manage.py migrate

# Create superuser (non-interactive)
echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('admin', 'admin@example.com', 'admin123') if not User.objects.filter(username='admin').exists() else None" | python manage.py shell

# Load sample data
python manage.py loaddata sample_data.json

# Collect static files
python manage.py collectstatic --noinput

# Create systemd service
cat > /etc/systemd/system/django-ecommerce.service << EOF
[Unit]
Description=Django E-commerce API Application
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/opt/django-ecommerce
Environment=PATH=/opt/django-ecommerce/venv/bin
Environment=DJANGO_SETTINGS_MODULE=ecommerce.settings
Environment=SECRET_KEY=django-insecure-vm-demo-key-change-in-production
ExecStart=/opt/django-ecommerce/venv/bin/gunicorn --bind 0.0.0.0:8000 --workers 2 ecommerce.wsgi:application
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Set correct permissions
chown -R ubuntu:ubuntu /opt/django-ecommerce

# Enable and start service
systemctl daemon-reload
systemctl enable django-ecommerce
systemctl start django-ecommerce

# Wait for service to start
sleep 5

echo " Django E-commerce API installed and running on port 8000"
echo " API URL: http://$(curl -s ifconfig.me):8000"
echo " Admin panel: http://$(curl -s ifconfig.me):8000/admin (admin/admin123)"
echo " API docs: http://$(curl -s ifconfig.me):8000/swagger/"
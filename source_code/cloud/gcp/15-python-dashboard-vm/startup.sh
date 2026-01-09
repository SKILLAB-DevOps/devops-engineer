#!/bin/bash

echo " Installing Python Dashboard on VM..."

# Update system
apt-get update
apt-get install -y python3 python3-pip python3-venv postgresql postgresql-contrib

# Start and enable PostgreSQL
systemctl start postgresql
systemctl enable postgresql

# Configure PostgreSQL
sudo -u postgres psql << EOF
CREATE DATABASE dashboarddb;
CREATE USER dashuser WITH PASSWORD 'dashpass123';
GRANT ALL PRIVILEGES ON DATABASE dashboarddb TO dashuser;
ALTER USER dashuser CREATEDB;
\q
EOF

# Create app directory
mkdir -p /opt/python-dashboard
cd /opt/python-dashboard

# Copy application files
cp -r /tmp/app-files/* /opt/python-dashboard/

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install flask flask-sqlalchemy psycopg2-binary plotly pandas numpy requests gunicorn

# Set up database tables and sample data
export DATABASE_URL="postgresql://dashuser:dashpass123@localhost/dashboarddb"
python3 init_db.py

# Create systemd service
cat > /etc/systemd/system/python-dashboard.service << EOF
[Unit]
Description=Python Dashboard Flask Application
After=network.target postgresql.service

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/opt/python-dashboard
Environment=PATH=/opt/python-dashboard/venv/bin
Environment=DATABASE_URL=postgresql://dashuser:dashpass123@localhost/dashboarddb
Environment=FLASK_ENV=production
ExecStart=/opt/python-dashboard/venv/bin/gunicorn --bind 0.0.0.0:5000 --workers 2 app:app
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Set correct permissions
chown -R ubuntu:ubuntu /opt/python-dashboard

# Enable and start service
systemctl daemon-reload
systemctl enable python-dashboard
systemctl start python-dashboard

# Wait for service to start
sleep 5

echo " Python Dashboard installed and running on port 5000"
echo " Dashboard URL: http://$(curl -s ifconfig.me):5000"
echo " Admin panel: http://$(curl -s ifconfig.me):5000/admin"
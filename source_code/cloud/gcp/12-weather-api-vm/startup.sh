#!/bin/bash
# Startup script for VM instance
echo "Installing Weather API on VM..."

# Update system
apt-get update
apt-get install -y python3 python3-pip python3-venv

# Create app directory
mkdir -p /opt/weather-api
cd /opt/weather-api

# Copy application files
cp /tmp/main.py /opt/weather-api/

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install fastapi uvicorn httpx

# Create systemd service
cat > /etc/systemd/system/weather-api.service << EOF
[Unit]
Description=Weather API FastAPI application
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/weather-api
Environment=PATH=/opt/weather-api/venv/bin
ExecStart=/opt/weather-api/venv/bin/python main.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
systemctl daemon-reload
systemctl enable weather-api
systemctl start weather-api

echo "Weather API installed and running on port 8000"
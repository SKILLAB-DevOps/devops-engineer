#!/bin/bash

# Get server ID from metadata
SERVER_ID=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/server-id 2>/dev/null || echo "unknown")

# Install Apache
sudo apt update
sudo apt install -y apache2

# Start Apache
sudo systemctl start apache2
sudo systemctl enable apache2

# Create custom webpage showing which server is responding
sudo tee /var/www/html/index.html > /dev/null <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Load Balanced Server</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }
        .server-info { background: #f0f8ff; padding: 20px; border-radius: 10px; display: inline-block; }
        .server-id { font-size: 48px; color: #4285f4; font-weight: bold; }
    </style>
</head>
<body>
    <div class="server-info">
        <h1>Hello from Load Balanced Server!</h1>
        <div class="server-id">Server #$SERVER_ID</div>
        <p>Hostname: $(hostname)</p>
        <p>Time: $(date)</p>
        <p>Refresh the page to see load balancing in action!</p>
    </div>
</body>
</html>
EOF

echo "Web server $SERVER_ID is ready!"
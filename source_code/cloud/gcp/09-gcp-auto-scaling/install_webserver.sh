#!/bin/bash

# Install Apache and stress testing tool
sudo apt update
sudo apt install -y apache2 stress

# Start Apache
sudo systemctl start apache2
sudo systemctl enable apache2

# Create webpage with load testing button
sudo tee /var/www/html/index.html > /dev/null <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Auto Scaling Demo</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }
        .container { background: #f0f8ff; padding: 20px; border-radius: 10px; display: inline-block; }
        .button { background: #4285f4; color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer; margin: 10px; }
        .button:hover { background: #3367d6; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Auto Scaling Demo Server</h1>
        <p>Server: $(hostname)</p>
        <p>Time: $(date)</p>
        <p>This server is part of an auto-scaling group!</p>
        <p>When CPU usage goes above 60%, more servers will be created automatically.</p>
        <p>When CPU usage drops, extra servers will be removed.</p>
        
        <div>
            <h3>Test Auto Scaling</h3>
            <p>To trigger scaling, run this command on each server:</p>
            <code>stress --cpu 2 --timeout 300s</code>
            <p>(This will max out CPU for 5 minutes)</p>
        </div>
    </div>
</body>
</html>
EOF

echo "Auto scaling web server ready!"
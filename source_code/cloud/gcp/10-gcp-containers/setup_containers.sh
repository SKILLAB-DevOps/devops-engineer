#!/bin/bash

# Wait for Docker to be ready
sleep 30

# Create HTML content
mkdir -p /tmp/html
cat > /tmp/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Containerized App</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }
        .container { background: #f0f8ff; padding: 20px; border-radius: 10px; display: inline-block; }
        .button { background: #4285f4; color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer; margin: 10px; }
        .api-response { background: #f9f9f9; padding: 10px; border-radius: 5px; margin: 10px; font-family: monospace; }
    </style>
    <script>
        async function callAPI() {
            try {
                const response = await fetch('/api');
                const data = await response.json();
                document.getElementById('api-result').innerHTML = JSON.stringify(data, null, 2);
            } catch (error) {
                document.getElementById('api-result').innerHTML = 'Error: ' + error.message;
            }
        }
        
        // Auto-refresh API call every 5 seconds
        setInterval(callAPI, 5000);
        window.onload = callAPI;
    </script>
</head>
<body>
    <div class="container">
        <h1>🐳 Containerized Application</h1>
        <p>This page is served by an <strong>NGINX container</strong></p>
        <p>The API below is served by a <strong>Node.js container</strong></p>
        
        <h3>Live API Response:</h3>
        <div class="api-response" id="api-result">Loading...</div>
        
        <button class="button" onclick="callAPI()">Refresh API</button>
        
        <h3>Container Benefits:</h3>
        <ul style="text-align: left; display: inline-block;">
            <li>Consistent environment across dev/prod</li>
            <li>Easy to scale and deploy</li>
            <li>Isolated processes</li>
            <li>Version control for entire application stack</li>
        </ul>
    </div>

    <script>
        // Proxy API calls to port 8080
        async function callAPI() {
            try {
                const response = await fetch(window.location.protocol + '//' + window.location.hostname + ':8080');
                const data = await response.json();
                document.getElementById('api-result').innerHTML = JSON.stringify(data, null, 2);
            } catch (error) {
                document.getElementById('api-result').innerHTML = 'Error: ' + error.message;
            }
        }
    </script>
</body>
</html>
EOF

# Copy docker-compose.yml to working directory
cp /tmp/docker-compose.yml /home/chronos/

# Create the html directory and copy content
mkdir -p /home/chronos/html
cp /tmp/html/index.html /home/chronos/html/

# Change to the directory and start containers
cd /home/chronos
docker-compose up -d

# Show running containers
docker ps

echo "Containers started successfully!"
echo "Web app available on port 80"
echo "API available on port 8080"
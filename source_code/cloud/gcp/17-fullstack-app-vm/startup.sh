#!/bin/bash

echo "🚀 Installing Fullstack Application on VM..."

# Update system
apt-get update
apt-get install -y curl git

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Start and enable Docker
systemctl start docker
systemctl enable docker

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Create app directory
mkdir -p /opt/fullstack-app
cd /opt/fullstack-app

# Clone the repository
git clone https://github.com/SKILLAB-DevOps/fullstack.git .

# Update the frontend to use the VM's IP address for API calls
VM_IP=$(curl -s ifconfig.me)

# Create updated index.html with correct backend URL
cat > index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Fullstack User Management</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background-color: white;
            border-radius: 10px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            text-align: center;
            margin-bottom: 30px;
        }
        button {
            background-color: #007bff;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            margin: 5px;
            font-size: 16px;
        }
        button:hover {
            background-color: #0056b3;
        }
        .form-section {
            margin: 20px 0;
            padding: 20px;
            border: 1px solid #ddd;
            border-radius: 5px;
            background-color: #f9f9f9;
        }
        input[type="number"], input[type="text"] {
            padding: 8px;
            margin: 5px;
            border: 1px solid #ddd;
            border-radius: 3px;
        }
        #user-list {
            margin-top: 20px;
            padding: 20px;
            background-color: #f8f9fa;
            border-radius: 5px;
        }
        .user-item {
            padding: 10px;
            margin: 5px 0;
            background-color: white;
            border-radius: 3px;
            border-left: 4px solid #007bff;
        }
        .deployment-info {
            background-color: #e8f4fd;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
            border-left: 4px solid #007bff;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="deployment-info">
            <h3>🌐 Fullstack App - GCP VM Deployment</h3>
            <p><strong>Frontend:</strong> Nginx serving static HTML</p>
            <p><strong>Backend:</strong> FastAPI Python application</p>
            <p><strong>Database:</strong> PostgreSQL with sample data</p>
            <p><strong>Backend API:</strong> <a href="http://${VM_IP}:8000" target="_blank">http://${VM_IP}:8000</a></p>
        </div>
        
        <h1>👥 User Management System</h1>
        
        <div>
            <button onclick="listUsers()">📋 View All Users</button>
            <button onclick="testBackend()">🔗 Test Backend Connection</button>
        </div>
        
        <div class="form-section">
            <h3>➕ Add New User</h3>
            <input type="number" id="userId" placeholder="User ID" />
            <input type="text" id="userName" placeholder="User Name" />
            <button onclick="addUser()">Add User</button>
        </div>
        
        <div class="form-section">
            <h3>🗑️ Delete User</h3>
            <input type="number" id="deleteUserId" placeholder="User ID to Delete" />
            <button onclick="deleteUser()">Delete User</button>
        </div>
        
        <div id="user-list"></div>
    </div>

    <script>
        const API_BASE = 'http://${VM_IP}:8000';
        
        async function testBackend() {
            const userList = document.getElementById('user-list');
            try {
                const response = await fetch(API_BASE + '/');
                if (response.ok) {
                    const data = await response.json();
                    userList.innerHTML = '<div class="user-item" style="border-left-color: #28a745;"><strong>✅ Backend Connection Successful!</strong><br>Response: ' + JSON.stringify(data) + '</div>';
                } else {
                    throw new Error('Backend responded with status: ' + response.status);
                }
            } catch (error) {
                userList.innerHTML = '<div class="user-item" style="border-left-color: #dc3545;"><strong>❌ Backend Connection Failed!</strong><br>Error: ' + error.message + '</div>';
            }
        }
        
        async function listUsers() {
            const userList = document.getElementById('user-list');
            userList.innerHTML = '<div class="user-item">🔄 Loading users...</div>';
            
            try {
                const response = await fetch(API_BASE + '/users');
                if (!response.ok) {
                    throw new Error('HTTP ' + response.status);
                }
                const data = await response.json();
                
                if (data.users && data.users.length > 0) {
                    const usersList = data.users.map(user => 
                        '<div class="user-item"><strong>ID:</strong> ' + user[0] + ' | <strong>Name:</strong> ' + user[1] + '</div>'
                    ).join('');
                    userList.innerHTML = '<h3>👥 Users List:</h3>' + usersList;
                } else {
                    userList.innerHTML = '<div class="user-item">📭 No users found</div>';
                }
            } catch (error) {
                userList.innerHTML = '<div class="user-item" style="border-left-color: #dc3545;"><strong>❌ Error:</strong> ' + error.message + '</div>';
            }
        }
        
        async function addUser() {
            const userId = document.getElementById('userId').value;
            const userName = document.getElementById('userName').value;
            const userList = document.getElementById('user-list');
            
            if (!userId || !userName) {
                alert('Please enter both User ID and Name');
                return;
            }
            
            try {
                const response = await fetch(API_BASE + '/users?user_id=' + userId + '&name=' + encodeURIComponent(userName), {
                    method: 'POST'
                });
                
                if (response.ok) {
                    userList.innerHTML = '<div class="user-item" style="border-left-color: #28a745;"><strong>✅ User added successfully!</strong></div>';
                    document.getElementById('userId').value = '';
                    document.getElementById('userName').value = '';
                    // Refresh the user list
                    setTimeout(listUsers, 1000);
                } else {
                    const errorData = await response.json();
                    throw new Error(errorData.detail || 'Failed to add user');
                }
            } catch (error) {
                userList.innerHTML = '<div class="user-item" style="border-left-color: #dc3545;"><strong>❌ Error adding user:</strong> ' + error.message + '</div>';
            }
        }
        
        async function deleteUser() {
            const userId = document.getElementById('deleteUserId').value;
            const userList = document.getElementById('user-list');
            
            if (!userId) {
                alert('Please enter User ID to delete');
                return;
            }
            
            try {
                const response = await fetch(API_BASE + '/users/' + userId, {
                    method: 'DELETE'
                });
                
                if (response.ok) {
                    userList.innerHTML = '<div class="user-item" style="border-left-color: #28a745;"><strong>✅ User deleted successfully!</strong></div>';
                    document.getElementById('deleteUserId').value = '';
                    // Refresh the user list
                    setTimeout(listUsers, 1000);
                } else {
                    const errorData = await response.json();
                    throw new Error(errorData.detail || 'Failed to delete user');
                }
            } catch (error) {
                userList.innerHTML = '<div class="user-item" style="border-left-color: #dc3545;"><strong>❌ Error deleting user:</strong> ' + error.message + '</div>';
            }
        }
        
        // Load users when page loads
        document.addEventListener('DOMContentLoaded', function() {
            listUsers();
        });
    </script>
</body>
</html>
EOF

# Update docker-compose.yaml with environment variables for the backend
cat > docker-compose.yaml << EOF
services:
  db:
    build:
      context: .
      dockerfile: Dockerfile.db
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: fullstack
      POSTGRES_PASSWORD: fullstack
      POSTGRES_DB: fullstack
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U fullstack"]
      interval: 30s
      timeout: 10s
      retries: 3

  backend:
    build:
      context: .
      dockerfile: Dockerfile.backend
    ports:
      - "8000:8000"
    depends_on:
      db:
        condition: service_healthy
    environment:
      DB_NAME: fullstack
      DB_USER: fullstack
      DB_PASSWORD: fullstack
      DB_HOST: db
      DB_PORT: 5432
    restart: unless-stopped

  frontend:
    build:
      context: .
      dockerfile: Dockerfile.frontend
    ports:
      - "80:80"
    depends_on:
      - backend
    restart: unless-stopped
EOF

# Build and start the containers
docker-compose up -d

# Wait for containers to be ready
echo "⏳ Waiting for containers to start..."
sleep 30

# Check container status
docker-compose ps

# Set correct permissions
chown -R ubuntu:ubuntu /opt/fullstack-app

echo "✅ Fullstack Application deployed and running!"
echo "🌐 Frontend URL: http://${VM_IP}"
echo "🔧 Backend API: http://${VM_IP}:8000"
echo "🗄️ Database: ${VM_IP}:5432"
echo ""
echo "📋 Container Status:"
docker-compose ps
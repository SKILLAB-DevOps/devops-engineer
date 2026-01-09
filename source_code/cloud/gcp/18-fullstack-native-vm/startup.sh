#!/bin/bash

echo "🚀 Installing Native Fullstack Application on VM..."

# Update system
apt-get update
apt-get install -y python3 python3-pip python3-venv nginx postgresql postgresql-contrib git curl

# Get VM IP for configuration
VM_IP=$(curl -s ifconfig.me)

echo "📦 Setting up PostgreSQL Database..."
# Start and enable PostgreSQL
systemctl start postgresql
systemctl enable postgresql

# Configure PostgreSQL
sudo -u postgres psql << EOF
CREATE DATABASE fullstack;
CREATE USER fullstack WITH PASSWORD 'fullstack';
GRANT ALL PRIVILEGES ON DATABASE fullstack TO fullstack;
ALTER USER fullstack CREATEDB;
\q
EOF

# Create users table and insert sample data
sudo -u postgres psql -d fullstack << EOF
CREATE TABLE users (id INT PRIMARY KEY, name VARCHAR(100));
INSERT INTO users (id, name) VALUES 
    (1, 'Alice'),
    (2, 'Bob'),
    (3, 'Charlie'),
    (4, 'Diana'),
    (5, 'Eve');
EOF

echo "🐍 Setting up Python Backend..."
# Create backend directory
mkdir -p /opt/fullstack-backend
cd /opt/fullstack-backend

# Create FastAPI application
cat > main.py << 'EOF'
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
import psycopg2
import os
from contextlib import contextmanager

app = FastAPI(
    title="Fullstack User Management API",
    description="A simple user management API with PostgreSQL backend",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Database configuration
DB_CONFIG = {
    'dbname': 'fullstack',
    'user': 'fullstack',
    'password': 'fullstack',
    'host': 'localhost',
    'port': '5432'
}

@contextmanager
def get_db_connection():
    conn = None
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        yield conn
    except Exception as e:
        if conn:
            conn.rollback()
        raise e
    finally:
        if conn:
            conn.close()

@app.get("/")
def read_root():
    return {
        "message": "Fullstack User Management API",
        "version": "1.0.0",
        "deployment": "native-vm",
        "endpoints": {
            "users": "/users",
            "docs": "/docs",
            "health": "/health"
        }
    }

@app.get("/health")
def health_check():
    try:
        with get_db_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT 1")
            cursor.close()
        return {
            "status": "healthy",
            "database": "connected",
            "deployment": "native-vm"
        }
    except Exception as e:
        return {
            "status": "unhealthy",
            "database": "disconnected",
            "error": str(e)
        }

@app.get("/users")
def get_users():
    try:
        with get_db_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT id, name FROM users ORDER BY id")
            users = cursor.fetchall()
            cursor.close()
        return {"users": users}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")

@app.post("/users")
def create_user(user_id: int, name: str):
    try:
        with get_db_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("INSERT INTO users (id, name) VALUES (%s, %s)", (user_id, name))
            conn.commit()
            cursor.close()
        return {"id": user_id, "name": name, "message": "User created successfully"}
    except psycopg2.IntegrityError:
        raise HTTPException(status_code=400, detail="User with this ID already exists")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")

@app.delete("/users/{user_id}")
def delete_user(user_id: int):
    try:
        with get_db_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM users WHERE id = %s", (user_id,))
            if cursor.rowcount == 0:
                raise HTTPException(status_code=404, detail="User not found")
            conn.commit()
            cursor.close()
        return {"message": f"User {user_id} deleted successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
EOF

# Create virtual environment and install dependencies
python3 -m venv venv
source venv/bin/activate
pip install fastapi uvicorn psycopg2-binary

# Create systemd service for backend
cat > /etc/systemd/system/fullstack-backend.service << EOF
[Unit]
Description=Fullstack Backend FastAPI Application
After=network.target postgresql.service

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/opt/fullstack-backend
Environment=PATH=/opt/fullstack-backend/venv/bin
ExecStart=/opt/fullstack-backend/venv/bin/python main.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

echo "🌐 Setting up Nginx Frontend..."
# Create frontend directory
mkdir -p /var/www/fullstack

# Create enhanced HTML frontend
cat > /var/www/fullstack/index.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Native Fullstack User Management</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            max-width: 1000px;
            margin: 0 auto;
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }
        .header h1 {
            font-size: 2.5rem;
            margin-bottom: 10px;
        }
        .deployment-info {
            background: rgba(255,255,255,0.1);
            padding: 20px;
            border-radius: 10px;
            margin-top: 20px;
        }
        .deployment-info h3 {
            margin-bottom: 15px;
            font-size: 1.3rem;
        }
        .deployment-info p {
            margin-bottom: 8px;
            opacity: 0.9;
        }
        .content {
            padding: 40px;
        }
        .section {
            margin-bottom: 40px;
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.05);
        }
        .section h3 {
            color: #333;
            margin-bottom: 20px;
            font-size: 1.4rem;
            border-bottom: 2px solid #667eea;
            padding-bottom: 10px;
        }
        .buttons {
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
            margin-bottom: 20px;
        }
        button {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 25px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 600;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
        }
        button:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
        }
        button:active {
            transform: translateY(0);
        }
        .form-section {
            background: #f8f9fa;
            border: 1px solid #e9ecef;
        }
        .form-row {
            display: flex;
            gap: 15px;
            align-items: center;
            flex-wrap: wrap;
        }
        input[type="number"], input[type="text"] {
            padding: 12px 16px;
            border: 2px solid #e9ecef;
            border-radius: 10px;
            font-size: 16px;
            transition: border-color 0.3s ease;
            min-width: 200px;
        }
        input[type="number"]:focus, input[type="text"]:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        #user-list {
            margin-top: 30px;
            min-height: 100px;
        }
        .user-item {
            padding: 15px 20px;
            margin: 10px 0;
            background: white;
            border-radius: 10px;
            border-left: 4px solid #667eea;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            transition: transform 0.2s ease;
        }
        .user-item:hover {
            transform: translateX(5px);
        }
        .user-item.success {
            border-left-color: #28a745;
            background: #f8fff9;
        }
        .user-item.error {
            border-left-color: #dc3545;
            background: #fff8f8;
        }
        .user-item.info {
            border-left-color: #17a2b8;
            background: #f8fcff;
        }
        .loading {
            text-align: center;
            padding: 20px;
            color: #666;
        }
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 15px;
            text-align: center;
        }
        .stat-number {
            font-size: 2rem;
            font-weight: bold;
            margin-bottom: 5px;
        }
        .architecture {
            background: #e8f4fd;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
        }
        .architecture h4 {
            color: #0056b3;
            margin-bottom: 10px;
        }
        .tech-stack {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
        .tech-item {
            background: #667eea;
            color: white;
            padding: 5px 12px;
            border-radius: 15px;
            font-size: 14px;
        }
        @media (max-width: 768px) {
            .buttons {
                flex-direction: column;
            }
            .form-row {
                flex-direction: column;
                align-items: stretch;
            }
            input[type="number"], input[type="text"] {
                min-width: auto;
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>👥 Native Fullstack User Management</h1>
            <div class="deployment-info">
                <h3>🖥️ Native VM Deployment (No Docker)</h3>
                <p><strong>Frontend:</strong> Nginx serving static HTML/CSS/JS</p>
                <p><strong>Backend:</strong> FastAPI Python application (Direct install)</p>
                <p><strong>Database:</strong> PostgreSQL (System service)</p>
                <p><strong>Backend API:</strong> <a href="http://${VM_IP}:8000" target="_blank" style="color: #ffeb3b;">http://${VM_IP}:8000</a></p>
                <p><strong>API Docs:</strong> <a href="http://${VM_IP}:8000/docs" target="_blank" style="color: #ffeb3b;">http://${VM_IP}:8000/docs</a></p>
            </div>
        </div>
        
        <div class="content">
            <div class="architecture">
                <h4>🏗️ Architecture: Native Services</h4>
                <p>All components run directly on the VM as system services - no containerization overhead!</p>
                <div class="tech-stack">
                    <span class="tech-item">Ubuntu 22.04</span>
                    <span class="tech-item">Nginx</span>
                    <span class="tech-item">FastAPI</span>
                    <span class="tech-item">PostgreSQL 14</span>
                    <span class="tech-item">Systemd Services</span>
                </div>
            </div>
            
            <div class="stats" id="stats">
                <div class="stat-card">
                    <div class="stat-number" id="total-users">-</div>
                    <div>Total Users</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number" id="backend-status">-</div>
                    <div>Backend Status</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number" id="db-status">-</div>
                    <div>Database Status</div>
                </div>
            </div>
            
            <div class="section">
                <h3>🔍 View & Test</h3>
                <div class="buttons">
                    <button onclick="listUsers()">📋 View All Users</button>
                    <button onclick="testBackend()">🔗 Test Backend</button>
                    <button onclick="checkHealth()">❤️ Health Check</button>
                    <button onclick="refreshStats()">🔄 Refresh Stats</button>
                </div>
            </div>
            
            <div class="section form-section">
                <h3>➕ Add New User</h3>
                <div class="form-row">
                    <input type="number" id="userId" placeholder="User ID" />
                    <input type="text" id="userName" placeholder="User Name" />
                    <button onclick="addUser()">Add User</button>
                </div>
            </div>
            
            <div class="section form-section">
                <h3>🗑️ Delete User</h3>
                <div class="form-row">
                    <input type="number" id="deleteUserId" placeholder="User ID to Delete" />
                    <button onclick="deleteUser()">Delete User</button>
                </div>
            </div>
            
            <div id="user-list"></div>
        </div>
    </div>

    <script>
        const API_BASE = 'http://${VM_IP}:8000';
        
        async function makeRequest(url, options = {}) {
            try {
                const response = await fetch(url, options);
                return { success: response.ok, data: await response.json(), status: response.status };
            } catch (error) {
                return { success: false, error: error.message };
            }
        }
        
        function showMessage(message, type = 'info', duration = 5000) {
            const userList = document.getElementById('user-list');
            const messageDiv = document.createElement('div');
            messageDiv.className = \`user-item \${type}\`;
            messageDiv.innerHTML = message;
            userList.insertBefore(messageDiv, userList.firstChild);
            
            setTimeout(() => {
                if (messageDiv.parentNode) {
                    messageDiv.remove();
                }
            }, duration);
        }
        
        async function refreshStats() {
            const result = await makeRequest(API_BASE + '/users');
            if (result.success) {
                document.getElementById('total-users').textContent = result.data.users.length;
            }
            
            const healthResult = await makeRequest(API_BASE + '/health');
            if (healthResult.success) {
                document.getElementById('backend-status').textContent = '✅ UP';
                document.getElementById('db-status').textContent = healthResult.data.database === 'connected' ? '✅ UP' : '❌ DOWN';
            } else {
                document.getElementById('backend-status').textContent = '❌ DOWN';
                document.getElementById('db-status').textContent = '❌ DOWN';
            }
        }
        
        async function testBackend() {
            showMessage('🔄 Testing backend connection...', 'info');
            const result = await makeRequest(API_BASE + '/');
            
            if (result.success) {
                showMessage(\`✅ <strong>Backend Connection Successful!</strong><br>
                    Version: \${result.data.version}<br>
                    Deployment: \${result.data.deployment}<br>
                    Message: \${result.data.message}\`, 'success');
            } else {
                showMessage(\`❌ <strong>Backend Connection Failed!</strong><br>
                    Error: \${result.error || 'Unknown error'}\`, 'error');
            }
        }
        
        async function checkHealth() {
            showMessage('🔄 Checking system health...', 'info');
            const result = await makeRequest(API_BASE + '/health');
            
            if (result.success) {
                showMessage(\`❤️ <strong>System Health Check:</strong><br>
                    Status: \${result.data.status}<br>
                    Database: \${result.data.database}<br>
                    Deployment: \${result.data.deployment}\`, 'success');
            } else {
                showMessage(\`💔 <strong>Health Check Failed!</strong><br>
                    Error: \${result.error || 'Service unavailable'}\`, 'error');
            }
        }
        
        async function listUsers() {
            const userList = document.getElementById('user-list');
            userList.innerHTML = '<div class="loading">🔄 Loading users...</div>';
            
            const result = await makeRequest(API_BASE + '/users');
            
            if (result.success && result.data.users) {
                if (result.data.users.length > 0) {
                    const usersList = result.data.users.map((user, index) => 
                        \`<div class="user-item">
                            <strong>ID:</strong> \${user[0]} | 
                            <strong>Name:</strong> \${user[1]}
                            <span style="float: right; opacity: 0.6;">#\${index + 1}</span>
                        </div>\`
                    ).join('');
                    userList.innerHTML = \`<h3 style="margin-bottom: 20px;">👥 Users List (\${result.data.users.length} total):</h3>\` + usersList;
                } else {
                    userList.innerHTML = '<div class="user-item info">📭 No users found in the database</div>';
                }
                await refreshStats();
            } else {
                userList.innerHTML = \`<div class="user-item error">❌ <strong>Error loading users:</strong> \${result.error || 'Unknown error'}</div>\`;
            }
        }
        
        async function addUser() {
            const userId = document.getElementById('userId').value;
            const userName = document.getElementById('userName').value;
            
            if (!userId || !userName) {
                showMessage('⚠️ Please enter both User ID and Name', 'error');
                return;
            }
            
            showMessage(\`🔄 Adding user: \${userName} (ID: \${userId})...\`, 'info');
            
            const result = await makeRequest(\`\${API_BASE}/users?user_id=\${userId}&name=\${encodeURIComponent(userName)}\`, {
                method: 'POST'
            });
            
            if (result.success) {
                showMessage(\`✅ <strong>User added successfully!</strong><br>
                    ID: \${result.data.id} | Name: \${result.data.name}\`, 'success');
                document.getElementById('userId').value = '';
                document.getElementById('userName').value = '';
                setTimeout(listUsers, 1000);
            } else {
                const errorMsg = result.data?.detail || result.error || 'Unknown error';
                showMessage(\`❌ <strong>Failed to add user:</strong><br>\${errorMsg}\`, 'error');
            }
        }
        
        async function deleteUser() {
            const userId = document.getElementById('deleteUserId').value;
            
            if (!userId) {
                showMessage('⚠️ Please enter User ID to delete', 'error');
                return;
            }
            
            showMessage(\`🗑️ Deleting user ID: \${userId}...\`, 'info');
            
            const result = await makeRequest(\`\${API_BASE}/users/\${userId}\`, {
                method: 'DELETE'
            });
            
            if (result.success) {
                showMessage(\`✅ <strong>User deleted successfully!</strong><br>
                    User ID \${userId} has been removed\`, 'success');
                document.getElementById('deleteUserId').value = '';
                setTimeout(listUsers, 1000);
            } else {
                const errorMsg = result.data?.detail || result.error || 'Unknown error';
                showMessage(\`❌ <strong>Failed to delete user:</strong><br>\${errorMsg}\`, 'error');
            }
        }
        
        // Initialize page
        document.addEventListener('DOMContentLoaded', function() {
            listUsers();
            refreshStats();
            
            // Auto-refresh stats every 30 seconds
            setInterval(refreshStats, 30000);
        });
    </script>
</body>
</html>
EOF

# Configure Nginx
cat > /etc/nginx/sites-available/fullstack << EOF
server {
    listen 80;
    server_name _;
    
    root /var/www/fullstack;
    index index.html;
    
    location / {
        try_files \$uri \$uri/ =404;
    }
    
    # Optional: Add API proxy to avoid CORS issues
    location /api/ {
        proxy_pass http://localhost:8000/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Enable Nginx site
ln -sf /etc/nginx/sites-available/fullstack /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
nginx -t

echo "🔧 Setting up services..."
# Set correct permissions
chown -R ubuntu:ubuntu /opt/fullstack-backend
chown -R www-data:www-data /var/www/fullstack

# Enable and start services
systemctl daemon-reload
systemctl enable fullstack-backend
systemctl enable nginx
systemctl restart postgresql
systemctl start fullstack-backend
systemctl restart nginx

# Wait for services to start
sleep 10

# Check service status
echo "📊 Service Status:"
systemctl is-active postgresql && echo "✅ PostgreSQL: Running" || echo "❌ PostgreSQL: Failed"
systemctl is-active fullstack-backend && echo "✅ Backend: Running" || echo "❌ Backend: Failed"
systemctl is-active nginx && echo "✅ Nginx: Running" || echo "❌ Nginx: Failed"

echo "✅ Native Fullstack Application deployed successfully!"
echo "🌐 Frontend URL: http://${VM_IP}"
echo "🔧 Backend API: http://${VM_IP}:8000"
echo "📚 API Docs: http://${VM_IP}:8000/docs"
echo "🗄️ Database: localhost:5432"
echo ""
echo "🔍 Quick Test Commands:"
echo "curl http://${VM_IP}:8000/health"
echo "curl http://${VM_IP}:8000/users"
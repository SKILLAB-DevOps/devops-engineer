##########################
8.3 Container Fundamentals
##########################

.. image:: ../diagrams/docker_arch.png
  :alt: A diagram showing the complete container lifecycle from image to running container
  :width: 800 px

**Mastering the Container Lifecycle**

Now that you can run basic containers, it's time to understand how containers really work. This section covers essential container operations, networking concepts, data persistence, and debugging techniques you'll use daily in development and production environments.

Think of this as your "driver's license" for containers - you'll learn not just what to do, but why and when to do it.

===================
Learning Objectives
===================

By the end of this section, you will:

• **Master** container lifecycle management (create, start, stop, remove)
• **Configure** container networking and port mapping effectively
• **Manage** data persistence with volumes and bind mounts
• **Debug** containers using logs, exec, and inspection tools
• **Optimize** resource usage and container performance
• **Understand** when to use interactive vs. detached modes

**Prerequisites:** Basic container concepts and successful "hello world" container runs

=========================
Container Execution Modes
=========================

**Interactive vs. Detached: When to Use Each**

Understanding execution modes is crucial for effective container management:

**Interactive Mode (-it):**

- **When to use:** Development, debugging, one-time tasks, learning
- **Characteristics:** Keeps terminal attached, captures input/output
- **Best for:** Database administration, file editing, testing commands

**Detached Mode (-d):**

- **When to use:** Production services, long-running processes, web servers
- **Characteristics:** Runs in background, returns control immediately
- **Best for:** Web applications, databases, background workers

**Practical Examples:**

.. code-block:: bash

    # Interactive: Perfect for debugging and exploration
    docker run -it ubuntu:22.04 /bin/bash
    # You get a shell inside the container
    
    # Interactive with cleanup: One-time tasks
    docker run --rm -it python:3.11 python
    # Python REPL, container removed when you exit
    
    # Detached: Long-running services
    docker run -d --name web-server nginx:alpine
    # Returns immediately, container runs in background
    
    # Detached with port mapping: Production-ready web service
    docker run -d -p 8080:80 --name my-web nginx:alpine

**Combining Modes:**

.. code-block:: bash

    # Start detached, then connect interactively
    docker run -d --name debug-container ubuntu:22.04 sleep 3600
    docker exec -it debug-container /bin/bash
    
    # View output from detached container
    docker logs -f debug-container

============================
Container Networking Mastery
============================

**Port Mapping Deep Dive**

Container networking can be confusing at first, but understanding the concepts makes everything click:

**Basic Port Mapping:**

.. code-block:: bash

    # Syntax: -p HOST_PORT:CONTAINER_PORT
    docker run -d -p 8080:80 nginx:alpine
    # Maps host port 8080 to container port 80
    
    # Multiple port mappings
    docker run -d \
      -p 8080:80 \
      -p 8443:443 \
      nginx:alpine
    
    # Bind to specific interface
    docker run -d -p 127.0.0.1:8080:80 nginx:alpine
    # Only accessible from localhost
    
    # Random port assignment
    docker run -d -P nginx:alpine
    # Docker assigns random available ports

**Network Modes:**

.. code-block:: bash

    # Default bridge network
    docker run -d --name web1 nginx:alpine
    
    # Host networking (container uses host's network stack)
    docker run -d --network host nginx:alpine
    # Container port 80 = host port 80 directly
    
    # No networking
    docker run -d --network none alpine sleep 3600
    # Complete network isolation
    
    # Custom networks (recommended for multi-container apps)
    docker network create my-app-network
    docker run -d --network my-app-network --name web nginx:alpine
    docker run -d --network my-app-network --name db postgres:15

**Service Discovery:**

.. code-block:: bash

    # Create custom network
    docker network create app-tier
    
    # Start database
    docker run -d \
      --network app-tier \
      --name postgres-db \
      -e POSTGRES_PASSWORD=mypassword \
      postgres:15
    
    # Start web app (can connect to 'postgres-db' by name)
    docker run -d \
      --network app-tier \
      --name web-app \
      -p 8080:8080 \
      -e DATABASE_URL=postgresql://postgres:mypassword@postgres-db:5432/postgres \
      my-web-app:latest

===========================
Data Persistence Strategies
===========================

**Understanding Container Storage**

Containers are ephemeral by design, but applications need persistent data. Here's how to handle it:

**Volume Types Comparison:**

.. list-table::
   :header-rows: 1
   :widths: 25 25 25 25

   * - Type
     - Use Case
     - Performance
     - Portability
   * - **Volumes**
     - Production data
     - Excellent
     - High (Docker-managed)
   * - **Bind Mounts**
     - Development
     - Native
     - Medium (host-dependent)
   * - **tmpfs**
     - Temporary data
     - Excellent
     - Low (memory-only)

**Docker Volumes (Recommended for Production):**

.. code-block:: bash

    # Create named volume
    docker volume create postgres-data
    
    # Use volume in container
    docker run -d \
      --name postgres-db \
      -v postgres-data:/var/lib/postgresql/data \
      -e POSTGRES_PASSWORD=securepassword \
      postgres:15
    
    # Inspect volume
    docker volume inspect postgres-data
    
    # List all volumes
    docker volume ls
    
    # Backup volume data
    docker run --rm \
      -v postgres-data:/source:ro \
      -v $(pwd):/backup \
      ubuntu tar czf /backup/postgres-backup.tar.gz -C /source .

**Bind Mounts (Great for Development):**

.. code-block:: bash

    # Mount current directory for live code editing
    docker run -d \
      --name dev-server \
      -v $(pwd):/app \
      -w /app \
      -p 3000:3000 \
      node:18-alpine \
      npm run dev
    
    # Mount config files
    docker run -d \
      --name web-server \
      -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro \
      -p 8080:80 \
      nginx:alpine

**tmpfs Mounts (Memory-based, Fast):**

.. code-block:: bash

    # Mount memory filesystem for temporary data
    docker run -d \
      --name fast-cache \
      --tmpfs /cache:rw,noexec,nosuid,size=1g \
      redis:alpine

==================================
Database Deployment Best Practices
==================================

**Production-Ready Database Container**

Let's deploy a PostgreSQL database following best practices:

.. code-block:: bash

    # Create dedicated network for database
    docker network create db-network
    
    # Create volume for persistent data
    docker volume create postgres-data
    
    # Deploy PostgreSQL with proper configuration
    docker run -d \
      --name production-postgres \
      --network db-network \
      -p 5432:5432 \
      -v postgres-data:/var/lib/postgresql/data \
      -v $(pwd)/init-scripts:/docker-entrypoint-initdb.d:ro \
      -e POSTGRES_DB=appdb \
      -e POSTGRES_USER=appuser \
      -e POSTGRES_PASSWORD=securepassword \
      -e POSTGRES_INITDB_ARGS="--auth-host=scram-sha-256" \
      --restart unless-stopped \
      postgres:15-alpine

**Database Initialization Script:**

.. code-block:: sql

    -- init-scripts/01-create-tables.sql
    CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        username VARCHAR(50) UNIQUE NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    CREATE TABLE IF NOT EXISTS posts (
        id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(id),
        title VARCHAR(200) NOT NULL,
        content TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    -- Create indexes for performance
    CREATE INDEX idx_users_username ON users(username);
    CREATE INDEX idx_posts_user_id ON posts(user_id);
    CREATE INDEX idx_posts_created_at ON posts(created_at);

**Database Connection Testing:**

.. code-block:: bash

    # Test connection using psql
    docker exec -it production-postgres psql -U appuser -d appdb
    
    # Run SQL commands from host
    docker exec production-postgres psql -U appuser -d appdb -c "SELECT version();"
    
    # Import data from SQL file
    docker exec -i production-postgres psql -U appuser -d appdb < data.sql

=============================
Container Management Commands
=============================

**Essential Container Operations**

**Lifecycle Management:**

.. code-block:: bash

    # Create container without starting
    docker create --name my-app nginx:alpine
    
    # Start a stopped container
    docker start my-app
    
    # Stop container gracefully (SIGTERM, then SIGKILL after timeout)
    docker stop my-app
    
    # Force stop container immediately (SIGKILL)
    docker kill my-app
    
    # Restart container
    docker restart my-app
    
    # Pause/unpause container processes
    docker pause my-app
    docker unpause my-app
    
    # Remove container (must be stopped first)
    docker rm my-app
    
    # Remove running container forcefully
    docker rm -f my-app

**Container Inspection and Debugging:**

.. code-block:: bash

    # View detailed container information
    docker inspect my-app
    
    # Get specific information using format
    docker inspect --format='{{.State.Status}}' my-app
    docker inspect --format='{{.NetworkSettings.IPAddress}}' my-app
    
    # View container processes
    docker top my-app
    
    # Monitor resource usage
    docker stats my-app
    docker stats --no-stream  # One-time snapshot
    
    # View port mappings
    docker port my-app

**Working with Container Filesystems:**

.. code-block:: bash

    # Copy files between host and container
    docker cp local-file.txt my-app:/app/
    docker cp my-app:/app/logs/ ./logs/
    
    # View filesystem changes
    docker diff my-app
    
    # Export container filesystem as tar
    docker export my-app > my-app-backup.tar

======================
Logging and Monitoring
======================

**Container Log Management**

.. code-block:: bash

    # View container logs
    docker logs my-app
    
    # Follow logs in real-time
    docker logs -f my-app
    
    # Show last 100 lines
    docker logs --tail 100 my-app
    
    # Show logs since specific time
    docker logs --since "2024-01-01T00:00:00" my-app
    
    # Show logs with timestamps
    docker logs -t my-app
    
    # Configure log rotation
    docker run -d \
      --log-driver json-file \
      --log-opt max-size=10m \
      --log-opt max-file=3 \
      nginx:alpine

**Resource Monitoring:**

.. code-block:: bash

    # Real-time resource usage
    docker stats
    
    # Historical resource usage (requires monitoring setup)
    # Use tools like cAdvisor, Prometheus, Grafana for production
    
    # Check disk usage
    docker system df
    docker system df -v  # Verbose output

=====================
Development Workflows
=====================

**Hot Reloading Development Setup**

.. code-block:: bash

    # Python development with hot reloading
    docker run -d \
      --name python-dev \
      -v $(pwd):/app \
      -w /app \
      -p 5000:5000 \
      -e FLASK_ENV=development \
      -e FLASK_DEBUG=1 \
      python:3.11-slim \
      bash -c "pip install flask && flask run --host=0.0.0.0"
    
    # Node.js development with nodemon
    docker run -d \
      --name node-dev \
      -v $(pwd):/app \
      -w /app \
      -p 3000:3000 \
      node:18-alpine \
      sh -c "npm install -g nodemon && nodemon app.js"

**Database Development Workflow:**

.. code-block:: bash

    # Start development database
    docker run -d \
      --name dev-postgres \
      -p 5433:5432 \
      -v dev-postgres-data:/var/lib/postgresql/data \
      -e POSTGRES_DB=dev_app \
      -e POSTGRES_USER=dev_user \
      -e POSTGRES_PASSWORD=dev_pass \
      postgres:15-alpine
    
    # Run database migrations
    docker exec dev-postgres psql -U dev_user -d dev_app -f /migrations/001_initial.sql
    
    # Backup development data
    docker exec dev-postgres pg_dump -U dev_user dev_app > dev_backup.sql
    
    # Reset development database
    docker exec dev-postgres psql -U dev_user -c "DROP DATABASE dev_app; CREATE DATABASE dev_app;"

=====================
Troubleshooting Guide
=====================

**Common Issues and Solutions**

**Container Won't Start:**

.. code-block:: bash

    # Check container status and exit code
    docker ps -a
    
    # View error logs
    docker logs container-name
    
    # Run with interactive mode to debug
    docker run -it --entrypoint /bin/sh image-name
    
    # Check if port is already in use
    netstat -tulpn | grep :8080  # Linux
    lsof -i :8080               # macOS

**Performance Issues:**

.. code-block:: bash

    # Check resource constraints
    docker stats
    
    # Inspect container configuration
    docker inspect container-name | jq '.[].HostConfig.Resources'
    
    # Check host system resources
    free -h        # Memory usage
    df -h          # Disk usage
    top            # CPU usage

**Network Connectivity Problems:**

.. code-block:: bash

    # Test container networking
    docker exec container-name ping google.com
    
    # Check DNS resolution
    docker exec container-name nslookup example.com
    
    # Inspect network configuration
    docker network ls
    docker network inspect bridge
    
    # Test port connectivity
    docker exec container-name nc -zv hostname port

**Permission Issues:**

.. code-block:: bash

    # Check file ownership in container
    docker exec container-name ls -la /app
    
    # Fix ownership for bind mounts
    sudo chown -R $(id -u):$(id -g) ./app-directory
    
    # Run container with specific user
    docker run --user $(id -u):$(id -g) image-name

=========================
Production Considerations
=========================

**Resource Limits and Constraints**

.. code-block:: bash

    # Set memory limit
    docker run -m 512m nginx:alpine
    
    # Set CPU limit
    docker run --cpus="1.5" nginx:alpine
    
    # Set both memory and CPU limits
    docker run -m 512m --cpus="1.0" nginx:alpine
    
    # Limit other resources
    docker run \
      --memory=512m \
      --cpus="1.0" \
      --pids-limit=100 \
      --ulimit nofile=1024:2048 \
      nginx:alpine

**Health Checks in Production:**

.. code-block:: bash

    # Run container with health check
    docker run -d \
      --name healthy-app \
      --health-cmd="curl -f http://localhost:8080/health || exit 1" \
      --health-interval=30s \
      --health-timeout=10s \
      --health-retries=3 \
      --health-start-period=60s \
      my-web-app:latest
    
    # Check health status
    docker ps  # Shows health status
    docker inspect healthy-app | jq '.[].State.Health'

**Restart Policies:**

.. code-block:: bash

    # Restart policies for production
    docker run -d --restart=unless-stopped nginx:alpine  # Recommended
    docker run -d --restart=always nginx:alpine          # Always restart
    docker run -d --restart=on-failure:3 nginx:alpine    # Restart on failure, max 3 times
    docker run -d --restart=no nginx:alpine              # Never restart (default)

==================
Practical Examples
==================

**Example 1: Complete Web Application Stack**

.. code-block:: bash

    # Create network
    docker network create webapp-network
    
    # Start database
    docker run -d \
      --name webapp-db \
      --network webapp-network \
      -v webapp-db-data:/var/lib/postgresql/data \
      -e POSTGRES_DB=webapp \
      -e POSTGRES_USER=webapp \
      -e POSTGRES_PASSWORD=securepassword \
      postgres:15-alpine
    
    # Start Redis cache
    docker run -d \
      --name webapp-cache \
      --network webapp-network \
      redis:7-alpine
    
    # Start web application
    docker run -d \
      --name webapp-api \
      --network webapp-network \
      -p 8080:8080 \
      -e DATABASE_URL=postgresql://webapp:securepassword@webapp-db:5432/webapp \
      -e REDIS_URL=redis://webapp-cache:6379 \
      my-webapp:latest
    
    # Start reverse proxy
    docker run -d \
      --name webapp-proxy \
      --network webapp-network \
      -p 80:80 \
      -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro \
      nginx:alpine

**Example 2: Development Environment**

.. code-block:: bash

    # Development database with sample data
    docker run -d \
      --name dev-db \
      -p 5432:5432 \
      -v $(pwd)/dev-data:/docker-entrypoint-initdb.d:ro \
      -e POSTGRES_DB=myapp_dev \
      -e POSTGRES_USER=developer \
      -e POSTGRES_PASSWORD=devpass \
      postgres:15-alpine
    
    # Development app with hot reloading
    docker run -d \
      --name dev-app \
      -p 3000:3000 \
      -v $(pwd)/src:/app/src:ro \
      -v $(pwd)/public:/app/public:ro \
      -e NODE_ENV=development \
      node:18-alpine \
      sh -c "cd /app && npm run dev"

============
What's Next?
============

You now have solid fundamentals for working with containers in any environment. In the next section, we'll learn how to create your own custom container images using Dockerfiles, giving you complete control over your application environments.

**Key takeaways:**

- Interactive mode for development and debugging, detached for production
- Port mapping enables network access to containerized services
- Volumes provide persistent data storage across container lifecycles
- Networks enable secure communication between containers
- Proper resource limits prevent containers from impacting system performance
- Health checks and restart policies ensure application reliability

.. note::

    **Practice Makes Perfect:** The commands and concepts in this section form the foundation of daily container operations. Practice them until they become second nature.

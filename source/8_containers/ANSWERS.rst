#######
Answers
#######

===============
Quick Questions
===============

**1. What is the main difference between a container image and a container?**

An image is a static template. A container is a running instance of that image.

**2. Why do containers start faster than virtual machines?**

Containers share the host OS kernel and only start the application process. VMs must boot an entire operating system.

**3. What happens to data inside a container when it stops?**

By default, all data is lost. Use volumes to persist data between container restarts.

**4. How do you pass environment variables to a Python container?**

Use `-e` flag: `docker run -e MY_VAR=value my-app` or environment section in docker-compose.yml.

**5. What is the purpose of a Dockerfile?**

A text file with instructions to build a container image automatically.

**6. Why should you avoid running containers as root?**

Security risk - if container is compromised, attacker has root access to host system.

**7. What is the difference between COPY and ADD in a Dockerfile?**

COPY just copies files. ADD can also extract archives and download URLs (use COPY for simple file copying).

**8. How do you persist data from a container?**

Use volumes (`docker run -v`) or bind mounts to store data outside the container filesystem.

**9. What is Docker Compose used for?**

To define and run multi-container applications using a YAML configuration file.

**10. How do you limit memory usage for a container?**

Use `--memory` flag: `docker run --memory=512m my-app` or resources section in docker-compose.yml.

==============
Task Solutions
==============

**Task 1: Create a Python "Hello World" container**

.. code-block:: dockerfile

    FROM python:3.12-slim
    RUN useradd -m appuser
    USER appuser
    WORKDIR /app
    ECHO 'print("Hello from Container!")' > hello.py
    CMD ["python", "hello.py"]

**Task 2: Pass environment variables to a Python script**

.. code-block:: python

    # greeting.py
    import os
    name = os.environ.get('NAME', 'World')
    print(f"Hello, {name}!")

.. code-block:: bash

    docker run -e NAME="DevOps" my-app

**Task 3: Mount a volume to read host files**

.. code-block:: bash

    # Create test file
    echo "test data" > data.txt
    
    # Run with volume mount
    docker run -v $(pwd):/data my-app

**Task 4: Build a simple Python web API container**

.. code-block:: python

    # app.py
    from flask import Flask, jsonify
    app = Flask(__name__)
    
    @app.route('/')
    def hello():
        return jsonify({"message": "Hello API"})
    
    app.run(host='0.0.0.0', port=5000)

.. code-block:: dockerfile

    FROM python:3.12-slim
    RUN pip install flask
    COPY app.py .
    EXPOSE 5000
    CMD ["python", "app.py"]

**Task 5: Create a multi-stage build**

.. code-block:: dockerfile

    # Build stage
    FROM python:3.12 as builder
    COPY requirements.txt .
    RUN pip install --user -r requirements.txt
    
    # Runtime stage
    FROM python:3.12-slim
    COPY --from=builder /root/.local /root/.local
    COPY app.py .
    CMD ["python", "app.py"]

**Task 6: Build a Python data processing container**

.. code-block:: python

    # processor.py
    import pandas as pd
    import sys
    
    data = pd.read_csv('/input/data.csv')
    result = data.groupby('category').sum()
    result.to_csv('/output/summary.csv')

.. code-block:: bash

    docker run -v $(pwd)/data:/input -v $(pwd)/output:/output processor

**Task 7: Create a container that installs Python packages**

.. code-block:: dockerfile

    FROM python:3.12-slim
    COPY requirements.txt .
    RUN pip install --no-cache-dir -r requirements.txt
    COPY . .
    CMD ["python", "main.py"]

**Task 8: Write a health check for your container**

.. code-block:: dockerfile

    HEALTHCHECK --interval=30s --timeout=3s \
      CMD curl -f http://localhost:5000/health || exit 1

**Task 9: Create a docker-compose.yml for multi-container app**

.. code-block:: yaml

    version: '3.8'
    services:
      web:
        build: .
        ports:
          - "8080:5000"
        depends_on:
          - redis
      redis:
        image: redis:alpine

**Task 10: Set resource limits on a container**

.. code-block:: bash

    docker run --memory=512m --cpus=0.5 my-app

.. code-block:: yaml

    # docker-compose.yml
    services:
      app:
        image: my-app
        deploy:
          resources:
            limits:
              memory: 512M
              cpus: '0.5'

=================
Discussion Topics
=================

**1. Container security and best practices**

Consider the principle of least privilege, vulnerability scanning, secrets management, and runtime security monitoring. How would you implement a security-first container strategy?

**2. Container orchestration trade-offs**

Compare Docker Swarm, Kubernetes, and cloud-native solutions. When would you choose each? What are the operational complexity vs. feature trade-offs?

**3. Microservices containerization strategy**

How do you decide service boundaries? What patterns help with service discovery, configuration management, and inter-service communication in a containerized environment?

**4. Container monitoring and observability**

Design a comprehensive monitoring strategy covering logs, metrics, traces, and health checks. How do you handle distributed debugging across multiple containers?

**5. Production container deployment patterns**

Evaluate blue-green deployments, rolling updates, canary releases, and feature flags in containerized environments. What deployment strategy fits different application types and risk tolerances?

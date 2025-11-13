######################
GCP Hands-On Exercises
######################

.. note::

   Complete these exercises to gain practical experience with Google Cloud Platform. Each exercise builds upon previous concepts and simulates real-world scenarios.

=======================
Exercise 1: Hello World
=======================

**Objective:** Deploy your first application on GCP using both Compute Engine (VM) and Cloud Storage (object storage)

++++++++++++++++++++++
Part A: Compute Engine
++++++++++++++++++++++

**Tasks:**

1. **Create a GCP Account and Project**
   
   .. code-block:: bash
   
      # Set up your project
      gcloud config set project YOUR_PROJECT_ID
      gcloud config set compute/zone us-central1-a

2. **Deploy a Web Server on Compute Engine**
   
   Create a VM instance and install Apache:
   
   .. code-block:: bash
   
      # Create VM
      gcloud compute instances create my-web-server \
          --machine-type=e2-micro \
          --tags=http-server \
          --image-family=ubuntu-2204-lts \
          --image-project=ubuntu-os-cloud
      
      # Create firewall rule
      gcloud compute firewall-rules create allow-http \
          --allow tcp:80 \
          --target-tags http-server
   
   **TODO:**
   
   □ SSH into your instance
   
   □ Install and configure Apache/Nginx
   
   □ Create a custom HTML page with your name and the current date
   
   □ Add a visitor counter using a simple script
   
   □ Access your website and take a screenshot

3. **Customize Your Deployment**
   
   **TODO:**
   
   □ Add CSS styling to your webpage
   
   □ Create multiple pages (index.html, about.html, contact.html)
   
   □ Implement a simple form that logs submissions
   
   □ Set up basic monitoring and create an alert

**Expected Output:**

   - A running VM with a custom website
   - Screenshot of your website
   - Documentation of steps taken

**Bonus Challenges:**

□ Set up a static IP address

□ Configure a custom domain name

□ Implement HTTPS with Let's Encrypt

□ Create a startup script for automatic configuration

++++++++++++++++++++++++++++++++++++
Part B: Cloud Storage Static Website
++++++++++++++++++++++++++++++++++++

**Tasks:**

1. **Create a Storage Bucket**
   
   .. code-block:: bash
   
      # Create bucket
      BUCKET_NAME="my-website-$(whoami)-$(date +%s)"
      gsutil mb gs://$BUCKET_NAME
      
      # Configure for website hosting
      gsutil web set -m index.html -e 404.html gs://$BUCKET_NAME

2. **Deploy a Static Website**
   
   **TODO:**
   
   □ Create an HTML/CSS/JS website locally
   
   □ Include multiple pages and images
   
   □ Upload to your bucket
   
   □ Make the bucket publicly accessible
   
   □ Test your website from different devices

3. **Implement Advanced Features**
   
   **TODO:**
   
   □ Add a contact form using Google Forms integration
   
   □ Implement Google Analytics
   
   □ Create a sitemap.xml
   
   □ Optimize images for web performance

**Expected Output:**

   - A functional static website hosted on GCS
   - URL to your website
   - Performance report showing page load time

**Questions to Answer:**

1. What are the cost differences between Compute Engine and Cloud Storage hosting?

2. When would you choose VM hosting over static hosting?

3. How would you implement continuous deployment for your static site?

==================================
Exercise 2: Serverless Application
==================================

**Objective:** Build a serverless API using Cloud Functions and Cloud Run

+++++++++++++++++++++++
Part A: Cloud Functions
+++++++++++++++++++++++

**Scenario:** Create a RESTful API for a simple task management system

**Tasks:**

1. **Create HTTP Cloud Functions**
   
   Implement these endpoints:
   
   .. code-block:: python
   
      # functions/main.py
      import functions_framework
      import json
      from google.cloud import firestore
      
      db = firestore.Client()
      
      @functions_framework.http
      def create_task(request):
          """TODO: Implement task creation"""
          pass
      
      @functions_framework.http
      def list_tasks(request):
          """TODO: Implement task listing"""
          pass
      
      @functions_framework.http
      def update_task(request):
          """TODO: Implement task update"""
          pass
      
      @functions_framework.http
      def delete_task(request):
          """TODO: Implement task deletion"""
          pass

2. **Implement CRUD Operations**
   
   **TODO:**
   
   □ Create database schema in Firestore
   
   □ Implement CREATE - Add new tasks
   
   □ Implement READ - List all tasks / Get task by ID
   
   □ Implement UPDATE - Modify task details
   
   □ Implement DELETE - Remove tasks
   
   □ Add input validation and error handling
   
   □ Implement authentication (API key or Firebase Auth)

3. **Deploy and Test**
   
   .. code-block:: bash
   
      # Deploy functions
      gcloud functions deploy create-task \
          --runtime python311 \
          --trigger-http \
          --allow-unauthenticated \
          --entry-point create_task
   
   **TODO:**
   
   □ Deploy all four functions
   
   □ Test each endpoint with curl or Postman
   
   □ Implement rate limiting
   
   □ Set up monitoring and logging
   
   □ Create API documentation

**Expected Output:**
   - Four working Cloud Functions
   - API documentation
   - Test results showing all CRUD operations

**Bonus Challenges:**

□ Add user authentication

□ Implement task sharing between users

□ Add file attachments using Cloud Storage

□ Create an email notification system

+++++++++++++++++++++++++++++
Part B: Cloud Run Application
+++++++++++++++++++++++++++++

**Scenario:** Convert your Cloud Functions API into a containerized Cloud Run service

**Tasks:**

1. **Create a Flask/FastAPI Application**
   
   .. code-block:: python
   
      # app.py
      from flask import Flask, request, jsonify
      from google.cloud import firestore
      
      app = Flask(__name__)
      db = firestore.Client()
      
      @app.route('/tasks', methods=['GET', 'POST'])
      def tasks():
          """TODO: Implement task management"""
          pass
      
      @app.route('/tasks/<task_id>', methods=['GET', 'PUT', 'DELETE'])
      def task_detail(task_id):
          """TODO: Implement task operations"""
          pass
      
      if __name__ == '__main__':
          app.run(host='0.0.0.0', port=8080)

2. **Dockerize Your Application**
   
   **TODO:**
   
   □ Create a Dockerfile
   
   □ Build the container image
   
   □ Test locally using Docker
   
   □ Push to Google Container Registry
   
   □ Deploy to Cloud Run

3. **Implement Advanced Features**
   
   **TODO:**
   
   □ Add WebSocket support for real-time updates
   
   □ Implement caching with Cloud Memorystore
   
   □ Set up CI/CD with Cloud Build
   
   □ Configure auto-scaling policies
   
   □ Implement health checks

**Expected Output:**

   - Containerized application running on Cloud Run
   - Load testing results
   - CI/CD pipeline documentation

===================================
Exercise 3: Data Analytics Pipeline
===================================

**Objective:** Build a data processing pipeline using BigQuery, Dataflow, and Pub/Sub

**Scenario:** Analyze website access logs to generate insights

++++++++++++++++++++++
Part A: Data Ingestion
++++++++++++++++++++++

**Tasks:**

1. **Set Up Data Collection**
   
   .. code-block:: python
   
      # log_generator.py
      """Generate simulated web access logs"""
      import random
      import json
      from datetime import datetime
      from google.cloud import pubsub_v1
      
      # TODO: Implement log generation
      # Generate logs with:
      # - timestamp
      # - user_id
      # - page_url
      # - response_time
      # - status_code
      # - user_agent
      # - ip_address

2. **Stream Data to Pub/Sub**
   
   **TODO:**
   
   □ Create a Pub/Sub topic
   
   □ Write a Python script to publish logs
   
   □ Simulate 1000+ log entries
   
   □ Implement error handling and retries

+++++++++++++++++++++++
Part B: Data Processing
+++++++++++++++++++++++

**Tasks:**

1. **Create Dataflow Pipeline**
   
   .. code-block:: python
   
      # dataflow_pipeline.py
      import apache_beam as beam
      from apache_beam.options.pipeline_options import PipelineOptions
      
      def process_log(element):
          """TODO: Implement log processing logic"""
          # Parse JSON
          # Extract fields
          # Calculate metrics
          # Enrich data
          pass
      
      def run():
          options = PipelineOptions()
          
          with beam.Pipeline(options=options) as pipeline:
              # TODO: Implement pipeline
              (pipeline
               | 'Read from Pub/Sub' >> beam.io.ReadFromPubSub(topic=TOPIC)
               | 'Process' >> beam.Map(process_log)
               | 'Write to BigQuery' >> beam.io.WriteToBigQuery(table=TABLE))

2. **Process and Transform Data**
   
   **TODO:**
   
   □ Parse and validate log entries
   
   □ Calculate response time statistics
   
   □ Identify top pages and users
   
   □ Detect anomalies (high error rates, slow responses)
   
   □ Aggregate data by hour/day

+++++++++++++++++++++
Part C: Data Analysis
+++++++++++++++++++++

**Tasks:**

1. **Create BigQuery Queries**
   
   **TODO - Write SQL queries to answer:**
   
   □ What are the top 10 most visited pages?
   
   .. code-block:: sql
   
      -- Your query here
      SELECT 
          page_url,
          COUNT(*) as visits
      FROM `project.dataset.access_logs`
      WHERE DATE(timestamp) = CURRENT_DATE()
      GROUP BY page_url
      ORDER BY visits DESC
      LIMIT 10;
   
   □ What is the average response time by hour?
   
   □ Which users have the highest activity?
   
   □ What percentage of requests result in errors?
   
   □ What are the peak traffic hours?

2. **Create Dashboard**
   
   **TODO:**
   
   □ Use Looker Studio (Data Studio) to create visualizations
   
   □ Create charts showing:
      - Traffic over time
      - Response time distribution
      - Error rate trends
      - Top pages
      - Geographic distribution (if IP geolocation added)
   
   □ Set up scheduled reports
   
   □ Share dashboard with stakeholders

**Expected Output:**

   - Working data pipeline
   - BigQuery dataset with processed data
   - Interactive dashboard with 5+ visualizations
   - Report documenting insights discovered

**Bonus Challenges:**

□ Implement real-time alerting for anomalies

□ Add machine learning predictions for traffic forecasting

□ Create a cost analysis of the pipeline

□ Implement data archival strategy

=======================================
Exercise 4: Machine Learning Deployment
=======================================

**Objective:** Train and deploy a machine learning model using Vertex AI

**Scenario:** Build an image classification service

++++++++++++++++++++++
Part A: Model Training
++++++++++++++++++++++

**Tasks:**

1. **Prepare Dataset**
   
   **TODO:**
   
   □ Choose a dataset (e.g., CIFAR-10, Fashion MNIST, or custom)
   
   □ Upload to Cloud Storage
   
   □ Create training/validation/test splits
   
   □ Implement data augmentation

2. **Train Model with Vertex AI**
   
   .. code-block:: python
   
      # training/train.py
      from google.cloud import aiplatform
      import tensorflow as tf
      
      def train_model():
          """TODO: Implement model training"""
          # Load data
          # Define model architecture
          # Compile model
          # Train
          # Evaluate
          # Save model
          pass
      
      if __name__ == '__main__':
          train_model()
   
   **TODO:**
   
   □ Create custom training job
   
   □ Experiment with hyperparameters
   
   □ Track experiments using Vertex AI Experiments
   
   □ Achieve > 80% accuracy

++++++++++++++++++++++++
Part B: Model Deployment
++++++++++++++++++++++++

**Tasks:**

1. **Deploy Model to Endpoint**
   
   .. code-block:: python
   
      # Deploy model
      from google.cloud import aiplatform
      
      # TODO: Implement deployment
      model = aiplatform.Model.upload(
          display_name="image-classifier",
          artifact_uri=MODEL_URI,
          serving_container_image_uri=SERVING_IMAGE
      )
      
      endpoint = model.deploy(
          machine_type="n1-standard-4",
          min_replica_count=1,
          max_replica_count=5
      )

2. **Create Prediction Service**
   
   **TODO:**
   
   □ Build an API wrapper around the model
   
   □ Implement image preprocessing
   
   □ Add request validation
   
   □ Implement batch prediction support
   
   □ Create web interface for testing

**Expected Output:**
   - Trained model with documented performance metrics
   - Deployed endpoint with API documentation
   - Web interface for testing predictions
   - Performance benchmarks (latency, throughput)

==================================
Exercise 5: Infrastructure as Code
==================================

**Objective:** Define and deploy complete infrastructure using Terraform

**Scenario:** Create production-ready multi-tier web application infrastructure

**Tasks:**

1. **Design Architecture**
   
   Components to include:
   - VPC with public/private subnets
   - Compute instances or GKE cluster
   - Cloud SQL database
   - Cloud Load Balancer
   - Cloud CDN
   - Cloud Storage buckets
   - Cloud Armor (WAF)
   - Monitoring and alerting

2. **Implement Terraform Configuration**
   
   **TODO:**
   
   □ Create modular Terraform code structure:
   
   .. code-block:: text
   
      terraform/
      ├── main.tf
      ├── variables.tf
      ├── outputs.tf
      ├── terraform.tfvars
      └── modules/
          ├── networking/
          ├── compute/
          ├── database/
          └── monitoring/
   
   □ Implement each module
   
   □ Use variables for configuration
   
   □ Implement remote state storage
   
   □ Add proper resource tagging

3. **Deploy and Validate**
   
   **TODO:**
   
   □ Initialize Terraform
   
   □ Plan deployment and review changes
   
   □ Apply configuration
   
   □ Validate all resources created correctly
   
   □ Test application functionality
   
   □ Document cost estimates

4. **Implement CI/CD for Infrastructure**
   
   **TODO:**
   
   □ Create Cloud Build pipeline for Terraform
   
   □ Implement terraform plan on pull requests
   
   □ Automate terraform apply on merge to main
   
   □ Add security scanning (e.g., Checkov)
   
   □ Implement approval gates for production

**Expected Output:**

   - Complete Terraform codebase
   - Deployed infrastructure (with screenshots)
   - CI/CD pipeline for infrastructure
   - Cost analysis document
   - Disaster recovery plan

**Bonus Challenges:**

□ Implement multiple environments (dev, staging, prod)

□ Add monitoring and alerting configuration

□ Implement automated backups

□ Create disaster recovery runbooks

=============================
Exercise 6: Kubernetes on GKE
=============================

**Objective:** Deploy and manage applications on Google Kubernetes Engine

**Scenario:** Deploy a microservices application with service mesh

+++++++++++++++++++++
Part A: Cluster Setup
+++++++++++++++++++++

**Tasks:**

1. **Create GKE Cluster**
   
   .. code-block:: bash
   
      # Create production-ready cluster
      gcloud container clusters create prod-cluster \
          --zone us-central1-a \
          --num-nodes 3 \
          --machine-type n1-standard-2 \
          --enable-autoscaling \
          --min-nodes 1 \
          --max-nodes 10 \
          --enable-autorepair \
          --enable-autoupgrade \
          --enable-ip-alias \
          --network "default" \
          --subnetwork "default" \
          --addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver

2. **Configure Cluster Access**
   
   **TODO:**
   
   □ Configure kubectl access
   
   □ Set up RBAC policies
   
   □ Create namespaces for different environments
   
   □ Implement Pod Security Policies

++++++++++++++++++++++++++++++
Part B: Application Deployment
++++++++++++++++++++++++++++++

**Tasks:**

1. **Deploy Microservices Application**
   
   Create deployments for:
   
   **TODO:**
   
   □ Frontend service (React/Vue)
   
   □ API gateway
   
   □ 3+ backend microservices
   
   □ Database (PostgreSQL using CloudSQL Proxy)
   
   □ Redis cache
   
   □ Message queue

2. **Implement Service Mesh (Istio/Anthos Service Mesh)**
   
   **TODO:**
   
   □ Install service mesh
   
   □ Configure traffic management
   
   □ Implement canary deployments
   
   □ Set up circuit breakers
   
   □ Configure retries and timeouts
   
   □ Implement mutual TLS

3. **Configure Observability**
   
   **TODO:**
   
   □ Set up Prometheus for metrics
   
   □ Configure Grafana dashboards
   
   □ Implement distributed tracing (Cloud Trace)
   
   □ Set up log aggregation
   
   □ Create alerting rules

**Expected Output:**
   - Running GKE cluster with application deployed
   - Service mesh configured
   - Observability dashboard
   - Load testing results
   - Documentation of architecture

+++++++++++++++++++++++++++++++++
Part C: Production Best Practices
+++++++++++++++++++++++++++++++++

**TODO:**

□ Implement HorizontalPodAutoscaler

□ Configure resource requests and limits

□ Set up PodDisruptionBudgets

□ Implement network policies

□ Configure secrets management with Secret Manager

□ Implement backup and disaster recovery

□ Create deployment strategies (blue/green, canary)

=============================
Exercise 7: Cost Optimization
=============================

**Objective:** Analyze and optimize GCP costs

**Tasks:**

1. **Cost Analysis**
   
   **TODO:**
   
   □ Enable detailed billing export to BigQuery
   
   □ Analyze current spending patterns
   
   □ Identify top cost drivers
   
   □ Find unused/underutilized resources
   
   □ Create cost allocation reports by project/team

2. **Implement Cost Controls**
   
   **TODO:**
   
   □ Set up budget alerts
   
   □ Implement resource quotas
   
   □ Create automated shutdown schedules for dev/test
   
   □ Right-size compute instances
   
   □ Implement committed use discounts analysis

3. **Create Cost Dashboard**
   
   **TODO:**
   
   □ Build BigQuery views for cost analysis
   
   □ Create Looker Studio dashboard showing:

      - Daily/monthly spend trends
      - Cost by service
      - Cost by project
      - Cost anomalies
      - Forecasted spend
   
   □ Set up automated cost reports

**Expected Output:**

   - Cost analysis report
   - List of optimization recommendations
   - Implemented cost-saving measures
   - Cost dashboard
   - Estimated annual savings

==============================
Exercise 8: Security Hardening
==============================

**Objective:** Implement security best practices across your GCP infrastructure

**Tasks:**

1. **IAM and Access Control**
   
   **TODO:**
   
   □ Audit current IAM policies
   
   □ Implement least privilege access
   
   □ Create custom IAM roles
   
   □ Set up organization policies
   
   □ Enable MFA for all users
   
   □ Implement service account key rotation

2. **Network Security**
   
   **TODO:**
   
   □ Configure VPC firewall rules
   
   □ Implement Cloud Armor WAF
   
   □ Set up DDoS protection
   
   □ Configure private Google access
   
   □ Implement VPC Service Controls
   
   □ Set up Cloud IDS (Intrusion Detection)

3. **Data Security**
   
   **TODO:**
   
   □ Enable encryption at rest for all resources
   
   □ Configure Customer-Managed Encryption Keys (CMEK)
   
   □ Implement data loss prevention (DLP)
   
   □ Set up audit logging
   
   □ Configure security scanning for containers

4. **Security Monitoring**
   
   **TODO:**
   
   □ Enable Security Command Center
   
   □ Configure security findings
   
   □ Set up security alerts
   
   □ Create incident response procedures
   
   □ Implement automated remediation

**Expected Output:**

   - Security audit report
   - Documented security architecture
   - Incident response playbook
   - Compliance documentation
   - Security monitoring dashboard

=============================
Exercise 9: Disaster Recovery
=============================

**Objective:** Design and test disaster recovery procedures

**Scenario:** Your primary region (us-central1) has become unavailable

**Tasks:**

1. **Design DR Strategy**
   
   **TODO:**
   
   □ Define RTO (Recovery Time Objective)
   
   □ Define RPO (Recovery Point Objective)
   
   □ Design multi-region architecture
   
   □ Document failover procedures
   
   □ Create backup strategies

2. **Implement DR Solution**
   
   **TODO:**
   
   □ Set up multi-region database replication
   
   □ Configure Cloud Load Balancing for multi-region
   
   □ Implement automated backups
   
   □ Create disaster recovery runbooks
   
   □ Set up monitoring for DR readiness

3. **Test DR Procedures**
   
   **TODO:**
   
   □ Perform controlled failover test
   
   □ Measure actual RTO/RPO
   
   □ Document lessons learned
   
   □ Update procedures based on findings
   
   □ Schedule regular DR drills

**Expected Output:**
   - DR architecture documentation
   - Tested failover procedures
   - DR test results
   - Updated runbooks
   - DR cost analysis

==========================
Exercise 10: Final Project
==========================

**Objective:** Build a complete production-ready application on GCP

**Requirements:**

Build a **scalable, secure, cost-optimized application** that includes:

**Architecture Requirements:**

□ Multi-tier architecture (frontend, API, database)

□ Deployed on GKE or Cloud Run

□ CI/CD pipeline with Cloud Build

□ Infrastructure as Code (Terraform)

□ Multi-region deployment

□ Automated backups and disaster recovery

**Technical Requirements:**

□ RESTful API with authentication

□ Database with encryption

□ File storage using Cloud Storage

□ Caching layer (Memorystore)

□ Message queue (Pub/Sub)

□ Serverless functions for background tasks

**Operational Requirements:**

□ Comprehensive monitoring and alerting

□ Centralized logging

□ Cost tracking and optimization

□ Security scanning and compliance

□ Documentation (architecture, runbooks, API docs)

**Bonus Features:**

□ Machine learning integration

□ Real-time features (WebSockets)

□ Mobile app integration

□ Analytics dashboard

**Deliverables:**

1. Source code repository (GitHub)
2. Terraform infrastructure code
3. CI/CD pipeline configuration
4. Architecture diagrams
5. API documentation
6. Deployment guide
7. Operations runbooks
8. Cost analysis report
9. Security audit report
10. Demo video (5-10 minutes)

**Presentation:**

Prepare a 15-minute presentation covering:

- Problem statement and solution
- Architecture decisions and trade-offs
- Challenges and how you overcame them
- Cost analysis and optimization
- Security measures implemented
- Lessons learned
- Future improvements

====================
Submission Checklist
====================

For each exercise, submit:

□ Working code/configuration

□ Screenshots demonstrating functionality

□ Documentation explaining your approach

□ Answers to all questions

□ Cost estimates for resources used

□ Cleanup confirmation (resources deleted to avoid charges)

==============
Grading Rubric
==============

**Functionality (40%)**

- Does the solution work as specified?
- Are all requirements met?
- Is error handling implemented?

**Code Quality (20%)**

- Is code well-organized and readable?
- Are best practices followed?
- Is documentation comprehensive?

**Security (15%)**

- Are security best practices implemented?
- Is sensitive data protected?
- Are access controls properly configured?

**Architecture (15%)**

- Is the architecture scalable?
- Is it cost-effective?
- Are appropriate services used?

**Innovation (10%)**

- Bonus features implemented?
- Creative solutions?
- Extra mile efforts?

=========
Resources
=========

**Documentation:**

- Google Cloud Documentation: https://cloud.google.com/docs
- Terraform GCP Provider: https://registry.terraform.io/providers/hashicorp/google
- GKE Documentation: https://cloud.google.com/kubernetes-engine/docs

**Training:**

- Google Cloud Skills Boost: https://www.cloudskillsboost.google
- Coursera GCP Courses: https://www.coursera.org/googlecloud
- Qwiklabs Hands-on Labs: https://www.qwiklabs.com

**Community:**

- GCP Slack Community
- Stack Overflow [google-cloud-platform]
- Google Cloud Blog
- GitHub GCP Samples

**Tools:**

- gcloud CLI documentation
- Cloud Console
- Cloud Shell
- Visual Studio Code with GCP extensions

============
Getting Help
============

If you get stuck:

1. Check the official documentation
2. Search Stack Overflow
3. Review code samples on GitHub
4. Ask in course forum/Slack channel
5. Attend office hours
6. Pair with a classmate

**Remember:** Making mistakes is part of learning. Don't be afraid to experiment!

===============
Cost Management
===============

.. warning::

   **Important:** GCP resources cost money!
   
   To avoid unexpected charges:
   
   ✓ Always delete resources after completing exercises
   
   ✓ Set up billing alerts ($10, $50, $100)
   
   ✓ Use the free tier when possible
   
   ✓ Shutdown dev resources when not in use
   
   ✓ Review billing daily during active development
   
   ✓ Use the pricing calculator to estimate costs

**Cleanup Commands:**

.. code-block:: bash

   # Delete Compute Engine instances
   gcloud compute instances delete INSTANCE_NAME --zone=ZONE
   
   # Delete GKE cluster
   gcloud container clusters delete CLUSTER_NAME --zone=ZONE
   
   # Delete Cloud Run services
   gcloud run services delete SERVICE_NAME --region=REGION
   
   # Delete Cloud Functions
   gcloud functions delete FUNCTION_NAME --region=REGION
   
   # Delete Cloud Storage buckets
   gsutil rm -r gs://BUCKET_NAME
   
   # Delete BigQuery datasets
   bq rm -r -f DATASET_NAME

**Good luck and happy learning!**

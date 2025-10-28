##########################################
11.0 Introduction to Google Cloud Platform  
##########################################

.. note::

    **Prerequisites**: This chapter assumes familiarity with basic cloud computing concepts 
    covered in Chapter 11_cloud (Cloud Fundamentals). If you're new to cloud computing, 
    start with the main cloud chapter to understand IaaS/PaaS/SaaS, deployment models, 
    and general cloud concepts before diving into GCP-specific implementations.

=======================================
What is Google Cloud Platform (GCP)?
=======================================

Google Cloud Platform (GCP) is Google's comprehensive cloud computing platform, launched in 2008. It runs on the same infrastructure that powers Google Search, Gmail, YouTube, and Google Drive. As the 3rd largest cloud provider globally, GCP offers over 100 services for computing, storage, networking, data analytics, and machine learning.

**Key Characteristics:**

.. code-block:: text

   Global Reach:    40+ regions, 121+ zones worldwide
   Network:         Private fiber-optic global backbone  
   Strengths:       AI/ML, BigQuery, Kubernetes, pricing
   Security:        Encryption by default, Zero Trust model
   Sustainability:  Carbon-neutral, renewable energy powered

========================
GCP's Key Advantages
========================

.. code-block:: text

   Why Choose GCP?
   
   Innovation Leader:        AI/ML, BigQuery, Kubernetes expertise
   Cost-Effective:          Per-second billing, automatic discounts
   Global Network:          Private fiber network, low latency
   Security-First:          Encryption by default, Zero Trust
   Developer-Friendly:      Clean UI, excellent tooling, APIs
   Sustainable:            Carbon-neutral, renewable energy focus

.. note::
   **For Detailed Comparison**: See Chapter 11.11 (Platform Overview) for comprehensive 
   service details and comparisons with AWS/Azure.

==============================
Chapter Navigation Guide
==============================

This GCP chapter is organized for progressive learning:

.. code-block:: text

   Learning Path:
   
   Start Here:
   ├─ 11.0 Introduction (this chapter) - GCP basics & setup
   ├─ 11.1 Identity & Access Management (IAM)
   ├─ 11.2 Networking & VPC
   ├─ 11.3 Compute Services Overview - Service comparison
   ├─ 11.4 Compute Engine (Virtual Machines) - Detailed hands-on
   ├─ 11.5 Cloud Storage
   ├─ 11.6 Serverless (Cloud Functions & Cloud Run)
   ├─ 11.7 Google Kubernetes Engine (GKE)
   ├─ 11.8 Security Best Practices
   ├─ 11.9 FinOps & Cost Optimization
   └─ 11.10 Database Services - Comprehensive overview
   
   Reference Materials:
   └─ 11.11 Platform Overview - Complete service catalog

============================
Getting Started with GCP
============================

**Quick Setup Steps:**

1. **Create Account**: Sign up at https://cloud.google.com
2. **Verify Identity**: Provide credit card (won't be charged during free trial)
3. **Create First Project**: Projects organize all your GCP resources
4. **Enable APIs**: Activate the services you need
5. **Set Up Billing**: Monitor usage with budget alerts

**Essential Tools:**

.. code-block:: text

   GCP Management Options:
   ├─ Cloud Console (Web UI) - Beginner-friendly interface
   ├─ Cloud Shell - Browser-based terminal with gcloud CLI
   ├─ gcloud CLI - Command-line interface for automation
   ├─ Cloud Mobile App - Monitor on the go
   └─ APIs & SDKs - Programmatic access

**Your First 30 Minutes:**

.. code-block:: bash

   # 1. Open Cloud Shell (in web console)
   # 2. Check your project
   gcloud config get-value project
   
   # 3. List available regions
   gcloud compute regions list
   
   # 4. Create a simple storage bucket
   gsutil mb gs://my-unique-bucket-name-$(date +%s)
   
   # 5. Upload a file
   echo "Hello GCP!" > hello.txt
   gsutil cp hello.txt gs://my-unique-bucket-name-*/

========================
Essential GCP Concepts
========================

**Core Service Categories:**

.. code-block:: text

   GCP Services Overview:
   ├─ Compute: VMs, Containers, Serverless
   ├─ Storage: Object, Block, File, Databases  
   ├─ Networking: VPC, Load Balancers, CDN
   ├─ AI/ML: Vertex AI, AutoML, Pre-trained APIs
   ├─ Analytics: BigQuery, Dataflow, Pub/Sub
   └─ DevOps: Cloud Build, GKE, Monitoring

.. note::
   **Detailed Service Information**: For comprehensive service details, pricing, and 
   comparisons, see `Chapter 11.11: Platform Overview <11_platform_overview.rst>`_.

====================================
Account Setup and First Steps
====================================

**Step 1: Create a GCP Account**

1. Visit: https://cloud.google.com
2. Click **Get started for free** or **Try it free**
3. Sign in with your Google account (or create one)
4. Enter billing information

**Free Tier Benefits:**

- **$300 free credits** for 90 days
- **Always Free products** with usage limits:
  - Compute Engine: 1 f1-micro instance/month
  - Cloud Storage: 5 GB standard storage
  - BigQuery: 1 TB queries/month, 10 GB storage
  - Cloud Functions: 2 million invocations/month
  - And many more...

.. note::

    You won't be charged automatically after free trial ends. You must explicitly upgrade to a paid account.

**Step 2: Set Up Cloud Console**

1. Access Cloud Console: https://console.cloud.google.com
2. Familiarize yourself with the interface:
   - **Navigation menu (☰)**: Access all GCP services
   - **Project selector**: Switch between projects
   - **Cloud Shell**: Browser-based terminal
   - **Search bar**: Quickly find resources and documentation

**Step 3: Create Your First Project**

.. code-block:: bash

    # Projects are containers for your GCP resources
    
    # Create project via console:
    # 1. Click project selector at top
    # 2. Click "New Project"
    # 3. Enter project name and ID
    # 4. Select billing account
    # 5. Click "Create"

**Step 4: Install Google Cloud SDK (gcloud)**

**Linux/macOS:**

.. code-block:: bash

    # Download and install
    curl https://sdk.cloud.google.com | bash
    
    # Restart shell
    exec -l $SHELL
    
    # Initialize gcloud
    gcloud init
    
    # Verify installation
    gcloud version

**Windows:**

1. Download installer: https://cloud.google.com/sdk/docs/install
2. Run installer and follow prompts
3. Open Cloud SDK Shell
4. Run `gcloud init`

**Step 5: Authenticate and Configure**

.. code-block:: bash

    # Login to your account
    gcloud auth login
    
    # Set default project
    gcloud config set project PROJECT_ID
    
    # Set default region and zone
    gcloud config set compute/region us-central1
    gcloud config set compute/zone us-central1-a
    
    # View current configuration
    gcloud config list
    
    # List available projects
    gcloud projects list

**Step 6: Enable APIs**

.. code-block:: bash

    # Enable commonly used APIs
    gcloud services enable compute.googleapis.com
    gcloud services enable storage.googleapis.com
    gcloud services enable container.googleapis.com
    
    # List enabled services
    gcloud services list --enabled

==============================
GCP Hierarchy and Organization
==============================

**Resource Hierarchy:**

.. code-block:: text

    Organization (optional)
    └── Folders (optional)
        └── Projects (required)
            └── Resources (VMs, Storage, etc.)

**Key Concepts:**

1. **Organization**: Root node, represents company

   - Centralized control
   - Organization-wide policies
   - Requires Google Workspace or Cloud Identity

2. **Folders**: Group projects by department, team, or environment

   - Apply policies to multiple projects
   - Nested structure supported

3. **Projects**: Container for resources

   - Separate billing and quota management
   - IAM policies applied at project level
   - Project ID must be globally unique

4. **Resources**: Individual services (VMs, databases, etc.)

   - Inherit permissions from project
   - Can have resource-level policies

**Best Practices:**

.. code-block:: text

    my-company (Organization)
    ├── Production (Folder)
    │   ├── web-app-prod (Project)
    │   └── api-prod (Project)
    ├── Staging (Folder)
    │   ├── web-app-staging (Project)
    │   └── api-staging (Project)
    └── Development (Folder)
        ├── web-app-dev (Project)
        └── api-dev (Project)

=================
GCP Pricing Model
=================

**Billing Concepts:**

1. **Pay-as-you-go**: No upfront costs, pay for what you use
2. **Per-second billing**: Billed every second (after first minute)
3. **Automatic discounts**: No upfront commitment needed
4. **Free tier**: Always free usage limits for many services

**Discount Types:**

**1. Sustained Use Discounts (Automatic):**

- Automatic discount for running VMs
- Up to 30% discount
- Based on monthly usage
- No action required

**2. Committed Use Discounts:**

- 1-year or 3-year commitment
- Up to 57% discount on VMs
- Flexible resource allocation

**3. Preemptible/Spot VMs:**

- Up to 80% discount
- Can be terminated anytime
- Good for batch processing

**Cost Management Tools:**

.. code-block:: bash

    # Set up billing budget alerts
    gcloud billing budgets create \
        --billing-account=BILLING_ACCOUNT_ID \
        --display-name="Monthly Budget" \
        --budget-amount=1000USD
    
    # View cost table
    # Navigate to: Billing → Cost table
    
    # Export billing to BigQuery
    # Navigate to: Billing → Billing export

================
Common GCP Tools
================

**1. gcloud (Command Line)**

.. code-block:: bash

    # General format
    gcloud [SERVICE] [GROUP] [COMMAND] [FLAGS]
    
    # Examples
    gcloud compute instances list
    gcloud storage buckets create gs://my-bucket
    gcloud container clusters create my-cluster

**2. Cloud Console (Web UI)**

- URL: https://console.cloud.google.com
- Visual interface for all services
- Resource monitoring and management
- Billing and cost management

**3. Cloud Shell**

- Browser-based terminal
- Pre-installed gcloud, kubectl, docker
- 5 GB persistent disk storage
- Code editor included
- Access from any device

.. code-block:: bash

    # Access Cloud Shell
    # Click Cloud Shell icon in top-right of console
    
    # Pre-installed tools include:
    # - gcloud, gsutil, bq
    # - kubectl, docker, git
    # - Python, Node.js, Go
    # - vim, nano, emacs

**4. Cloud SDK Components**

.. code-block:: bash

    # gcloud: Main CLI tool
    gcloud compute instances list
    
    # gsutil: Cloud Storage tool
    gsutil cp file.txt gs://my-bucket/
    
    # bq: BigQuery tool
    bq query 'SELECT * FROM dataset.table LIMIT 10'
    
    # kubectl: Kubernetes tool (for GKE)
    kubectl get pods

**5. APIs and Client Libraries**

Languages supported:
- Python
- Java
- Node.js
- Go
- C#
- Ruby
- PHP

.. code-block:: python

    # Example: Python client library
    from google.cloud import storage
    
    # Initialize client
    client = storage.Client()
    
    # List buckets
    buckets = client.list_buckets()
    for bucket in buckets:
        print(bucket.name)

==================================
Best Practices for Getting Started
==================================

**1. Organize Your Projects:**

.. code-block:: bash

    # Use descriptive project names
    # Example: company-environment-purpose
    my-company-prod-web
    my-company-dev-api

**2. Enable Billing Alerts:**

.. code-block:: bash

    # Set up budget alerts early
    gcloud billing budgets create \
        --billing-account=BILLING_ACCOUNT_ID \
        --display-name="Development Budget" \
        --budget-amount=100USD \
        --threshold-rule=percent=50

**3. Use Labels and Tags:**

.. code-block:: bash

    # Label resources for organization
    gcloud compute instances create my-vm \
        --labels=env=dev,team=backend,owner=alice

**4. Follow Security Best Practices:**

- Enable MFA on your Google account
- Use service accounts for applications
- Implement principle of least privilege
- Regular security audits

**5. Start Small and Scale:**

- Begin with smallest instance types
- Monitor usage and performance
- Scale up based on actual needs
- Use autoscaling where possible

**6. Use Infrastructure as Code:**

- Define infrastructure in code (Terraform)
- Version control your configurations
- Reproducible environments
- Easy disaster recovery

================
Common Use Cases
================

**1. Web Applications:**

- Compute Engine for VMs
- Cloud Load Balancing
- Cloud CDN for static content
- Cloud SQL for database

**2. Mobile Backend:**

- Cloud Run for APIs
- Firestore for NoSQL database
- Firebase for authentication
- Cloud Functions for serverless logic

**3. Data Analytics:**

- BigQuery for data warehouse
- Dataflow for ETL pipelines
- Data Studio for visualization
- Pub/Sub for event streaming

**4. Machine Learning:**

- Vertex AI for ML models
- AutoML for no-code ML
- TensorFlow on GKE
- Pre-trained APIs (Vision, NLP)

**5. DevOps and CI/CD:**

- Cloud Build for pipelines
- Artifact Registry for containers
- GKE for Kubernetes
- Cloud Deploy for delivery

**6. Hybrid Cloud:**

- Anthos for multi-cloud management
- Cloud VPN/Interconnect for connectivity
- Migrate for Compute Engine
- Cloud Run for Anthos

=====================
Resources and Support
=====================

**Documentation:**

- Official Docs: https://cloud.google.com/docs
- Quickstarts: https://cloud.google.com/docs/get-started
- Code Samples: https://github.com/GoogleCloudPlatform
- Architecture Center: https://cloud.google.com/architecture

**Learning Resources:**

- Google Cloud Skills Boost: https://www.cloudskillsboost.google/
- YouTube Channel: Google Cloud Tech
- Free training: https://cloud.google.com/training
- Codelabs: https://codelabs.developers.google.com/

**Community:**

- Stack Overflow: `google-cloud-platform` tag
- Reddit: r/googlecloud
- Google Cloud Community: https://www.googlecloudcommunity.com/
- Google Cloud Blog: https://cloud.google.com/blog

**Support Options:**

1. **Community Support**: Free, community-driven
2. **Basic Support**: Included with billing account
3. **Standard Support**: Starting at $150/month
4. **Enhanced Support**: Starting at $500/month
5. **Premium Support**: Custom pricing, 24/7 support

**Getting Help:**

.. code-block:: bash

    # Built-in help
    gcloud help
    gcloud compute help
    gcloud compute instances create --help
    
    # Open documentation
    gcloud topic [TOPIC_NAME]

============
What's Next?
============

Now that you have a solid introduction to GCP, proceed with the following chapters:

1. **IAM (Identity and Access Management)**: Learn how to secure your GCP resources
2. **Networking**: Understand VPC, subnets, and firewall rules
3. **Compute Engine**: Deploy and manage virtual machines
4. **Cloud Storage**: Store and manage objects and files
5. **Serverless**: Build applications with Cloud Run and Functions
6. **GKE**: Deploy containerized applications with Kubernetes
7. **FinOps**: Optimize costs and manage budgets
8. **Security**: Implement security best practices

**First Hands-On Exercise:**

.. code-block:: bash

    # 1. Create your first project
    gcloud projects create my-first-gcp-project --name="My First GCP Project"
    
    # 2. Set it as default
    gcloud config set project my-first-gcp-project
    
    # 3. Enable Compute Engine API
    gcloud services enable compute.googleapis.com
    
    # 4. Create your first VM
    gcloud compute instances create my-first-vm \
        --zone=us-central1-a \
        --machine-type=e2-micro
    
    # 5. SSH into the VM
    gcloud compute ssh my-first-vm --zone=us-central1-a
    
    # 6. Clean up
    gcloud compute instances delete my-first-vm --zone=us-central1-a

.. tip::

    **Pro Tip**: Use Cloud Shell for the first exercises. It's free, pre-configured, and you don't need to install anything on your local machine!

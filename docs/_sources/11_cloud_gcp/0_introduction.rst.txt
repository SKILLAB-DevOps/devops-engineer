##########################################
11.0 Introduction to Google Cloud Platform
##########################################

.. note::

    Google Cloud Platform (GCP) is a suite of cloud computing services offered by Google. It runs on the same infrastructure that Google uses internally for its end-user products like Google Search, Gmail, YouTube, and Google Drive. GCP provides a wide range of services for computing, storage, networking, big data, machine learning, and more.

==============================
What is Google Cloud Platform?
==============================

Google Cloud Platform is one of the leading cloud service providers, alongside Amazon Web Services (AWS) and Microsoft Azure. Launched in 2008, GCP has grown to become a comprehensive cloud platform offering over 100 products and services.

**Key Characteristics:**

- **Global Infrastructure**: 40+ regions and 121+ zones worldwide
- **Google's Network**: Private fiber-optic network connecting data centers
- **Innovation Focus**: Leading in AI/ML, big data, and Kubernetes
- **Security First**: Built-in security at every layer
- **Sustainability**: Carbon-neutral since 2007, aiming for 24/7 carbon-free energy by 2030
- **Open Source**: Strong commitment to open-source technologies

===============
Why Choose GCP?
===============

**1. Performance and Speed:**

- **Premium Network**: Google's private global network offers lower latency
- **Live Migration**: VMs can be live-migrated during maintenance with zero downtime
- **Fast Innovation**: Regular updates with cutting-edge features
- **Global Load Balancing**: Automatically routes traffic to the nearest available resource

**2. Advanced Data and AI/ML Capabilities:**

- **BigQuery**: Serverless data warehouse for analytics at scale
- **TensorFlow**: Industry-leading machine learning framework
- **Vertex AI**: Unified AI platform for building and deploying ML models
- **Natural Language Processing**: Pre-trained models for text analysis
- **Computer Vision**: Image and video analysis APIs

**3. Kubernetes Expertise:**

- **GKE (Google Kubernetes Engine)**: Managed Kubernetes service
- **Kubernetes Origins**: Google created Kubernetes based on internal Borg system
- **Autopilot Mode**: Fully managed, hands-off Kubernetes
- **Best Practices**: Built-in security and operational best practices

**4. Pricing and Cost Optimization:**

- **Per-Second Billing**: Pay only for what you use (after first minute)
- **Sustained Use Discounts**: Automatic discounts for long-running workloads
- **Committed Use Discounts**: Save up to 57% with 1 or 3-year commitments
- **Preemptible/Spot VMs**: Up to 80% discount for fault-tolerant workloads
- **Transparent Pricing**: Clear, straightforward pricing model

**5. Developer Experience:**

- **Cloud Shell**: Browser-based command line with pre-installed tools
- **Cloud Code**: IDE extensions for VS Code and IntelliJ
- **Infrastructure as Code**: Support for Terraform, Deployment Manager
- **APIs and SDKs**: Comprehensive APIs for all services in multiple languages

**6. Security and Compliance:**

- **Encryption by Default**: Data encrypted at rest and in transit
- **Zero Trust Architecture**: BeyondCorp security model
- **Compliance Certifications**: GDPR, HIPAA, PCI-DSS, SOC 2/3, ISO 27001
- **Security Command Center**: Centralized security and risk management
- **Identity-Aware Proxy**: Context-aware access to applications

===================
GCP vs AWS vs Azure
===================

**Quick Comparison:**

+---------------------------+-------------------------+-------------------------+-------------------------+
| Feature                   | GCP                     | AWS                     | Azure                   |
+===========================+=========================+=========================+=========================+
| **Market Position**       | 3rd largest             | Market leader           | 2nd largest             |
+---------------------------+-------------------------+-------------------------+-------------------------+
| **Launched**              | 2008                    | 2006                    | 2010                    |
+---------------------------+-------------------------+-------------------------+-------------------------+
| **Strengths**             | AI/ML, Big Data,        | Breadth of services,    | Enterprise integration, |
|                           | Kubernetes              | Mature ecosystem        | Hybrid cloud            |
+---------------------------+-------------------------+-------------------------+-------------------------+
| **Pricing**               | Per-second billing,     | Complex pricing,        | Per-minute billing,     |
|                           | Automatic discounts     | Reserved instances      | Hybrid benefits         |
+---------------------------+-------------------------+-------------------------+-------------------------+
| **Network**               | Private global network  | Public internet-based   | ExpressRoute available  |
+---------------------------+-------------------------+-------------------------+-------------------------+
| **Data Analytics**        | BigQuery (serverless)   | Redshift, Athena        | Synapse Analytics       |
+---------------------------+-------------------------+-------------------------+-------------------------+
| **Kubernetes**            | GKE (native)            | EKS                     | AKS                     |
+---------------------------+-------------------------+-------------------------+-------------------------+
| **Serverless**            | Cloud Run, Functions    | Lambda, Fargate         | Functions, Container    |
|                           |                         |                         | Apps                    |
+---------------------------+-------------------------+-------------------------+-------------------------+
| **Best For**              | Startups, data-driven   | Large enterprises,      | Microsoft shops,        |
|                           | companies, ML projects  | Broad requirements      | Hybrid scenarios        |
+---------------------------+-------------------------+-------------------------+-------------------------+

==========================
GCP Global Infrastructure
==========================

**Regions and Zones:**

- **Region**: Independent geographic area (e.g., us-central1, europe-west1)
  - Contains multiple zones
  - Each region isolated from other regions
  - Provides high availability and fault tolerance

- **Zone**: Deployment area within a region (e.g., us-central1-a, us-central1-b)
  - Single failure domain
  - Low-latency network connection to other zones in same region
  - Resources in different zones isolated from each other

**Network Architecture:**

.. code-block:: text

    Google's Private Network
    ├── Edge Points of Presence (100+)
    │   ├── Cloud CDN
    │   └── Load Balancing Entry Points
    │
    ├── Regional Networks (40+ regions)
    │   ├── us-central1 (Iowa)
    │   ├── us-east1 (South Carolina)
    │   ├── us-west1 (Oregon)
    │   ├── europe-west1 (Belgium)
    │   ├── asia-southeast1 (Singapore)
    │   └── ... more regions
    │
    └── Private Fiber-Optic Links
        └── Petabit-scale backbone

**Key Regions:**

- **Americas**: US (multiple), Canada, Brazil, Chile
- **Europe**: Belgium, Finland, UK, Germany, France, Netherlands
- **Asia Pacific**: Singapore, Taiwan, Japan, Australia, India
- **Middle East**: Israel
- **Africa**: South Africa

==========================
Core GCP Services Overview
==========================

**Compute Services:**

+---------------------------+------------------------------------------+
| Service                   | Description                              |
+===========================+==========================================+
| **Compute Engine**        | Virtual machines (IaaS)                  |
+---------------------------+------------------------------------------+
| **Google Kubernetes**     | Managed Kubernetes clusters              |
| **Engine (GKE)**          |                                          |
+---------------------------+------------------------------------------+
| **Cloud Run**             | Serverless containers                    |
+---------------------------+------------------------------------------+
| **Cloud Functions**       | Event-driven serverless functions        |
+---------------------------+------------------------------------------+
| **App Engine**            | Fully managed application platform       |
+---------------------------+------------------------------------------+

**Storage Services:**

+---------------------------+------------------------------------------+
| Service                   | Description                              |
+===========================+==========================================+
| **Cloud Storage**         | Object storage (like AWS S3)             |
+---------------------------+------------------------------------------+
| **Persistent Disk**       | Block storage for VMs                    |
+---------------------------+------------------------------------------+
| **Filestore**             | Managed NFS file storage                 |
+---------------------------+------------------------------------------+
| **Cloud SQL**             | Managed relational databases             |
|                           | (MySQL, PostgreSQL, SQL Server)          |
+---------------------------+------------------------------------------+
| **Cloud Spanner**         | Globally distributed database            |
+---------------------------+------------------------------------------+
| **Firestore**             | NoSQL document database                  |
+---------------------------+------------------------------------------+
| **Bigtable**              | NoSQL wide-column database               |
+---------------------------+------------------------------------------+

**Networking Services:**

+---------------------------+------------------------------------------+
| Service                   | Description                              |
+===========================+==========================================+
| **VPC**                   | Virtual Private Cloud networking         |
+---------------------------+------------------------------------------+
| **Cloud Load Balancing**  | Global, scalable load balancing          |
+---------------------------+------------------------------------------+
| **Cloud CDN**             | Content delivery network                 |
+---------------------------+------------------------------------------+
| **Cloud DNS**             | Managed DNS service                      |
+---------------------------+------------------------------------------+
| **Cloud NAT**             | Network address translation              |
+---------------------------+------------------------------------------+
| **Cloud VPN**             | VPN connectivity                         |
+---------------------------+------------------------------------------+
| **Cloud Interconnect**    | Dedicated network connections            |
+---------------------------+------------------------------------------+

**Big Data and Analytics:**

+---------------------------+------------------------------------------+
| Service                   | Description                              |
+===========================+==========================================+
| **BigQuery**              | Serverless data warehouse                |
+---------------------------+------------------------------------------+
| **Dataflow**              | Stream and batch data processing         |
+---------------------------+------------------------------------------+
| **Dataproc**              | Managed Hadoop and Spark                 |
+---------------------------+------------------------------------------+
| **Pub/Sub**               | Message queue and event streaming        |
+---------------------------+------------------------------------------+
| **Data Fusion**           | Visual data integration                  |
+---------------------------+------------------------------------------+

**AI and Machine Learning:**

+---------------------------+------------------------------------------+
| Service                   | Description                              |
+===========================+==========================================+
| **Vertex AI**             | Unified ML platform                      |
+---------------------------+------------------------------------------+
| **AutoML**                | Custom ML models without code            |
+---------------------------+------------------------------------------+
| **Vision AI**             | Image recognition and analysis           |
+---------------------------+------------------------------------------+
| **Natural Language AI**   | Text analysis and understanding          |
+---------------------------+------------------------------------------+
| **Translation AI**        | Language translation                     |
+---------------------------+------------------------------------------+
| **Speech-to-Text**        | Audio transcription                      |
+---------------------------+------------------------------------------+

**Developer Tools:**

+---------------------------+------------------------------------------+
| Service                   | Description                              |
+===========================+==========================================+
| **Cloud Build**           | CI/CD platform                           |
+---------------------------+------------------------------------------+
| **Cloud Source**          | Git repository hosting                   |
| **Repositories**          |                                          |
+---------------------------+------------------------------------------+
| **Artifact Registry**     | Container and package registry           |
+---------------------------+------------------------------------------+
| **Cloud Deploy**          | Continuous delivery                      |
+---------------------------+------------------------------------------+

**Management and Monitoring:**

+---------------------------+------------------------------------------+
| Service                   | Description                              |
+===========================+==========================================+
| **Cloud Logging**         | Centralized logging                      |
+---------------------------+------------------------------------------+
| **Cloud Monitoring**      | Infrastructure and application           |
|                           | monitoring                               |
+---------------------------+------------------------------------------+
| **Cloud Trace**           | Distributed tracing                      |
+---------------------------+------------------------------------------+
| **Cloud Profiler**        | Application performance profiling        |
+---------------------------+------------------------------------------+
| **Error Reporting**       | Real-time error monitoring               |
+---------------------------+------------------------------------------+

**Security and Identity:**

+---------------------------+------------------------------------------+
| Service                   | Description                              |
+===========================+==========================================+
| **IAM**                   | Identity and access management           |
+---------------------------+------------------------------------------+
| **Cloud Identity**        | Identity as a service                    |
+---------------------------+------------------------------------------+
| **Secret Manager**        | Secure secret storage                    |
+---------------------------+------------------------------------------+
| **Security Command**      | Security and risk management             |
| **Center**                |                                          |
+---------------------------+------------------------------------------+
| **Cloud KMS**             | Key management service                   |
+---------------------------+------------------------------------------+
| **Binary Authorization**  | Deploy-time security enforcement         |
+---------------------------+------------------------------------------+

========================
Getting Started with GCP
========================

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

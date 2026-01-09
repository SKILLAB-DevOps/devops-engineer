#################################
10.5 Terraform Practical Examples
#################################

This chapter provides references to hands-on examples that demonstrate real-world Terraform usage with Google Cloud Platform, progressing from simple to complex scenarios.

======================
Learning Path Overview
======================

The practical examples demonstrate the complete journey from basic cloud services to advanced container orchestration, designed for progressive learning:

**Foundation → Security → Scaling → Modern Architecture**

.. code-block:: bash

    source_code/cloud/gcp/
    ├── 01-gcp-storage-hello-world/          # Start here
    ├── 02-gcp-compute-hello-world/          
    ├── 03-gcp-compute-wordpress/            
    ├── 04-gcp-wordpress-variables/          
    ├── 05-gcp-wordpress-https/              
    ├── 06-gcp-wordpress-state/              
    ├── 07-gcp-wordpress-modules/            
    ├── 08-gcp-load-balancer/                
    ├── 09-gcp-auto-scaling/                 
    ├── 10-gcp-containers/                   
    ├── 11-gcp-kubernetes/                   
    ├── 12-weather-api-vm/                   
    ├── 13-weather-api-serverless/           
    └── 14-weather-api-container/            # Advanced

===========================
Foundation Examples (01-03)
===========================

**1. Static Website Hosting (01-gcp-storage-hello-world)**

**Purpose**: Introduction to GCP and Terraform basics

**What You'll Learn**:

- Google Cloud Storage bucket creation
- Public access policies and IAM
- Cost-effective static website hosting
- Basic Terraform syntax and workflow

**Key Terraform Concepts**:

.. code-block:: hcl

    # Basic provider configuration
    provider "google" {
      project = "your-project-id"
      region  = "us-central1"
    }
    
    # Simple resource creation
    resource "google_storage_bucket" "website" {
      name     = "my-website-bucket"
      location = "US"
      
      website {
        main_page_suffix = "index.html"
        not_found_page   = "404.html"
      }
    }

**Skills Developed**:

- Terraform initialization and basic commands
- GCP project setup and authentication
- Understanding of cloud storage services

---

**2. Virtual Machine Deployment (02-gcp-compute-hello-world)**

**Purpose**: Basic compute infrastructure

**What You'll Learn**:

- Compute Engine instance creation
- Firewall rules and network security
- Startup scripts for automation
- SSH access and basic VM management

**Key Terraform Concepts**:

.. code-block:: hcl

    # Compute instance with startup script
    resource "google_compute_instance" "web_server" {
      name         = "web-server"
      machine_type = "e2-micro"
      zone         = "us-central1-a"
      
      boot_disk {
        initialize_params {
          image = "ubuntu-os-cloud/ubuntu-2204-lts"
        }
      }
      
      metadata_startup_script = file("${path.module}/startup.sh")
    }

**Skills Developed**:

- Virtual machine provisioning
- Network configuration basics
- Linux system administration concepts

---

**3. Full Application Stack (03-gcp-compute-wordpress)**

**Purpose**: Complete web application deployment

**What You'll Learn**:

- LAMP stack installation and configuration
- Database setup and management
- Multi-service application architecture
- Service integration and dependencies

**Key Terraform Concepts**:

.. code-block:: hcl

    # Complex startup script with multiple services
    resource "google_compute_instance" "wordpress" {
      metadata_startup_script = templatefile("${path.module}/install.sh", {
        db_password = var.db_password
        site_title  = var.site_title
      })
    }

**Skills Developed**:

- Application deployment strategies
- Database configuration
- Template usage and variable interpolation

=========================================
Security & Configuration Examples (04-07)
=========================================

**4. Configuration Management (04-gcp-wordpress-variables)**

**Purpose**: Flexible and reusable infrastructure code

**What You'll Learn**:

- Terraform variables and their types
- Environment-specific configurations
- Input validation and defaults
- Variable files and best practices

**Key Terraform Concepts**:

.. code-block:: hcl

    # Variable definitions with validation
    variable "environment" {
      description = "Environment name"
      type        = string
      
      validation {
        condition     = contains(["dev", "staging", "prod"], var.environment)
        error_message = "Environment must be dev, staging, or prod."
      }
    }
    
    # Conditional resource creation
    resource "google_compute_instance" "app" {
      machine_type = var.environment == "prod" ? "e2-medium" : "e2-micro"
      
      labels = {
        environment = var.environment
        cost_center = var.cost_center
      }
    }

**Skills Developed**:

- Infrastructure parameterization
- Environment management strategies
- Code reusability principles

---

**5. Security Implementation (05-gcp-wordpress-https)**

**Purpose**: Secure web applications with SSL/TLS

**What You'll Learn**:

- SSL certificate management
- HTTPS redirection and enforcement
- Static IP address allocation
- Security best practices

**Key Terraform Concepts**:

.. code-block:: hcl

    # Static IP for consistent SSL setup
    resource "google_compute_address" "static_ip" {
      name = "wordpress-static-ip"
    }
    
    # Instance with static IP
    resource "google_compute_instance" "wordpress" {
      network_interface {
        access_config {
          nat_ip = google_compute_address.static_ip.address
        }
      }
    }

**Skills Developed**:

- Web security fundamentals
- Certificate management
- Network security configuration

---

**6. Team Collaboration (06-gcp-wordpress-state)**

**Purpose**: Remote state management for teams

**What You'll Learn**:

- Remote state backends
- State locking and consistency
- Team collaboration workflows
- State backup and recovery

**Key Terraform Concepts**:

.. code-block:: hcl

    # Remote state configuration
    terraform {
      backend "gcs" {
        bucket = "my-terraform-state"
        prefix = "wordpress-production"
      }
    }

**Skills Developed**:

- Team workflows and collaboration
- State management strategies
- Infrastructure versioning

---

**7. Modular Architecture (07-gcp-wordpress-modules)**

**Purpose**: Reusable and maintainable infrastructure

**What You'll Learn**:

- Module creation and structure
- Module versioning and distribution
- Inter-module communication
- Design patterns for infrastructure

**Key Terraform Concepts**:

.. code-block:: hcl

    # Module usage
    module "networking" {
      source = "./modules/networking"
      
      project_id = var.project_id
      region     = var.region
    }
    
    module "compute" {
      source = "./modules/compute"
      
      network_id    = module.networking.network_id
      subnet_id     = module.networking.subnet_id
      instance_name = var.instance_name
    }

**Skills Developed**:

- Modular design principles
- Code organization and structure
- Reusable component creation

=======================================
Scaling & Availability Examples (08-09)
=======================================

**8. High Availability (08-gcp-load-balancer)**

**Purpose**: Load balancing and redundancy

**What You'll Learn**:

- Multiple server deployment
- Load balancer configuration
- Health checks and failover
- Traffic distribution strategies

**Key Terraform Concepts**:

.. code-block:: text

    # Multiple instances with load balancing
    resource "google_compute_instance" "web_servers" {
      count = 2
      name  = "web-server-${count.index + 1}"
      
      # Spread across zones for redundancy
      zone = data.google_compute_zones.available.names[count.index]
    }
    
    # Load balancer target pool
    resource "google_compute_target_pool" "web_servers" {
      name      = "web-server-pool"
      instances = google_compute_instance.web_servers[*].self_link
      
      health_checks = [
        google_compute_http_health_check.web_servers.name
      ]
    }

**Skills Developed**:

- High availability design
- Load balancing concepts
- Fault tolerance strategies

---

**9. Elastic Scaling (09-gcp-auto-scaling)**

**Purpose**: Automatic scaling based on demand

**What You'll Learn**:

- Instance templates and groups
- Auto-scaling policies
- CPU-based scaling triggers
- Managed instance groups

**Key Terraform Concepts**:

.. code-block:: hcl

    # Instance template for auto-scaling
    resource "google_compute_instance_template" "web_server" {
      name_prefix  = "web-server-template-"
      machine_type = "e2-micro"
      
      lifecycle {
        create_before_destroy = true
      }
    }
    
    # Auto-scaler with CPU-based scaling
    resource "google_compute_autoscaler" "web_servers" {
      name   = "web-server-autoscaler"
      target = google_compute_instance_group_manager.web_servers.id
      
      autoscaling_policy {
        max_replicas    = 10
        min_replicas    = 2
        cooldown_period = 60
        
        cpu_utilization {
          target = 0.7
        }
      }
    }

**Skills Developed**:

- Elastic infrastructure design
- Performance-based scaling
- Resource optimization

====================================
Modern Architecture Examples (10-11)
====================================

**10. Containerization (10-gcp-containers)**

**Purpose**: Introduction to container technology

**What You'll Learn**:

- Docker containerization basics
- Container-Optimized OS
- Multi-container applications
- Microservices architecture fundamentals

**Key Terraform Concepts**:

.. code-block:: hcl

    # Container-optimized VM
    resource "google_compute_instance" "container_vm" {
      boot_disk {
        initialize_params {
          image = "cos-cloud/cos-stable"  # Container-Optimized OS
        }
      }
      
      # Docker Compose setup via metadata
      metadata = {
        "docker-compose" = file("${path.module}/docker-compose.yml")
      }
    }

**Skills Developed**:

- Container technology basics
- Application containerization
- Service orchestration introduction

---

**11. Container Orchestration (11-gcp-kubernetes)**

**Purpose**: Kubernetes and container orchestration at scale

**What You'll Learn**:

- Google Kubernetes Engine (GKE)
- Pod deployments and services
- Container scaling and management
- Load balancing for containers
- Self-healing infrastructure

**Key Terraform Concepts**:

.. code-block:: hcl

    # GKE cluster creation
    resource "google_container_cluster" "primary" {
      name     = "learning-cluster"
      location = "us-central1-a"
      
      initial_node_count = 2
      
      node_config {
        machine_type = "e2-small"
        oauth_scopes = [
          "https://www.googleapis.com/auth/cloud-platform"
        ]
      }
    }

**Skills Developed**:

- Container orchestration concepts
- Kubernetes fundamentals
- Cloud-native architecture patterns

=======================================
Application Deployment Patterns (12-14)
=======================================

These examples demonstrate the same application (FastAPI Weather API) deployed using three different strategies:

**12. Traditional VM Deployment (12-weather-api-vm)**

**Deployment Pattern**: Infrastructure as a Service (IaaS)

**When to Use**:

- Legacy applications requiring specific OS configurations
- Applications needing persistent local storage
- Workloads requiring full system control

**Key Learning Points**:

.. code-block:: hcl

    # Traditional VM with application installation
    resource "google_compute_instance" "weather_api" {
      metadata_startup_script = file("${path.module}/install_app.sh")
      
      # Persistent disk for application data
      attached_disk {
        source = google_compute_disk.app_data.self_link
      }
    }

---

**13. Serverless Deployment (13-weather-api-serverless)**

**Deployment Pattern**: Function as a Service (FaaS) / Platform as a Service (PaaS)

**When to Use**:

- Event-driven applications
- Variable or unpredictable traffic
- Minimal operational overhead requirements

**Key Learning Points**:

.. code-block:: hcl

    # Cloud Run service for serverless deployment
    resource "google_cloud_run_service" "weather_api" {
      name     = "weather-api"
      location = "us-central1"
      
      template {
        spec {
          containers {
            image = "gcr.io/${var.project_id}/weather-api:latest"
            
            # Automatic scaling configuration
            resources {
              limits = {
                cpu    = "1000m"
                memory = "512Mi"
              }
            }
          }
          
          container_concurrency = 100
        }
        
        metadata {
          annotations = {
            "autoscaling.knative.dev/maxScale" = "10"
            "autoscaling.knative.dev/minScale" = "0"
          }
        }
      }
    }

---

**14. Container Orchestration (14-weather-api-container)**

**Deployment Pattern**: Container as a Service (CaaS)

**When to Use**:

- Microservices architectures
- Applications requiring advanced orchestration
- Complex service mesh requirements

**Key Learning Points**:

.. code-block:: hcl

    # GKE cluster with application deployment
    resource "google_container_cluster" "weather_cluster" {
      name               = "weather-api-cluster"
      initial_node_count = 2
    }
    
    # The application is deployed using Kubernetes manifests
    # Referenced in the deployment scripts

=====================
Getting Started Guide
=====================

**Prerequisites Setup:**

.. code-block:: bash

    # 1. Install required tools
    # Install Terraform
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    sudo apt-get update && sudo apt-get install terraform
    
    # Install Google Cloud SDK
    curl https://sdk.cloud.google.com | bash
    exec -l $SHELL
    
    # 2. Authenticate with GCP
    gcloud auth login
    gcloud auth application-default login
    gcloud config set project YOUR_PROJECT_ID

**Example Workflow:**

.. code-block:: bash

    # Start with the simplest example
    cd source_code/cloud/gcp/01-gcp-storage-hello-world
    
    # Review the code
    cat main.tf
    cat README.md
    
    # Initialize and deploy
    terraform init
    terraform plan
    terraform apply
    
    # Test the deployment
    # (Instructions in each example's README)
    
    # Clean up
    terraform destroy

**Learning Recommendations:**

1. **Work Through Examples in Order**: Each builds upon previous concepts
2. **Read All README Files**: Comprehensive documentation and learning objectives
3. **Experiment with Variables**: Modify configurations to understand behavior
4. **Test Thoroughly**: Use provided testing commands
5. **Clean Up Resources**: Always destroy test infrastructure to avoid costs

=========================
Skills Progression Matrix
=========================

+-------------------+------------------+------------------+------------------+------------------+
| Skill Category    | Foundation       | Security &       | Scaling &        | Modern           |
|                   | (01-03)          | Config (04-07)   | Availability     | Architecture     |
|                   |                  |                  | (08-09)          | (10-14)          |
+===================+==================+==================+==================+==================+
| **Terraform**     | Basic syntax,    | Variables,       | Advanced         | Complex          |
| **Concepts**      | providers,       | modules,         | resources,       | deployments,     |
|                   | resources        | state mgmt       | dependencies     | multi-service    |
+-------------------+------------------+------------------+------------------+------------------+
| **GCP Services**  | Storage,         | IAM, Security,   | Load Balancers,  | GKE, Cloud Run,  |
|                   | Compute Engine   | SSL certs        | Auto-scaling     | Container        |
|                   |                  |                  |                  | Registry         |
+-------------------+------------------+------------------+------------------+------------------+
| **DevOps**        | Basic            | Team             | High             | CI/CD,           |
| **Practices**     | automation       | collaboration,   | availability,    | Container        |
|                   |                  | version control  | monitoring       | orchestration    |
+-------------------+------------------+------------------+------------------+------------------+
| **Architecture**  | Single service   | Secure apps,     | Scalable         | Microservices,   |
| **Patterns**      | deployment       | multi-env        | systems,         | cloud-native     |
|                   |                  |                  | fault tolerance  | architecture     |
+-------------------+------------------+------------------+------------------+------------------+

====================
Additional Resources
====================

**Documentation References:**

- `Terraform Google Provider <https://registry.terraform.io/providers/hashicorp/google/latest/docs>`_
- `Google Cloud Documentation <https://cloud.google.com/docs>`_
- `Terraform Best Practices <https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html>`_

**Community Resources:**

- `Terraform Google Modules <https://github.com/terraform-google-modules>`_
- `Google Cloud Architecture Center <https://cloud.google.com/architecture>`_
- `Terraform Registry <https://registry.terraform.io/>`_

**Next Steps After Completing Examples:**

1. **Implement CI/CD**: Set up automated deployments with GitHub Actions or Cloud Build
2. **Add Monitoring**: Integrate Cloud Monitoring and Logging
3. **Security Hardening**: Implement advanced security practices
4. **Cost Optimization**: Use cost management tools and policies
5. **Multi-Region Deployment**: Expand to global infrastructure

.. note::

    These examples are designed for learning and development. For production deployments, additional considerations around security, monitoring, backup, and disaster recovery should be implemented.
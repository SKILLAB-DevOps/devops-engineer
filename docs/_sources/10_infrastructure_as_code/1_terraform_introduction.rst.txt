########################################
10.1 Terraform & OpenTofu - Introduction
########################################

==================
What is Terraform?
==================

Terraform is an infrastructure as code tool originally created by HashiCorp in 2014. It enables you to define, provision, and manage infrastructure across multiple cloud providers using a declarative configuration language called HCL (HashiCorp Configuration Language).

**Core Value Proposition:**

Terraform allows you to build, change, and version infrastructure safely and efficiently. Instead of manually creating resources through web consoles or CLI commands, you declare what you want in configuration files, and Terraform handles the creation and management of those resources.

**What Terraform is Used For:**

1. **Multi-Cloud Infrastructure Provisioning**
   
   - Create virtual machines, networks, storage, and databases across AWS, GCP, Azure, and 3000+ other provider resources
   - Manage DNS records, CDN configurations, and load balancers
   - Provision Kubernetes clusters and container registries

2. **Infrastructure Lifecycle Management**
   
   - Create, update, and destroy infrastructure resources
   - Track infrastructure changes over time with state management
   - Plan changes before applying them to prevent unwanted modifications

3. **Compliance and Governance**
   
   - Enforce organizational policies through code
   - Standardize infrastructure patterns across teams
   - Audit infrastructure changes through version control

4. **Cost Optimization**
   
   - Automatically provision resources only when needed
   - Schedule infrastructure creation/destruction
   - Right-size resources based on actual usage patterns

.. note::

    Terraform treats infrastructure as code, meaning you can version control it, review changes through pull requests, and apply software development best practices to your infrastructure.

=================
What is OpenTofu?
=================

**OpenTofu** is an open-source fork of Terraform, created in 2023 by the OpenTofu Foundation after HashiCorp changed Terraform's license from MPL 2.0 to the Business Source License (BSL).

**Why OpenTofu Was Created:**

1. **License Concerns**: HashiCorp's license change meant Terraform could no longer be used by competing commercial products
2. **Community Control**: Ensure the tool remains truly open-source and community-driven
3. **Vendor Independence**: Prevent single-vendor control over critical infrastructure tooling

**Who Created OpenTofu:**

- **Linux Foundation** hosts the project
- **Major Contributors**: Spacelift, env0, Scalr, Digger, Terramate, and hundreds of community contributors
- **Industry Support**: Backed by major cloud providers and infrastructure companies

**When to Use OpenTofu vs Terraform:**

**Use OpenTofu When:**

- You need guaranteed open-source licensing
- Your organization requires vendor-neutral tooling
- You want to contribute to community-driven development
- You're building commercial products that compete with HashiCorp

**Use Terraform When:**

- You need HashiCorp's commercial support and enterprise features
- Your organization already has established Terraform workflows
- You require specific HashiCorp ecosystem integrations (Vault, Consul)
- You prefer stability over cutting-edge features

**Compatibility:**

OpenTofu maintains **100% compatibility** with Terraform 1.5.x configurations and state files, making migration seamless.

.. code-block:: bash

    # Switch from Terraform to OpenTofu
    terraform --version
    tofu --version
    
    # Same commands, same syntax
    tofu init
    tofu plan
    tofu apply

================================
HashiCorp Configuration Language
================================

Terraform uses **HCL (HashiCorp Configuration Language)**, a declarative language designed to be human-readable and machine-friendly. HCL is similar to JSON but more concise and easier to read.

.. note::

    For a comprehensive comparison between Terraform and Pulumi, including syntax examples, architectural differences, and decision criteria for choosing between declarative (HCL) and imperative (programming languages) approaches, see **Chapter 10.0: Infrastructure as Code Introduction**, section "Infrastructure Provisioning: Terraform vs Pulumi".

**Example: Creating a GCP Compute Instance**

.. code-block:: hcl

    # Define the provider
    provider "google" {
      project = "my-gcp-project"
      region  = "us-central1"
    }
    
    # Create a VPC network
    resource "google_compute_network" "main" {
      name                    = "main-network"
      auto_create_subnetworks = false
      description            = "Main production network"
    }
    
    # Create a subnet
    resource "google_compute_subnetwork" "public" {
      name          = "public-subnet"
      network       = google_compute_network.main.id
      ip_cidr_range = "10.0.1.0/24"
      region        = "us-central1"
      
      description = "Public subnet for web servers"
    }
    
    # Create a firewall rule
    resource "google_compute_firewall" "web" {
      name    = "allow-web-traffic"
      network = google_compute_network.main.name
      
      description = "Allow HTTP and HTTPS traffic"
      
      allow {
        protocol = "tcp"
        ports    = ["80", "443"]
      }
      
      source_ranges = ["0.0.0.0/0"]
      target_tags   = ["web-server"]
    }
    
    # Create a Compute Engine instance
    resource "google_compute_instance" "web_server" {
      name         = "web-server"
      machine_type = "e2-micro"
      zone         = "us-central1-a"
      
      tags = ["web-server"]
      
      boot_disk {
        initialize_params {
          image = "ubuntu-os-cloud/ubuntu-2204-lts"
          size  = 20
        }
      }
      
      network_interface {
        network    = google_compute_network.main.id
        subnetwork = google_compute_subnetwork.public.id
        
        access_config {
          # Ephemeral public IP
        }
      }
      
      metadata = {
        Environment = "production"
        ManagedBy   = "terraform"
      }
    }

==================================
Key Benefits of IaC with Terraform
==================================

**1. Declarative Approach**

You describe the desired end state, not the steps to get there:

.. code-block:: hcl

    # You declare what you want
    resource "google_compute_instance" "web" {
      name         = "web-server"
      machine_type = "e2-micro"
    }
    
    # Terraform figures out how to create it

**2. Infrastructure as Code**

- **Version Control**: Track every infrastructure change in Git
- **Code Reviews**: Peer review infrastructure changes like application code
- **Automation**: Integrate with CI/CD pipelines
- **Documentation**: The code documents the infrastructure

**3. Plan Before Apply**

.. code-block:: bash

    # Always preview changes before applying
    terraform plan
    # Shows exactly what will be created, modified, or destroyed
    
    terraform apply
    # Only executes the planned changes

**4. State Management**

Terraform tracks the current state of your infrastructure:

- **Drift Detection**: Knows when manual changes occur
- **Dependency Management**: Understands resource relationships
- **Incremental Changes**: Only modifies what needs to change

**5. Multi-Provider Support**

Manage resources across different providers in a single configuration:

.. code-block:: hcl

    # GCP resources
    resource "google_compute_instance" "app" {
      # ... configuration
    }
    
    # AWS resources for backup
    resource "aws_s3_bucket" "backup" {
      # ... configuration
    }
    
    # DNS from Cloudflare
    resource "cloudflare_record" "app" {
      # ... configuration
    }

======================
Learning Path Overview
======================

This Infrastructure as Code section is structured for progressive learning:

1. **Introduction** (This Chapter)
   
   - Understanding Terraform vs OpenTofu
   - Basic HCL syntax and concepts
   - Value proposition of IaC

2. **Core Concepts** (Chapter 10.2)
   
   - Providers and resources
   - Variables and outputs
   - Data sources and locals

3. **Terraform Workflow & GCP** (Chapter 10.3)
   
   - The terraform init/plan/apply cycle
   - GCP-specific considerations
   - Authentication and setup

4. **Production Challenges** (Chapter 10.4)
   
   - Common problems and solutions
   - State management issues
   - Security and compliance

5. **Practical Examples** (Chapter 10.5)
   
   - 14 hands-on GCP examples
   - From simple storage to Kubernetes
   - Real-world deployment patterns

.. note::

    Each chapter builds upon the previous one. It's recommended to work through them in order and complete the practical examples as you progress.
############################
10.2 Terraform Core Concepts
############################

This chapter covers the fundamental building blocks of Terraform configurations that you'll use in every project.

=======================
Terraform Core Concepts
=======================

**1. Providers**

Providers are plugins that enable Terraform to interact with cloud platforms, SaaS providers, and other APIs. Each provider adds a set of resource types and data sources.

.. code-block:: hcl

    # Google Cloud Provider (Primary focus)
    provider "google" {
      project = "my-gcp-project-id"
      region  = "us-central1"
      zone    = "us-central1-a"
    }
    
    # Multiple providers can be used together
    provider "aws" {
      region  = "us-west-2"
      profile = "default"
    }
    
    # Azure Provider
    provider "azurerm" {
      features {}
    }
    
    # Provider versioning for stability
    terraform {
      required_providers {
        google = {
          source  = "hashicorp/google"
          version = "~> 4.0"
        }
      }
    }

**2. Resources**

Resources are the most important element in Terraform. Each resource block describes one or more infrastructure objects, such as virtual networks, compute instances, or DNS records.

.. code-block:: hcl

    # GCP Cloud Storage bucket
    resource "google_storage_bucket" "data" {
      name     = "my-company-data-bucket"
      location = "US"
      
      versioning {
        enabled = true
      }
      
      encryption {
        default_kms_key_name = google_kms_crypto_key.bucket_key.id
      }
      
      uniform_bucket_level_access = true
      
      lifecycle {
        prevent_destroy = true  # Protect from accidental deletion
      }
      
      labels = {
        environment = "production"
        team        = "data-engineering"
      }
    }
    
    # GCP KMS key for bucket encryption
    resource "google_kms_crypto_key" "bucket_key" {
      name     = "bucket-encryption-key"
      key_ring = google_kms_key_ring.main.id
      
      purpose = "ENCRYPT_DECRYPT"
      
      lifecycle {
        prevent_destroy = true
      }
    }

**3. Data Sources**

Data sources allow Terraform to fetch information from existing infrastructure or external sources.

.. code-block:: hcl

    # Get the latest Ubuntu 22.04 LTS image
    data "google_compute_image" "ubuntu" {
      family  = "ubuntu-2204-lts"
      project = "ubuntu-os-cloud"
    }
    
    # Get information about available zones
    data "google_compute_zones" "available" {
      region = "us-central1"
      status = "UP"
    }
    
    # Get current project information
    data "google_project" "current" {}
    
    # Use the image in a compute instance
    resource "google_compute_instance" "web" {
      name         = "web-server"
      machine_type = "e2-micro"
      zone         = data.google_compute_zones.available.names[0]
      
      boot_disk {
        initialize_params {
          image = data.google_compute_image.ubuntu.self_link
        }
      }
      
      metadata = {
        project-id = data.google_project.current.project_id
      }
    }

**4. Variables**

Variables make your Terraform configurations flexible and reusable.

.. code-block:: text

    # variables.tf
    variable "environment" {
      description = "Environment name"
      type        = string
      default     = "development"
    }
    
    variable "instance_count" {
      description = "Number of instances to create"
      type        = number
      default     = 1
      
      validation {
        condition     = var.instance_count >= 1 && var.instance_count <= 10
        error_message = "Instance count must be between 1 and 10."
      }
    }
    
    variable "allowed_cidr_blocks" {
      description = "CIDR blocks allowed to access resources"
      type        = list(string)
      default     = ["0.0.0.0/0"]
    }
    
    variable "tags" {
      description = "Tags to apply to resources"
      type        = map(string)
      default     = {
        Project = "MyApp"
        Team    = "DevOps"
      }
    }

**Variable Types:**

.. code-block:: hcl

    # String variable
    variable "project_name" {
      type        = string
      description = "Name of the GCP project"
    }
    
    # Number variable
    variable "disk_size" {
      type        = number
      description = "Boot disk size in GB"
      default     = 20
    }
    
    # Boolean variable
    variable "enable_https" {
      type        = bool
      description = "Enable HTTPS load balancer"
      default     = true
    }
    
    # List variable
    variable "availability_zones" {
      type        = list(string)
      description = "List of availability zones"
      default     = ["us-central1-a", "us-central1-b"]
    }
    
    # Map variable
    variable "instance_types" {
      type = map(string)
      description = "Instance types per environment"
      default = {
        development = "e2-micro"
        staging     = "e2-small"
        production  = "e2-medium"
      }
    }
    
    # Object variable
    variable "database_config" {
      type = object({
        tier = string
        size = number
        backup_enabled = bool
      })
      description = "Database configuration"
      default = {
        tier           = "db-f1-micro"
        size           = 10
        backup_enabled = true
      }
    }

**Using Variables:**

.. code-block:: hcl

    # In terraform.tfvars file
    environment = "production"
    instance_count = 3
    project_name = "my-web-app"
    
    # In resource configuration
    resource "google_compute_instance" "app" {
      count        = var.instance_count
      name         = "${var.project_name}-${var.environment}-${count.index + 1}"
      machine_type = var.instance_types[var.environment]
      
      labels = {
        environment = var.environment
        project     = var.project_name
      }
    }

**5. Outputs**

Outputs display information about your infrastructure and can be used to pass data to other Terraform configurations.

.. code-block:: hcl

    # outputs.tf
    output "instance_public_ip" {
      description = "Public IP address of the web server"
      value       = google_compute_instance.web_server.network_interface[0].access_config[0].nat_ip
    }
    
    output "network_id" {
      description = "ID of the VPC network"
      value       = google_compute_network.main.id
    }
    
    output "database_connection_name" {
      description = "Cloud SQL instance connection name"
      value       = google_sql_database_instance.main.connection_name
      sensitive   = true  # Mark sensitive data
    }
    
    output "load_balancer_ip" {
      description = "External IP of the load balancer"
      value       = google_compute_global_address.lb_ip.address
    }

**Output Usage:**

.. code-block:: bash

    # View all outputs
    terraform output
    
    # Get specific output value
    terraform output instance_public_ip
    
    # Get output in JSON format
    terraform output -json
    
    # Use in scripts
    IP=$(terraform output -raw instance_public_ip)
    curl http://$IP

**6. Local Values**

Locals assign a name to an expression, making it easier to reuse values throughout your configuration.

.. code-block:: hcl

    locals {
      common_tags = {
        Environment = var.environment
        ManagedBy   = "Terraform"
        Project     = "WebApp"
      }
      
      name_prefix = "${var.environment}-webapp"
      
      instance_type = var.environment == "production" ? "e2-medium" : "e2-micro"
      
      # Complex expressions
      availability_zones = data.google_compute_zones.available.names
      
      # Conditional logic
      backup_retention = var.environment == "production" ? 30 : 7
    }
    
    resource "google_compute_instance" "app" {
      name         = "${local.name_prefix}-server"
      machine_type = local.instance_type
      zone         = local.availability_zones[0]
      
      boot_disk {
        initialize_params {
          image = data.google_compute_image.ubuntu.self_link
        }
      }
      
      network_interface {
        network = "default"
        access_config {}
      }
      
      labels = local.common_tags
      
      metadata = {
        Name = "${local.name_prefix}-server"
      }
    }

=================
Advanced Concepts
=================

**1. Resource Dependencies**

Terraform automatically handles dependencies through resource references:

.. code-block:: hcl

    # Implicit dependency - network referenced in instance
    resource "google_compute_network" "main" {
      name = "main-network"
    }
    
    resource "google_compute_instance" "app" {
      name = "app-server"
      
      network_interface {
        network = google_compute_network.main.id  # Creates dependency
      }
    }
    
    # Explicit dependency when reference isn't enough
    resource "google_compute_instance" "app" {
      depends_on = [
        google_compute_network.main,
        google_compute_firewall.allow_ssh
      ]
    }

**2. Count and For Each**

Create multiple similar resources:

.. code-block:: hcl

    # Using count
    resource "google_compute_instance" "web" {
      count = 3
      
      name = "web-server-${count.index + 1}"
      # ... other configuration
    }
    
    # Using for_each with list
    variable "instance_names" {
      default = ["web", "api", "database"]
    }
    
    resource "google_compute_instance" "servers" {
      for_each = toset(var.instance_names)
      
      name = "${each.value}-server"
      # ... other configuration
    }
    
    # Using for_each with map
    variable "environments" {
      default = {
        dev  = "e2-micro"
        prod = "e2-medium"
      }
    }
    
    resource "google_compute_instance" "env_servers" {
      for_each = var.environments
      
      name         = "${each.key}-server"
      machine_type = each.value
      # ... other configuration
    }

**3. Lifecycle Management**

Control resource behavior:

.. code-block:: hcl

    resource "google_storage_bucket" "important_data" {
      name = "critical-application-data"
      
      lifecycle {
        # Prevent accidental deletion
        prevent_destroy = true
        
        # Create new resource before destroying old one
        create_before_destroy = true
        
        # Ignore changes to specific attributes
        ignore_changes = [
          labels,
          versioning
        ]
      }
    }

**4. Conditional Resources**

Create resources based on conditions:

.. code-block:: hcl

    # Create load balancer only in production
    resource "google_compute_global_forwarding_rule" "lb" {
      count = var.environment == "production" ? 1 : 0
      
      name       = "production-lb"
      target     = google_compute_target_http_proxy.lb[0].id
      port_range = "80"
    }
    
    # Using for_each with conditional
    resource "google_compute_firewall" "conditional" {
      for_each = var.enable_monitoring ? toset(["http", "https"]) : toset([])
      
      name = "allow-${each.value}"
      # ... configuration
    }

=================
File Organization
=================

**Best Practices for Terraform File Structure:**

.. code-block:: bash

    terraform-project/
    ├── main.tf              # Primary resource definitions
    ├── variables.tf         # Input variable declarations
    ├── outputs.tf           # Output value declarations
    ├── terraform.tfvars     # Variable value assignments
    ├── versions.tf          # Provider version constraints
    ├── locals.tf            # Local value definitions
    └── modules/
        ├── networking/
        │   ├── main.tf
        │   ├── variables.tf
        │   └── outputs.tf
        └── compute/
            ├── main.tf
            ├── variables.tf
            └── outputs.tf

**Example File Contents:**

**versions.tf:**

.. code-block:: hcl

    terraform {
      required_version = ">= 1.0"
      
      required_providers {
        google = {
          source  = "hashicorp/google"
          version = "~> 4.0"
        }
      }
    }

**main.tf:**

.. code-block:: hcl

    provider "google" {
      project = var.project_id
      region  = var.region
    }
    
    # Resource definitions...

**variables.tf:**

.. code-block:: hcl

    variable "project_id" {
      description = "GCP project ID"
      type        = string
    }
    
    variable "region" {
      description = "GCP region"
      type        = string
      default     = "us-central1"
    }

**terraform.tfvars:**

.. code-block:: hcl

    project_id = "my-gcp-project"
    region     = "europe-west1"

.. note::

    Never commit `terraform.tfvars` files containing sensitive information to version control. Use `.tfvars.example` files as templates instead.
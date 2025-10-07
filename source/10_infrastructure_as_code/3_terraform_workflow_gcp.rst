#############################
10.3 Terraform Workflow & GCP
#############################

This chapter covers the Terraform workflow and Google Cloud Platform-specific considerations for real-world deployments.

======================
The Terraform Workflow
======================

Terraform follows a consistent workflow that makes infrastructure changes predictable and safe:

**1. Write**

Define your infrastructure in configuration files (.tf files).

**2. Initialize (terraform init)**

Download provider plugins and prepare the working directory.

.. code-block:: bash

    $ terraform init
    
    Initializing the backend...
    Initializing provider plugins...
    - Finding latest version of hashicorp/google...
    - Installing hashicorp/google v4.84.0...
    
    Terraform has been successfully initialized!

**3. Plan (terraform plan)**

Preview the changes Terraform will make to match your configuration.

.. code-block:: bash

    $ terraform plan
    
    Terraform will perform the following actions:
    
      # google_compute_instance.web_server will be created
      + resource "google_compute_instance" "web_server" {
          + name         = "web-server"
          + machine_type = "e2-micro"
          + zone         = "us-central1-a"
          + self_link    = (known after apply)
          ...
        }
    
    Plan: 1 to add, 0 to change, 0 to destroy.

**4. Apply (terraform apply)**

Execute the planned changes to create, update, or delete infrastructure.

.. code-block:: bash

    $ terraform apply
    
    Do you want to perform these actions?
      Terraform will perform the actions described above.
      Only 'yes' will be accepted to approve.
    
      Enter a value: yes
    
    google_compute_instance.web_server: Creating...
    google_compute_instance.web_server: Creation complete after 45s
    
    Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

**5. Destroy (terraform destroy)**

Remove all infrastructure managed by the configuration (use with caution).

.. code-block:: bash

    $ terraform destroy
    
    # Destroy specific resources
    $ terraform destroy -target=google_compute_instance.web_server

=====================================
GCP-Specific Terraform Considerations
=====================================

Google Cloud Platform has unique characteristics that affect how you use Terraform effectively.

**1. GCP Authentication and Setup**

.. code-block:: bash

    # Authenticate with Google Cloud
    gcloud auth login
    gcloud auth application-default login
    
    # Set default project
    gcloud config set project my-gcp-project-id
    
    # Enable required APIs (Terraform cannot enable these automatically)
    gcloud services enable compute.googleapis.com
    gcloud services enable storage.googleapis.com
    gcloud services enable container.googleapis.com

**2. Service Account Best Practices**

.. code-block:: hcl

    # Create a service account for Terraform
    resource "google_service_account" "terraform" {
      account_id   = "terraform-automation"
      display_name = "Terraform Service Account"
      description  = "Service account for Terraform infrastructure automation"
    }
    
    # Grant minimal required permissions
    resource "google_project_iam_member" "terraform_compute" {
      project = var.project_id
      role    = "roles/compute.instanceAdmin.v1"
      member  = "serviceAccount:${google_service_account.terraform.email}"
    }
    
    resource "google_project_iam_member" "terraform_storage" {
      project = var.project_id
      role    = "roles/storage.admin"
      member  = "serviceAccount:${google_service_account.terraform.email}"
    }

**Service Account Key Management:**

.. code-block:: bash

    # Create service account key
    gcloud iam service-accounts keys create terraform-key.json \
        --iam-account=terraform-automation@PROJECT_ID.iam.gserviceaccount.com
    
    # Set environment variable
    export GOOGLE_APPLICATION_CREDENTIALS="terraform-key.json"
    
    # Or use in provider block
    provider "google" {
      credentials = file("terraform-key.json")
      project     = "my-project-id"
      region      = "us-central1"
    }

**3. GCP Resource Naming and Organization**

.. code-block:: hcl

    # GCP has strict naming conventions
    locals {
      # Resource names must be lowercase, contain only letters, numbers, and hyphens
      resource_prefix = lower("${var.environment}-${var.project_name}")
      
      # GCP labels are different from AWS tags
      common_labels = {
        environment = var.environment
        project     = var.project_name
        managed_by  = "terraform"
        team        = var.team_name
      }
    }
    
    resource "google_compute_instance" "app" {
      name = "${local.resource_prefix}-app-server"
      
      # Use labels, not tags (AWS terminology)
      labels = local.common_labels
    }

**GCP Naming Rules:**

- **Lowercase only**: All GCP resource names must be lowercase
- **Length limits**: Most resources have 63-character limits
- **Valid characters**: Letters, numbers, hyphens (no underscores in names)
- **Start/end**: Must start and end with letter or number

**4. GCP-Specific State Backend Configuration**

.. code-block:: hcl

    # Create a GCS bucket for Terraform state
    resource "google_storage_bucket" "terraform_state" {
      name     = "my-terraform-state-bucket"
      location = "US"
      
      uniform_bucket_level_access = true
      
      versioning {
        enabled = true
      }
      
      lifecycle_rule {
        condition {
          age = 30
        }
        action {
          type = "Delete"
        }
      }
    }
    
    # Configure backend in separate configuration
    terraform {
      backend "gcs" {
        bucket = "my-terraform-state-bucket"
        prefix = "production"
      }
    }

**State Backend Security:**

.. code-block:: hcl

    # Secure state bucket
    resource "google_storage_bucket" "terraform_state" {
      name     = "${var.project_id}-terraform-state"
      location = "US"
      
      # Prevent public access
      uniform_bucket_level_access = true
      
      # Enable versioning for state history
      versioning {
        enabled = true
      }
      
      # Encrypt at rest
      encryption {
        default_kms_key_name = google_kms_crypto_key.terraform_state.id
      }
      
      # Lifecycle management
      lifecycle_rule {
        condition {
          age                   = 90
          matches_storage_class = ["COLDLINE"]
        }
        action {
          type = "Delete"
        }
      }
    }

**5. GCP Quota and API Limitations**

.. code-block:: bash

    # Check current quotas
    gcloud compute project-info describe --project=my-project
    
    # Request quota increases through Console
    # Plan for API rate limits in large deployments

**Handling Quotas in Terraform:**

.. code-block:: text

    # Use timeouts for slow operations
    resource "google_compute_instance" "app" {
      name         = "app-server"
      machine_type = "e2-micro"
      
      timeouts {
        create = "10m"
        update = "10m"
        delete = "10m"
      }
    }
    
    # Use depends_on to control resource creation order
    resource "google_compute_instance" "app" {
      count = var.instance_count
      
      depends_on = [
        google_compute_network.main,
        google_compute_subnetwork.public
      ]
      
      name = "app-server-${count.index + 1}"
      # Spread across zones to avoid single-zone limits
      zone = data.google_compute_zones.available.names[count.index % length(data.google_compute_zones.available.names)]
    }

**6. GCP Multi-Region Deployments**

.. code-block:: hcl

    # GCP regions and zones
    variable "regions" {
      description = "List of GCP regions for deployment"
      type        = list(string)
      default     = ["us-central1", "us-east1", "europe-west1"]
    }
    
    # Get available zones for each region
    data "google_compute_zones" "available" {
      for_each = toset(var.regions)
      
      region = each.key
      status = "UP"
    }
    
    # Deploy across multiple regions
    resource "google_compute_instance" "app" {
      for_each = toset(var.regions)
      
      name         = "app-server-${each.key}"
      machine_type = "e2-micro"
      zone         = data.google_compute_zones.available[each.key].names[0]
      
      boot_disk {
        initialize_params {
          image = data.google_compute_image.ubuntu.self_link
        }
      }
      
      network_interface {
        network = google_compute_network.main.id
        subnetwork = google_compute_subnetwork.regional[each.key].id
        
        access_config {
          # Ephemeral public IP
        }
      }
      
      labels = {
        region = each.key
        app    = "web-server"
      }
    }

============================
Advanced Terraform Workflows
============================

**1. Environment Management**

.. code-block:: bash

    # Directory structure for environments
    environments/
    ├── dev/
    │   ├── main.tf
    │   ├── terraform.tfvars
    │   └── backend.tf
    ├── staging/
    │   ├── main.tf
    │   ├── terraform.tfvars
    │   └── backend.tf
    └── production/
        ├── main.tf
        ├── terraform.tfvars
        └── backend.tf

**Environment-Specific Configuration:**

.. code-block:: hcl

    # environments/production/terraform.tfvars
    environment     = "production"
    instance_type   = "e2-medium"
    min_replicas    = 3
    max_replicas    = 10
    enable_backup   = true
    backup_schedule = "0 2 * * *"
    
    # environments/dev/terraform.tfvars  
    environment     = "development"
    instance_type   = "e2-micro"
    min_replicas    = 1
    max_replicas    = 2
    enable_backup   = false

**2. Terraform Workspaces**

.. code-block:: bash

    # Create and switch to workspace
    terraform workspace new production
    terraform workspace new staging
    terraform workspace new development
    
    # List workspaces
    terraform workspace list
    
    # Switch workspace
    terraform workspace select production
    
    # Use workspace in configuration
    locals {
      environment = terraform.workspace
      instance_count = terraform.workspace == "production" ? 3 : 1
    }

**3. State Management Strategies**

**Remote State Sharing:**

.. code-block:: text

    # In networking project
    output "vpc_id" {
      value = google_compute_network.main.id
    }
    
    output "subnet_ids" {
      value = {
        for subnet in google_compute_subnetwork.subnets :
        subnet.name => subnet.id
      }
    }
    
    # In application project
    data "terraform_remote_state" "networking" {
      backend = "gcs"
      config = {
        bucket = "company-terraform-state"
        prefix = "networking"
      }
    }
    
    resource "google_compute_instance" "app" {
      network    = data.terraform_remote_state.networking.outputs.vpc_id
      subnetwork = data.terraform_remote_state.networking.outputs.subnet_ids["public"]
    }

**4. Module Development**

.. code-block:: text

    # modules/gcp-web-server/main.tf
    resource "google_compute_instance" "web" {
      name         = var.instance_name
      machine_type = var.machine_type
      zone         = var.zone
      
      boot_disk {
        initialize_params {
          image = var.boot_disk_image
          size  = var.boot_disk_size
        }
      }
      
      network_interface {
        network = var.network
        subnetwork = var.subnetwork
        
        dynamic "access_config" {
          for_each = var.assign_public_ip ? [1] : []
          content {
            # Ephemeral public IP
          }
        }
      }
      
      metadata_startup_script = var.startup_script
      
      labels = var.labels
      tags   = var.network_tags
    }
    
    # Using the module
    module "web_servers" {
      source = "./modules/gcp-web-server"
      
      instance_name     = "web-server"
      machine_type      = "e2-micro"
      zone              = "us-central1-a"
      network           = google_compute_network.main.id
      subnetwork        = google_compute_subnetwork.public.id
      assign_public_ip  = true
      startup_script    = file("${path.module}/scripts/install-nginx.sh")
      
      labels = {
        environment = var.environment
        component   = "web-server"
      }
      
      network_tags = ["web-server", "http-allowed"]
    }

**5. CI/CD Integration**

**GitHub Actions Example:**

.. code-block:: yaml

    # .github/workflows/terraform.yml
    name: 'Terraform'
    
    on:
      push:
        branches: [ main ]
        paths: ['infrastructure/**']
      pull_request:
        branches: [ main ]
        paths: ['infrastructure/**']
    
    env:
      TF_VAR_project_id: ${{ secrets.GCP_PROJECT_ID }}
    
    jobs:
      terraform:
        name: 'Terraform'
        runs-on: ubuntu-latest
        
        defaults:
          run:
            shell: bash
            working-directory: ./infrastructure
        
        steps:
        - name: Checkout
          uses: actions/checkout@v3
        
        - name: Setup Terraform
          uses: hashicorp/setup-terraform@v2
          with:
            terraform_version: 1.5.0
        
        - name: Authenticate to Google Cloud
          uses: google-github-actions/auth@v1
          with:
            credentials_json: ${{ secrets.GCP_SA_KEY }}
        
        - name: Terraform Format
          run: terraform fmt -check
        
        - name: Terraform Init
          run: terraform init
        
        - name: Terraform Validate
          run: terraform validate
        
        - name: Terraform Plan
          run: terraform plan -no-color
          if: github.event_name == 'pull_request'
        
        - name: Terraform Apply
          run: terraform apply -auto-approve
          if: github.ref == 'refs/heads/main'

========================
Terraform Best Practices
========================

**1. State File Security**

.. code-block:: bash

    # Never commit state files
    echo "*.tfstate" >> .gitignore
    echo "*.tfstate.*" >> .gitignore
    echo ".terraform/" >> .gitignore
    echo "terraform.tfvars" >> .gitignore

**2. Resource Tagging/Labeling**

.. code-block:: hcl

    locals {
      common_labels = {
        environment = var.environment
        project     = var.project_name
        managed_by  = "terraform"
        team        = var.team_name
        cost_center = var.cost_center
        created_by  = "terraform"
        created_on  = formatdate("YYYY-MM-DD", timestamp())
      }
    }
    
    # Apply to all resources
    resource "google_compute_instance" "app" {
      labels = merge(
        local.common_labels,
        {
          component = "application-server"
          tier      = "web"
        }
      )
    }

**3. Security Practices**

.. code-block:: hcl

    # Use Google Secret Manager for sensitive data
    resource "google_secret_manager_secret" "db_password" {
      secret_id = "database-password"
      
      replication {
        automatic = true
      }
    }
    
    resource "google_secret_manager_secret_version" "db_password" {
      secret      = google_secret_manager_secret.db_password.id
      secret_data = var.db_password
    }
    
    # Reference secrets in resources
    resource "google_sql_database_instance" "main" {
      settings {
        user_labels = {
          password_secret = google_secret_manager_secret.db_password.secret_id
        }
      }
    }

**4. Error Handling and Validation**

.. code-block:: text

    variable "environment" {
      description = "Environment name"
      type        = string
      
      validation {
        condition     = contains(["dev", "staging", "production"], var.environment)
        error_message = "Environment must be one of: dev, staging, production."
      }
    }
    
    variable "instance_count" {
      description = "Number of instances"
      type        = number
      
      validation {
        condition     = var.instance_count >= 1 && var.instance_count <= 10
        error_message = "Instance count must be between 1 and 10."
      }
    }

.. note::

    Always run `terraform plan` before `terraform apply` to review changes. Use `terraform validate` and `terraform fmt` to catch errors early and maintain consistent formatting.
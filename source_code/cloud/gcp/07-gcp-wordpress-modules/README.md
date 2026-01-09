# GCP Compute WordPress with Modules

This example demonstrates using Terraform modules to create a modular, reusable WordPress deployment on Google Cloud Platform.

## Module Architecture

The infrastructure is organized into three modules:

```
modules/
├── networking/          # VPC and subnet management
├── firewall/           # Security rules management  
└── compute-instance/   # VM and application deployment
```

### Benefits of Modular Architecture

- **Reusability**: Modules can be used across different environments
- **Maintainability**: Each module has a single responsibility
- **Testing**: Modules can be tested independently
- **Collaboration**: Teams can work on different modules
- **Versioning**: Modules can be versioned separately

## Prerequisites

1. Install [Terraform](https://www.terraform.io/downloads.html)
2. Install [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
3. Authenticate with GCP: `gcloud auth application-default login`
4. Create a GCP project and note the project ID

## Module Details

### Networking Module (`modules/networking/`)

**Purpose**: Creates VPC network and subnet

**Resources**:
- `google_compute_network`: VPC network
- `google_compute_subnetwork`: Subnet with custom CIDR

**Inputs**:
- `environment`: Environment name for naming
- `project_name`: Project name for naming
- `region`: GCP region
- `subnet_cidr`: CIDR block for subnet

**Outputs**:
- `network_name`: Name of the created network
- `subnet_name`: Name of the created subnet

### Firewall Module (`modules/firewall/`)

**Purpose**: Manages security rules for the network

**Resources**:
- `google_compute_firewall`: HTTP access rule
- `google_compute_firewall`: SSH access rule

**Inputs**:
- `environment`: Environment name for naming
- `network_name`: Target network for rules
- `allowed_cidr_blocks`: IPs allowed for HTTP
- `ssh_allowed_cidr_blocks`: IPs allowed for SSH

**Outputs**:
- `firewall_rules`: List of created firewall rules

### Compute Instance Module (`modules/compute-instance/`)

**Purpose**: Creates and configures the WordPress instance

**Resources**:
- `tls_private_key`: SSH key generation
- `google_compute_instance`: VM with WordPress

**Inputs**:
- Instance configuration (machine type, image, disk size)
- Network configuration (network name, subnet name)
- Database configuration (credentials and settings)

**Outputs**:
- `instance_ip`: External IP address
- `wordpress_url`: WordPress site URL
- `ssh_command`: SSH connection command

## Deployment Steps

### Using terraform.tfvars

```bash
# Update terraform.tfvars with your project ID
vim terraform.tfvars

# Deploy
terraform init
terraform plan
terraform apply

# Save SSH key
terraform output -raw private_key > dev-wordpress-modules-key.pem && chmod 400 dev-wordpress-modules-key.pem
```

### Using environment variables

```bash
export TF_VAR_gcp_project="your-project-id"
export TF_VAR_environment="staging"

terraform apply
```

## Multiple Environments with Modules

### Directory Structure for Multiple Environments

```
environments/
├── dev/
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars
├── staging/
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars
└── prod/
    ├── main.tf
    ├── variables.tf
    └── terraform.tfvars

modules/              # Shared modules
├── networking/
├── firewall/
└── compute-instance/
```

### Environment-specific Configuration

**Development** (`environments/dev/terraform.tfvars`):
```hcl
gcp_project = "my-project-dev"
environment = "dev"
machine_type = "e2-micro"
disk_size = 15
allowed_cidr_blocks = ["0.0.0.0/0"]
```

**Production** (`environments/prod/terraform.tfvars`):
```hcl
gcp_project = "my-project-prod"
environment = "prod"
machine_type = "e2-standard-2"
disk_size = 50
allowed_cidr_blocks = ["10.0.0.0/8"]  # Restricted
```

## Module Versioning

### Using Git Tags for Module Versions

```hcl
module "networking" {
  source = "git::https://github.com/your-org/terraform-gcp-modules.git//networking?ref=v1.0.0"
  
  environment = var.environment
  region      = var.gcp_region
}
```

### Using Terraform Registry

```hcl
module "networking" {
  source  = "your-org/networking/gcp"
  version = "~> 1.0"
  
  environment = var.environment
  region      = var.gcp_region
}
```

## Testing Modules

### Unit Testing with Terratest

```go
func TestNetworkingModule(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "./modules/networking",
        Vars: map[string]interface{}{
            "environment": "test",
            "region": "us-central1",
        },
    }
    
    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)
    
    networkName := terraform.Output(t, terraformOptions, "network_name")
    assert.Contains(t, networkName, "test")
}
```

### Integration Testing

```bash
# Test all modules together
cd environments/test
terraform init
terraform plan
terraform apply
terraform destroy
```

## Module Best Practices

### 1. Module Structure

```
module/
├── main.tf          # Main resources
├── variables.tf     # Input variables
├── outputs.tf       # Output values
├── versions.tf      # Provider versions
└── README.md        # Module documentation
```

### 2. Variable Validation

```hcl
variable "machine_type" {
  type = string
  validation {
    condition = contains(["e2-micro", "e2-small", "e2-medium"], var.machine_type)
    error_message = "Invalid machine type."
  }
}
```

### 3. Output Documentation

```hcl
output "network_name" {
  description = "Name of the VPC network created by this module"
  value       = google_compute_network.vpc_network.name
}
```

## Access your WordPress site

```bash
# Get outputs
terraform output wordpress_url
terraform output network_info

# SSH access
terraform output ssh_command
```

## Troubleshooting

### Module-specific Issues

```bash
# Test individual modules
cd modules/networking
terraform init
terraform plan -var="environment=test" -var="region=us-central1"

# Check module dependencies
terraform graph
```

### Debug Module Communication

```bash
# Show all outputs
terraform output

# Show specific module output
terraform output network_info
```

## Clean up

```bash
terraform destroy
```

## Advanced Module Features

### Conditional Resources

```hcl
resource "google_compute_firewall" "https" {
  count = var.enable_https ? 1 : 0
  # ... configuration
}
```

### Dynamic Blocks

```hcl
dynamic "allow" {
  for_each = var.allowed_protocols
  content {
    protocol = allow.value.protocol
    ports    = allow.value.ports
  }
}
```

### Module Composition

```hcl
module "wordpress_stack" {
  source = "./modules/wordpress-stack"
  
  # This module internally uses networking, firewall, and compute modules
  gcp_project = var.gcp_project
  environment = var.environment
}
```
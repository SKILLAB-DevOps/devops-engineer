terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
  zone    = var.gcp_zone
}

# Networking module
module "networking" {
  source = "./modules/networking"

  environment   = var.environment
  project_name  = var.project_name
  region        = var.gcp_region
  subnet_cidr   = var.subnet_cidr
}

# Firewall module
module "firewall" {
  source = "./modules/firewall"

  environment               = var.environment
  network_name             = module.networking.network_name
  allowed_cidr_blocks      = var.allowed_cidr_blocks
  ssh_allowed_cidr_blocks  = var.ssh_allowed_cidr_blocks
}

# Compute instance module
module "compute_instance" {
  source = "./modules/compute-instance"

  environment     = var.environment
  project_name    = var.project_name 
  machine_type    = var.machine_type
  zone           = var.gcp_zone
  image_family   = var.image_family
  disk_size      = var.disk_size
  network_name   = module.networking.network_name
  subnet_name    = module.networking.subnet_name
  
  # Database configuration
  db_name          = var.db_name
  db_user          = var.db_user
  db_password      = var.db_password
  db_root_password = var.db_root_password
}

output "instance_ip" {
  value = module.compute_instance.instance_ip
}

output "private_key" {
  value     = module.compute_instance.private_key
  sensitive = true
}

output "wordpress_url" {
  value = module.compute_instance.wordpress_url
}

output "ssh_command" {
  value = module.compute_instance.ssh_command
}

output "network_info" {
  value = {
    network_name    = module.networking.network_name
    subnet_name     = module.networking.subnet_name
    firewall_rules  = module.firewall.firewall_rules
  }
}
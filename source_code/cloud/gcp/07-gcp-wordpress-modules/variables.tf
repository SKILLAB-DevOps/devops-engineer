# Required variables
variable "gcp_project" {
  description = "The GCP project ID to deploy to"
  type        = string
}

# Optional variables with defaults
variable "gcp_region" {
  description = "The GCP region to deploy to"
  type        = string
  default     = "europe-west1"
}

variable "gcp_zone" {
  description = "The GCP zone to deploy to"
  type        = string
  default     = "europe-west1-b"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for labeling resources"
  type        = string
  default     = "wordpress-modules"
}

variable "machine_type" {
  description = "GCP machine type for the instance"
  type        = string
  default     = "e2-medium"
}

variable "image_family" {
  description = "The image family for the instance"
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2204-lts"
}

variable "disk_size" {
  description = "Boot disk size in GB"
  type        = number
  default     = 20
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access HTTP"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ssh_allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# Database configuration
variable "db_name" {
  description = "WordPress database name"
  type        = string
  default     = "wordpress"
}

variable "db_user" {
  description = "WordPress database user"
  type        = string
  default     = "wordpressuser"
}

variable "db_password" {
  description = "WordPress database password"
  type        = string
  default     = "wordpresspassword"
  sensitive   = true
}

variable "db_root_password" {
  description = "MySQL root password"
  type        = string
  default     = "rootpassword"
  sensitive   = true
}
variable "gcp_project" {
  description = "Your GCP project ID"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "machine_type" {
  description = "VM size"
  type        = string
  default     = "e2-medium"
}

variable "db_password" {
  description = "Database password"
  type        = string
  default     = "mypassword123"
  sensitive   = true
}
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "machine_type" {
  description = "GCP machine type for the instance"
  type        = string
}

variable "zone" {
  description = "GCP zone to deploy to"
  type        = string
}

variable "image_family" {
  description = "The image family for the instance"
  type        = string
}

variable "disk_size" {
  description = "Boot disk size in GB"
  type        = number
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
}

variable "db_name" {
  description = "WordPress database name"
  type        = string
}

variable "db_user" {
  description = "WordPress database user"
  type        = string
}

variable "db_password" {
  description = "WordPress database password"
  type        = string
  sensitive   = true
}

variable "db_root_password" {
  description = "MySQL root password"
  type        = string
  sensitive   = true
}
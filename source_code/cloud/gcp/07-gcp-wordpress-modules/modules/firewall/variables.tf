variable "environment" {
  description = "Environment name"
  type        = string
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access HTTP"
  type        = list(string)
}

variable "ssh_allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access SSH"
  type        = list(string)
}
# GCP Project (required)
gcp_project = "your-project-id"

# Infrastructure settings
gcp_region   = "europe-west1"
gcp_zone     = "europe-west1-b"
environment  = "dev"
project_name = "wordpress-modules"

# Instance configuration
machine_type = "e2-medium"
disk_size    = 25

# Network configuration
subnet_cidr             = "10.0.1.0/24"
allowed_cidr_blocks     = ["0.0.0.0/0"]
ssh_allowed_cidr_blocks = ["0.0.0.0/0"]  # Restrict this in production

# Database configuration
db_name          = "wordpress"
db_user          = "wordpressuser"
db_password      = "secure_wordpress_password_123"
db_root_password = "secure_root_password_123"
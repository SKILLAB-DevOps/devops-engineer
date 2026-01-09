terraform {
  # Store state in Google Cloud Storage (uncomment after creating bucket)
  # backend "gcs" {
  #   bucket = "my-terraform-state-bucket-12345"
  #   prefix = "terraform/state"
  # }
}

provider "google" {
  project = "your-project-id"  # Replace with your GCP project ID
  region  = "us-central1"
}

# Create a bucket for storing Terraform state
resource "google_storage_bucket" "terraform_state" {
  name          = "my-terraform-state-bucket-12345"  # Must be globally unique
  location      = "US"
  force_destroy = true

  versioning {
    enabled = true
  }
}

# Allow HTTP traffic
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http-state"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

# WordPress instance
resource "google_compute_instance" "wordpress" {
  name         = "wordpress-with-state"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = file("${path.module}/install_wordpress.sh")

  tags = ["http-server"]
}

output "wordpress_url" {
  value = "http://${google_compute_instance.wordpress.network_interface[0].access_config[0].nat_ip}"
}

output "state_bucket" {
  value = google_storage_bucket.terraform_state.name
}
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = "your-project-id"  # Replace with your project ID
  region  = "us-central1"
}

# Firewall rule for Fullstack App (Frontend: 80, Backend: 8000, DB: 5432)
resource "google_compute_firewall" "fullstack_app" {
  name    = "fullstack-app-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "8000", "5432"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["fullstack-app"]
}

# VM for Fullstack Application
resource "google_compute_instance" "fullstack_app" {
  name         = "fullstack-app-vm"
  machine_type = "e2-medium"  # Increased for Docker containers
  zone         = "us-central1-a"
  tags         = ["fullstack-app"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 30  # Increased disk for Docker images
    }
  }

  network_interface {
    network = "default"
    access_config {
      # Ephemeral public IP
    }
  }

  metadata = {
    startup-script = file("${path.module}/startup.sh")
  }
}

# Outputs
output "vm_external_ip" {
  value = google_compute_instance.fullstack_app.network_interface[0].access_config[0].nat_ip
}

output "frontend_url" {
  value = "http://${google_compute_instance.fullstack_app.network_interface[0].access_config[0].nat_ip}"
}

output "backend_api_url" {
  value = "http://${google_compute_instance.fullstack_app.network_interface[0].access_config[0].nat_ip}:8000"
}

output "backend_users_api" {
  value = "http://${google_compute_instance.fullstack_app.network_interface[0].access_config[0].nat_ip}:8000/users"
}

output "database_connection" {
  value = "${google_compute_instance.fullstack_app.network_interface[0].access_config[0].nat_ip}:5432"
}
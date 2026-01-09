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

# Firewall rule for Python Dashboard (port 5000)
resource "google_compute_firewall" "python_dashboard" {
  name    = "python-dashboard-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["5000"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["python-dashboard"]
}

# VM for Python Dashboard
resource "google_compute_instance" "python_dashboard" {
  name         = "python-dashboard-vm"
  machine_type = "e2-medium"  # Increased for PostgreSQL + Flask
  zone         = "us-central1-a"
  tags         = ["python-dashboard"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 30  # Increased disk for PostgreSQL
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

  # Copy application files
  provisioner "file" {
    source      = "app-files/"
    destination = "/tmp/app-files/"
    
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.network_interface[0].access_config[0].nat_ip
    }
  }
}

# Outputs
output "vm_external_ip" {
  value = google_compute_instance.python_dashboard.network_interface[0].access_config[0].nat_ip
}

output "dashboard_url" {
  value = "http://${google_compute_instance.python_dashboard.network_interface[0].access_config[0].nat_ip}:5000"
}

output "api_url" {
  value = "http://${google_compute_instance.python_dashboard.network_interface[0].access_config[0].nat_ip}:5000/api"
}

output "admin_url" {
  value = "http://${google_compute_instance.python_dashboard.network_interface[0].access_config[0].nat_ip}:5000/admin"
}
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

# Firewall rule for Django E-commerce API (port 8000)
resource "google_compute_firewall" "django_ecommerce" {
  name    = "django-ecommerce-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8000"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["django-ecommerce"]
}

# VM for Django E-commerce
resource "google_compute_instance" "django_ecommerce" {
  name         = "django-ecommerce-vm"
  machine_type = "e2-medium"
  zone         = "us-central1-a"
  tags         = ["django-ecommerce"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 25
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
  value = google_compute_instance.django_ecommerce.network_interface[0].access_config[0].nat_ip
}

output "api_url" {
  value = "http://${google_compute_instance.django_ecommerce.network_interface[0].access_config[0].nat_ip}:8000"
}

output "admin_url" {
  value = "http://${google_compute_instance.django_ecommerce.network_interface[0].access_config[0].nat_ip}:8000/admin"
}

output "products_api" {
  value = "http://${google_compute_instance.django_ecommerce.network_interface[0].access_config[0].nat_ip}:8000/api/products/"
}

output "swagger_docs" {
  value = "http://${google_compute_instance.django_ecommerce.network_interface[0].access_config[0].nat_ip}:8000/swagger/"
}
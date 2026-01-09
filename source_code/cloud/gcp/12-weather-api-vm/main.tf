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

# Firewall rule for FastAPI
resource "google_compute_firewall" "weather_api" {
  name    = "weather-api-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8000"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["weather-api"]
}

# VM for Weather API
resource "google_compute_instance" "weather_api" {
  name         = "weather-api-vm"
  machine_type = "e2-small"
  zone         = "us-central1-a"
  tags         = ["weather-api"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 20
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

  metadata_startup_script = file("${path.module}/app-files/main.py")

  # Copy application files
  provisioner "file" {
    source      = "app-files/"
    destination = "/tmp/"
    
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.network_interface[0].access_config[0].nat_ip
    }
  }
}

# Outputs
output "vm_external_ip" {
  value = google_compute_instance.weather_api.network_interface[0].access_config[0].nat_ip
}

output "api_url" {
  value = "http://${google_compute_instance.weather_api.network_interface[0].access_config[0].nat_ip}:8000"
}

output "health_check_url" {
  value = "http://${google_compute_instance.weather_api.network_interface[0].access_config[0].nat_ip}:8000/health"
}

output "weather_example_url" {
  value = "http://${google_compute_instance.weather_api.network_interface[0].access_config[0].nat_ip}:8000/weather/London"
}
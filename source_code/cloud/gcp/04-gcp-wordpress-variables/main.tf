provider "google" {
  project = var.gcp_project
  region  = "us-central1"
}

# Firewall rule
resource "google_compute_firewall" "allow_http" {
  name    = "${var.environment}-allow-http"
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
  name         = "${var.environment}-wordpress"
  machine_type = var.machine_type
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

  metadata = {
    db-password = var.db_password
  }

  metadata_startup_script = file("${path.module}/install_wordpress.sh")

  tags = ["http-server"]
}

output "wordpress_url" {
  value = "http://${google_compute_instance.wordpress.network_interface[0].access_config[0].nat_ip}"
}

output "environment" {
  value = var.environment
}
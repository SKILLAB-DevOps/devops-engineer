provider "google" {
  project = "your-project-id"  # Replace with your GCP project ID
  region  = "us-central1"
}

# Reserve a static IP
resource "google_compute_address" "wordpress_ip" {
  name = "wordpress-static-ip"
}

# Allow HTTP and HTTPS traffic
resource "google_compute_firewall" "allow_web" {
  name    = "allow-web-https"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
}

# WordPress instance with static IP
resource "google_compute_instance" "wordpress" {
  name         = "wordpress-https"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.wordpress_ip.address
    }
  }

  metadata_startup_script = file("${path.module}/install_wordpress.sh")

  tags = ["web-server"]
}

output "static_ip" {
  value = google_compute_address.wordpress_ip.address
}

output "wordpress_url_http" {
  value = "http://${google_compute_address.wordpress_ip.address}"
}

output "wordpress_url_https" {
  value = "https://${google_compute_address.wordpress_ip.address}"
}
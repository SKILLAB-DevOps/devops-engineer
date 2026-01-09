provider "google" {
  project = "your-project-id"  # Replace with your GCP project ID
  region  = "us-central1"
  zone    = "us-central1-a"
}

# Firewall rule to allow HTTP traffic
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http-wordpress"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]  # Open to the world
  target_tags   = ["http-server"]
}

# Firewall rule to allow SSH access for debugging
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh-wordpress"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]  # For learning; restrict to your IP in production
  target_tags   = ["http-server"]
}

# Create WordPress instance
resource "google_compute_instance" "wordpress" {
  name         = "wordpress-instance"
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
      # Get a public IP
    }
  }

  metadata_startup_script = file("${path.module}/install_wordpress.sh")

  tags = ["http-server"]
}

output "instance_ip" {
  value       = google_compute_instance.wordpress.network_interface[0].access_config[0].nat_ip
  description = "Public IP address of the WordPress instance"
}

output "wordpress_url" {
  value       = "http://${google_compute_instance.wordpress.network_interface[0].access_config[0].nat_ip}"
  description = "URL to access your WordPress site"
}

output "ssh_command" {
  value       = "gcloud compute ssh ${google_compute_instance.wordpress.name} --zone=${google_compute_instance.wordpress.zone}"
  description = "Command to SSH into the instance"
}
provider "google" {
  project = "your-project-id"  # Replace with your GCP project ID
  region  = "us-central1"
  zone    = "us-central1-a"
}

# Create a simple VPC network (let GCP create subnets automatically)
resource "google_compute_network" "vpc_network" {
  name = "hello-world-network"
}

# Allow HTTP traffic
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]  # Open to everyone for demo
  target_tags   = ["http-server"]
}

# Create the compute instance
resource "google_compute_instance" "hello_world" {
  name         = "hello-world-instance"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
      # Get a public IP
    }
  }

  metadata_startup_script = file("${path.module}/install_apache.sh")

  tags = ["http-server"]
}

output "instance_ip" {
  value = google_compute_instance.hello_world.network_interface[0].access_config[0].nat_ip
}

output "website_url" {
  value = "http://${google_compute_instance.hello_world.network_interface[0].access_config[0].nat_ip}"
}
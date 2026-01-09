provider "google" {
  project = "your-project-id"  # Replace with your GCP project ID
  region  = "us-central1"
}

# Create Container-Optimized OS instance
resource "google_compute_instance" "container_vm" {
  name         = "container-vm"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"  # Container-Optimized OS
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    # Run Docker containers on startup
    user-data = file("${path.module}/docker-compose.yml")
  }

  metadata_startup_script = file("${path.module}/setup_containers.sh")

  tags = ["http-server"]

  service_account {
    scopes = ["cloud-platform"]
  }
}

# Allow HTTP traffic
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http-containers"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

output "container_vm_ip" {
  value = google_compute_instance.container_vm.network_interface[0].access_config[0].nat_ip
}

output "web_app_url" {
  value = "http://${google_compute_instance.container_vm.network_interface[0].access_config[0].nat_ip}"
}

output "api_url" {
  value = "http://${google_compute_instance.container_vm.network_interface[0].access_config[0].nat_ip}:8080"
}
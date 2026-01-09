provider "google" {
  project = "your-project-id"  # Replace with your GCP project ID
  region  = "us-central1"
}

# Create multiple web server instances
resource "google_compute_instance" "web_server" {
  count        = 2
  name         = "web-server-${count.index + 1}"
  machine_type = "e2-micro"
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
    server-id = count.index + 1
  }

  metadata_startup_script = file("${path.module}/install_webserver.sh")

  tags = ["http-server"]
}

# Health check for load balancer
resource "google_compute_http_health_check" "web_health_check" {
  name = "web-health-check"
  port = 80
  request_path = "/"
}

# Target pool for load balancer
resource "google_compute_target_pool" "web_target_pool" {
  name = "web-target-pool"
  
  instances = [
    for instance in google_compute_instance.web_server : 
    "${instance.zone}/${instance.name}"
  ]

  health_checks = [
    google_compute_http_health_check.web_health_check.name
  ]
}

# Forwarding rule (load balancer)
resource "google_compute_forwarding_rule" "web_forwarding_rule" {
  name       = "web-forwarding-rule"
  target     = google_compute_target_pool.web_target_pool.self_link
  port_range = "80"
}

# Allow HTTP traffic
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http-lb"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

output "load_balancer_ip" {
  value = google_compute_forwarding_rule.web_forwarding_rule.ip_address
}

output "web_servers" {
  value = [
    for instance in google_compute_instance.web_server :
    "http://${instance.network_interface[0].access_config[0].nat_ip}"
  ]
}
provider "google" {
  project = "your-project-id"  # Replace with your GCP project ID
  region  = "us-central1"
}

# Create instance template
resource "google_compute_instance_template" "web_template" {
  name         = "web-server-template"
  machine_type = "e2-micro"
  
  disk {
    source_image = "ubuntu-os-cloud/ubuntu-2204-lts"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = file("${path.module}/install_webserver.sh")

  tags = ["http-server"]
}

# Create managed instance group (auto scaling group)
resource "google_compute_instance_group_manager" "web_group" {
  name               = "web-server-group"
  base_instance_name = "web-server"
  zone               = "us-central1-a"
  target_size        = 2

  version {
    instance_template = google_compute_instance_template.web_template.id
  }

  named_port {
    name = "http"
    port = 80
  }
}

# Auto scaler
resource "google_compute_autoscaler" "web_autoscaler" {
  name   = "web-autoscaler"
  zone   = "us-central1-a"
  target = google_compute_instance_group_manager.web_group.id

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 2
    cooldown_period = 60

    cpu_utilization {
      target = 0.6  # Scale up when CPU > 60%
    }
  }
}

# Health check
resource "google_compute_http_health_check" "web_health_check" {
  name         = "web-health-check-as"
  port         = 80
  request_path = "/"
}

# Backend service
resource "google_compute_backend_service" "web_backend" {
  name        = "web-backend-service"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10

  backend {
    group = google_compute_instance_group_manager.web_group.instance_group
  }

  health_checks = [google_compute_http_health_check.web_health_check.id]
}

# URL map
resource "google_compute_url_map" "web_url_map" {
  name            = "web-url-map"
  default_service = google_compute_backend_service.web_backend.id
}

# HTTP proxy
resource "google_compute_target_http_proxy" "web_proxy" {
  name    = "web-proxy"
  url_map = google_compute_url_map.web_url_map.id
}

# Global forwarding rule
resource "google_compute_global_forwarding_rule" "web_forwarding_rule" {
  name       = "web-forwarding-rule-global"
  target     = google_compute_target_http_proxy.web_proxy.id
  port_range = "80"
}

# Firewall rule
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http-as"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

output "load_balancer_ip" {
  value = google_compute_global_forwarding_rule.web_forwarding_rule.ip_address
}

output "scaling_info" {
  value = "Auto scaling: 2-5 instances based on CPU usage (>60%)"
}
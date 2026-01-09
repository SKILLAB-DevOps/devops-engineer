# Create firewall rule for HTTP
resource "google_compute_firewall" "allow_http" {
  name    = "${var.environment}-allow-http"
  network = var.network_name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = var.allowed_cidr_blocks
  target_tags   = ["http-server"]
}

# Create firewall rule for SSH
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.environment}-allow-ssh"
  network = var.network_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.ssh_allowed_cidr_blocks
  target_tags   = ["ssh-server"]
}
# Create a VPC network
resource "google_compute_network" "vpc_network" {
  name                    = "${var.environment}-${var.project_name}-network"
  auto_create_subnetworks = false
}

# Create a subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.environment}-${var.project_name}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc_network.id
}
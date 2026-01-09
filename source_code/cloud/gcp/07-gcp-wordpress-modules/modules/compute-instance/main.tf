# Generate SSH key pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Create the compute instance for WordPress
resource "google_compute_instance" "wordpress" {
  name         = "${var.environment}-${var.project_name}-instance"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image_family
      size  = var.disk_size
    }
  }

  network_interface {
    network    = var.network_name
    subnetwork = var.subnet_name
    access_config {
      # Ephemeral public IP
    }
  }

  metadata = {
    ssh-keys         = "ubuntu:${tls_private_key.ssh_key.public_key_openssh}"
    db-name          = var.db_name
    db-user          = var.db_user
    db-password      = var.db_password
    db-root-password = var.db_root_password
  }

  metadata_startup_script = file("${path.module}/install_wordpress.sh")

  tags = ["http-server", "ssh-server"]

  labels = {
    environment = var.environment
    project     = var.project_name
  }
}
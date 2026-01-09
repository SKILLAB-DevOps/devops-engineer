provider "google" {
  project = "your-gcp-project-id"
  region  = "us-central1"
  zone    = "us-central1-a"
}


resource "google_compute_firewall" "allow-fastapi" {
  name    = "allow-fastapi"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8000"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "vm_instance" {
  name         = "devops-01"
  machine_type = "e2-medium"
  boot_disk {
    auto_delete = true

    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20251002"
      size  = 10
      type  = "pd-balanced"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = file("${path.module}/startup-script.sh")
}

output "vm_instance_ip" {
  value       = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
  description = "The public IP address of the VM instance"
}

output "ssh_command" {
  value       = "gcloud compute ssh ${google_compute_instance.vm_instance.name} --zone ${google_compute_instance.vm_instance.zone}"
  description = "Command to SSH into the VM instance"
}
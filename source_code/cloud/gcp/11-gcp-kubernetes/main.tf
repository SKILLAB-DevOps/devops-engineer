terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = "your-project-id"  # Replace with your project ID
  region  = "us-central1"
}

# GKE Cluster (Kubernetes)
resource "google_container_cluster" "primary" {
  name     = "learning-cluster"
  location = "us-central1-a"

  # Start with single node for learning
  initial_node_count = 1
  
  # Enable basic features
  network    = "default"
  subnetwork = "default"

  # Node configuration
  node_config {
    machine_type = "e2-small"
    disk_size_gb = 20
    
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  # Enable network policy
  network_policy {
    enabled = true
  }

  # Disable legacy ABAC
  enable_legacy_abac = false
}

# Outputs
output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "cluster_location" {
  value = google_container_cluster.primary.location
}

output "connect_command" {
  value = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --zone=${google_container_cluster.primary.location}"
}
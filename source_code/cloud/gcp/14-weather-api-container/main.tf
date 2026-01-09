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

# Enable required APIs
resource "google_project_service" "container_api" {
  service = "container.googleapis.com"
}

resource "google_project_service" "cloud_build_api" {
  service = "cloudbuild.googleapis.com"
}

# GKE Cluster
resource "google_container_cluster" "weather_cluster" {
  name     = "weather-api-cluster"
  location = "us-central1-a"

  initial_node_count = 2

  network    = "default"
  subnetwork = "default"

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

  depends_on = [google_project_service.container_api]
}

# Get current project info
data "google_project" "current" {}

# Outputs
output "cluster_name" {
  value = google_container_cluster.weather_cluster.name
}

output "cluster_location" {
  value = google_container_cluster.weather_cluster.location
}

output "connect_command" {
  value = "gcloud container clusters get-credentials ${google_container_cluster.weather_cluster.name} --zone=${google_container_cluster.weather_cluster.location}"
}

output "build_command" {
  value = "gcloud builds submit --tag gcr.io/${data.google_project.current.project_id}/weather-api:latest"
}
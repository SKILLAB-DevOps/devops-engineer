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
resource "google_project_service" "cloud_run_api" {
  service = "run.googleapis.com"
}

resource "google_project_service" "cloud_build_api" {
  service = "cloudbuild.googleapis.com"
}

# Cloud Run service
resource "google_cloud_run_service" "weather_api" {
  name     = "weather-api"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "gcr.io/${data.google_project.current.project_id}/weather-api:latest"
        
        ports {
          container_port = 8000
        }

        env {
          name  = "PORT"
          value = "8000"
        }

        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
      }

      # Allow up to 100 concurrent requests per instance
      container_concurrency = 100
      
      # Timeout after 5 minutes
      timeout_seconds = 300
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = "10"
        "autoscaling.knative.dev/minScale" = "0"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [google_project_service.cloud_run_api]
}

# Make the service publicly accessible
resource "google_cloud_run_service_iam_member" "public_access" {
  service  = google_cloud_run_service.weather_api.name
  location = google_cloud_run_service.weather_api.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Get current project info
data "google_project" "current" {}

# Outputs
output "service_url" {
  value = google_cloud_run_service.weather_api.status[0].url
}

output "health_check_url" {
  value = "${google_cloud_run_service.weather_api.status[0].url}/health"
}

output "weather_example_url" {
  value = "${google_cloud_run_service.weather_api.status[0].url}/weather/London"
}

output "build_command" {
  value = "gcloud builds submit --tag gcr.io/${data.google_project.current.project_id}/weather-api:latest"
}
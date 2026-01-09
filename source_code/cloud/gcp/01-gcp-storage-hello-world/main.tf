provider "google" {
  project = "your-project-id"  # Replace with your GCP project ID
  region  = "us-central1"
}

# Create a Cloud Storage bucket for website hosting
resource "google_storage_bucket" "website_bucket" {
  name          = "my-hello-world-website-bucket-12345"  # Must be globally unique
  location      = "US"
  force_destroy = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "error.html"
  }

  uniform_bucket_level_access = false
}

# Upload index.html
resource "google_storage_bucket_object" "index_html" {
  name   = "index.html"
  bucket = google_storage_bucket.website_bucket.name
  source = "index.html"
  content_type = "text/html"
}

# Upload error.html
resource "google_storage_bucket_object" "error_html" {
  name   = "error.html"
  bucket = google_storage_bucket.website_bucket.name
  source = "error.html"
  content_type = "text/html"
}

# Make the bucket objects publicly readable
resource "google_storage_bucket_iam_member" "public_read" {
  bucket = google_storage_bucket.website_bucket.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

output "website_url" {
  value = "http://storage.googleapis.com/${google_storage_bucket.website_bucket.name}/index.html"
}
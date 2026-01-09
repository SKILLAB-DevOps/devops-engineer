variable "aws_region" {
  description = "The AWS region to deploy to"
  default     = "eu-central-1"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "my_website_bucket" {
  bucket = "my-hello-world-website-unique-name"
  
}

resource "aws_s3_bucket_website_configuration" "my_website" {
  bucket = aws_s3_bucket.my_website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.my_website_bucket.id
  key          = "index.html"
  source       = "index.html"
  content_type = "text/html"
  # Removed acl = "public-read" due to BucketOwnerEnforced settings
}

resource "aws_s3_object" "error_html" {
  bucket       = aws_s3_bucket.my_website_bucket.id
  key          = "error.html"
  source       = "error.html"
  content_type = "text/html"
  # Removed acl = "public-read" due to BucketOwnerEnforced settings
}

resource "aws_s3_bucket_public_access_block" "my_website_access_block" {
  bucket = aws_s3_bucket.my_website_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "my_website_policy" {
  bucket = aws_s3_bucket.my_website_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.my_website_bucket.arn}/*"
      },
    ]
  })
}

output "website_url" {
  value = "http://${aws_s3_bucket.my_website_bucket.bucket}.s3-website-${var.aws_region}.amazonaws.com"
}
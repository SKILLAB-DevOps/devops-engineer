output "instance_ip" {
  description = "External IP address of the instance"
  value       = google_compute_instance.wordpress.network_interface[0].access_config[0].nat_ip
}

output "instance_name" {
  description = "Name of the instance"
  value       = google_compute_instance.wordpress.name
}

output "private_key" {
  description = "Private SSH key"
  value       = tls_private_key.ssh_key.private_key_pem
  sensitive   = true
}

output "public_key" {
  description = "Public SSH key"
  value       = tls_private_key.ssh_key.public_key_openssh
}

output "wordpress_url" {
  description = "URL to access WordPress"
  value       = "http://${google_compute_instance.wordpress.network_interface[0].access_config[0].nat_ip}"
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ${var.environment}-${var.project_name}-key.pem ubuntu@${google_compute_instance.wordpress.network_interface[0].access_config[0].nat_ip}"
}
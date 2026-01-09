output "http_firewall_rule" {
  description = "Name of the HTTP firewall rule"
  value       = google_compute_firewall.allow_http.name
}

output "ssh_firewall_rule" {
  description = "Name of the SSH firewall rule"
  value       = google_compute_firewall.allow_ssh.name
}

output "firewall_rules" {
  description = "List of all firewall rules created"
  value = [
    google_compute_firewall.allow_http.name,
    google_compute_firewall.allow_ssh.name
  ]
}
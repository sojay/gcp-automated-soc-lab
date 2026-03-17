output "network_name" {
  description = "Name of the created VPC network."
  value       = google_compute_network.main.name
}

output "network_self_link" {
  description = "Self link of the VPC network."
  value       = google_compute_network.main.self_link
}

output "public_honeypot_subnet_name" {
  description = "Name of the public honeypot subnet."
  value       = google_compute_subnetwork.public_honeypot.name
}

output "tools_subnet_name" {
  description = "Name of the tools subnet."
  value       = google_compute_subnetwork.tools.name
}

output "cowrie_target_tags" {
  description = "Network tags that should be attached to the Cowrie VM."
  value       = var.cowrie_target_tags
}

output "cowrie_admin_target_tags" {
  description = "Network tags that should be attached to expose admin SSH on port 2022."
  value       = var.cowrie_admin_target_tags
}

output "cowrie_instance_template_self_link" {
  description = "Self link for the Cowrie instance template."
  value       = google_compute_instance_template.cowrie.self_link
}

output "cowrie_vm_name" {
  description = "Name of the Cowrie VM when create_cowrie_vm is enabled."
  value       = try(google_compute_instance_from_template.cowrie[0].name, null)
}

output "logging_vm_name" {
  description = "Name of the logging VM when create_logging_vm is enabled."
  value       = try(google_compute_instance.logging[0].name, null)
}

output "logging_vm_internal_ip" {
  description = "Internal IP of the logging VM when create_logging_vm is enabled."
  value       = try(google_compute_instance.logging[0].network_interface[0].network_ip, null)
}

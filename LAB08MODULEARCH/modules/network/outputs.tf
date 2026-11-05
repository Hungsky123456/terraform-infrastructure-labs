
output "network_info" {
  description = "Network configuration for other modules"
  value       = terraform_data.network_config.output
}

output "network_id" {
  description = "Simulated Network resource ID"
  value       = terraform_data.network_config.id
}


output "server_info" {
  description = "Server configuration for Application Module"
  value       = terraform_data.server_config.output
}

output "server_id" {
  description = "Simulated server resource ID"
  value       = terraform_data.server_config.id
}

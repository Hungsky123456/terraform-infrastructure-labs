
output "application_info" {
  description = "Application deployment configuration"
  value       = terraform_data.application_config.output
}

output "application_id" {
  description = "Simulated application resource ID"
  value       = terraform_data.application_config.id
}

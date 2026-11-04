output "created_file" {
  description = "Duong dan file server duoc tao"
  value       = local_file.server_config.filename
}

output "server_name" {
  description = "Ten server"
  value       = var.server_name
}
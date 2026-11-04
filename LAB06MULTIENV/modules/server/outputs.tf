
output "created_file" {
  description = "Duong dan file cau hinh server"
  value       = local_file.server_config.filename
}

output "server_name" {
  description = "Ten server da trien khai"
  value       = var.server_name
}

output "environment" {
  description = "Moi truong cua server"
  value       = var.environment
}

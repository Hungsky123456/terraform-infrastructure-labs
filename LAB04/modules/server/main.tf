
resource "local_file" "server_config" {
  filename = "${path.root}/server-${var.server_name}.txt"

  content = <<-EOT
    Server Name: ${var.server_name}
    CPU: ${var.server_cpu} vCPU
    RAM: ${var.server_ram} MB
    Environment: ${var.environment}
  EOT
}

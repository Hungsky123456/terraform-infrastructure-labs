
resource "terraform_data" "server_config" {
  input = {
    name    = var.server_name
    cpu     = var.server_cpu
    ram     = var.server_ram
    network = var.network_info
  }
}

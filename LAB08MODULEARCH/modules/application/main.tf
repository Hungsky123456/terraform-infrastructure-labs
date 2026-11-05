
resource "terraform_data" "application_config" {
  input = {
    name        = var.application_name
    port        = var.application_port
    server_name = var.server_info.name
    network     = var.server_info.network.name
  }
}

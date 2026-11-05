
resource "terraform_data" "network_config" {
  input = {
    name        = var.network_name
    subnet_cidr = var.subnet_cidr
    gateway_ip  = var.gateway_ip
  }
}

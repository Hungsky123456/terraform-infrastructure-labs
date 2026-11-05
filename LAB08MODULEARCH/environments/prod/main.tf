
terraform {
  required_version = ">= 1.5.0"
}

# Network Module
module "network" {
  source = "../../modules/network"

  network_name = "prod-network"
  subnet_cidr  = "192.168.70.0/24"
  gateway_ip   = "192.168.70.1"
}

# Server Module
module "server" {
  source   = "../../modules/server"
  for_each = var.servers

  server_name  = each.value.name
  server_cpu   = local.server_profiles[each.value.profile].cpu
  server_ram   = local.server_profiles[each.value.profile].ram
  network_info = module.network.network_info
}

# Application Module
module "application" {
  source = "../../modules/application"

  application_name = "nginx-web-prod"
  application_port = 8080

  server_info = module.server["prod01"].server_info
}

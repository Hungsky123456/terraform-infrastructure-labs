
terraform {
  required_version = ">= 1.5.0"
}

# 1. Network Module
module "network" {
  source = "../../modules/network"

  network_name = "dev-network"
  subnet_cidr  = "192.168.50.0/24"
  gateway_ip   = "192.168.50.1"
}

# 2. Server Module - for_each
module "server" {
  source   = "../../modules/server"
  for_each = var.servers

  server_name = each.value.name

  server_cpu = local.server_profiles[each.value.profile].cpu
  server_ram = local.server_profiles[each.value.profile].ram

  network_info = module.network.network_info
}

# 3. Application Module
module "application" {
  source = "../../modules/application"

  application_name = "nginx-web"
  application_port = 8080

  server_info = module.server["dev01"].server_info
}

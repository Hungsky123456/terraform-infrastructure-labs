
terraform {
  required_version = ">= 1.5.0"
}

module "network" {
  source = "../../modules/network"

  network_name = "test-network"
  subnet_cidr  = "192.168.60.0/24"
  gateway_ip   = "192.168.60.1"
}

module "server" {
  source   = "../../modules/server"
  for_each = var.servers

  server_name  = each.value.name
  server_cpu   = local.server_profiles[each.value.profile].cpu
  server_ram   = local.server_profiles[each.value.profile].ram
  network_info = module.network.network_info
}

module "application" {
  source = "../../modules/application"

  application_name = "nginx-web-test"
  application_port = 8080

  server_info = module.server["test01"].server_info
}

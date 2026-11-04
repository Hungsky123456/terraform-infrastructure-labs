
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

provider "local" {}


module "servers" {
  source   = "./modules/server"
  for_each = local.servers

  server_name = each.value.server_name

  server_cpu = local.env_defaults[each.value.env].server_cpu

  server_ram = local.env_defaults[each.value.env].server_ram

  environment = local.env_defaults[each.value.env].environment
}

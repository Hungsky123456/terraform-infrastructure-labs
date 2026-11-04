
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
  source   = "../../../modules/server"
  for_each = var.servers

  server_name = each.value.name

  server_cpu = local.profiles[each.value.profile].cpu
  server_ram = local.profiles[each.value.profile].ram

  environment = local.environment
}

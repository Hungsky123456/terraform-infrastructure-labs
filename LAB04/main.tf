
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

module "dev_server" {
  source = "./modules/server"

  server_name = "ubuntu-dev-01"
  server_cpu  = 1
  server_ram  = 2048
  environment = "Development"
}


module "test_server" {
  source = "./modules/server"

  server_name = "ubuntu-test-01"
  server_cpu  = 2
  server_ram  = 4096
  environment = "Testing"
}

module "prod_server" {
  source = "./modules/server"

  server_name = "ubuntu-prod-01"
  server_cpu  = 4
  server_ram  = 8192
  environment = "Production"
}
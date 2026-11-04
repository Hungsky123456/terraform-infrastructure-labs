
terraform {
  required_version = ">= 1.5.0"

  backend "local" {}

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

provider "local" {}

resource "local_file" "server_config" {
  filename = "${path.module}/server-${var.environment}.txt"

  content = <<-EOT
    Server Name: ${var.server_name}
    CPU: ${var.server_cpu} vCPU
    RAM: ${var.server_ram} MB
    Environment: ${var.environment}
  EOT
}

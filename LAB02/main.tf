
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

resource "local_file" "server_info" {
  filename = "${path.module}/server-info.txt"

  content = <<-EOT
    Server Name: ubuntu-lab-01
    Operating System: Ubuntu Server
    CPU: 2 vCPU
    RAM: 8192 MB
    Environment: Home Lab
  EOT
}

output "created_file" {
  value = local_file.server_info.filename
}

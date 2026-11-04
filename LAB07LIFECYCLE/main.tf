
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

resource "local_file" "server_config" {
  filename = "${path.module}/server-lifecycle.txt"

  content = <<-EOT
    Server Name: ubuntu-lifecycle-01
    CPU: 2 vCPU
    RAM: 8192 MB
    Environment: Development
  EOT
}

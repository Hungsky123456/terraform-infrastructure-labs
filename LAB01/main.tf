
# LAB 01 - Terraform Fundamentals

terraform {
  required_version = ">= 1.5.0"
}

variable "server_name" {
  description = "Ten server Ubuntu"
  type        = string
  default     = "ubuntu-lab-01"
}

variable "server_ram" {
  description = "RAM tinh bang MB"
  type        = number
  default     = 4096
}

output "server_info" {
  value = "Server: ${var.server_name} | RAM: ${var.server_ram} MB"
}

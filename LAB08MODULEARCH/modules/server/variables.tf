
variable "server_name" {
  description = "Server name"
  type        = string
}

variable "server_cpu" {
  description = "Number of vCPUs"
  type        = number
}

variable "server_ram" {
  description = "RAM in MB"
  type        = number
}

variable "network_info" {
  description = "Network configuration received from Network Module"

  type = object({
    name        = string
    subnet_cidr = string
    gateway_ip  = string
  })
}


variable "network_name" {
  description = "Network name"
  type        = string
}

variable "subnet_cidr" {
  description = "Network CIDR"
  type        = string

  validation {
    condition     = can(cidrhost(var.subnet_cidr, 1))
    error_message = "subnet_cidr must be a valid CIDR."
  }
}

variable "gateway_ip" {
  description = "Gateway IP address"
  type        = string
}

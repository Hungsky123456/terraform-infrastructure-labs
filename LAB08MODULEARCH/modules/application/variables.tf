
variable "application_name" {
  description = "Application name"
  type        = string
}

variable "application_port" {
  description = "Application listening port"
  type        = number

  validation {
    condition     = var.application_port >= 1 && var.application_port <= 65535
    error_message = "Application port must be between 1 and 65535."
  }
}

variable "server_info" {
  description = "Server configuration received from Server Module"

  type = object({
    name    = string
    cpu     = number
    ram     = number
    network = object({
      name        = string
      subnet_cidr = string
      gateway_ip  = string
    })
  })
}

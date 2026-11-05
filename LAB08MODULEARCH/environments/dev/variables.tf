
variable "servers" {
  description = "DEV server inventory"

  type = map(object({
    name    = string
    profile = string
  }))

  validation {
    condition = alltrue([
      for key, server in var.servers :
      contains(["standard", "database", "monitoring"], server.profile)
    ])

    error_message = "Server profile must be standard, database, or monitoring."
  }
}

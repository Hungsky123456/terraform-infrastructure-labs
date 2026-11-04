
variable "servers" {
  description = "Danh sach server thuoc moi truong TEST"

  type = map(object({
    name    = string
    profile = optional(string, "standard")
  }))

  validation {
    condition = alltrue([
      for key, server in var.servers :
      contains(["standard", "database", "monitoring"], server.profile)
    ])

    error_message = "Profile khong hop le. Chi cho phep: standard, database, monitoring."
  }
}

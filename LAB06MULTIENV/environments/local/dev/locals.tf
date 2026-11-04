
locals {
  environment = "Development"

  profiles = {
    standard = {
      cpu = 1
      ram = 2048
    }

    database = {
      cpu = 4
      ram = 8192
    }

    monitoring = {
      cpu = 2
      ram = 4096
    }
  }
}

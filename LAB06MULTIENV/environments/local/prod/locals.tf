
locals {
  environment = "Production"

  profiles = {
    standard = {
      cpu = 4
      ram = 8192
    }

    database = {
      cpu = 8
      ram = 16384
    }

    monitoring = {
      cpu = 2
      ram = 4096
    }
  }
}

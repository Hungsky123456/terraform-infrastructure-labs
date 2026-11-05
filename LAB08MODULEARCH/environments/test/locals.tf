
locals {
  server_profiles = {
    standard = {
      cpu = 2
      ram = 6144
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

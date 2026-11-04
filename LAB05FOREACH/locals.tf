
locals {
  # Cau hinh mac dinh theo moi truong
  env_defaults = {
    dev = {
      server_cpu  = 1
      server_ram  = 2048
      environment = "Development"
    }

    test = {
      server_cpu  = 2
      server_ram  = 4096
      environment = "Testing"
    }

    prod = {
      server_cpu  = 4
      server_ram  = 8192
      environment = "Production"
    }
  }

  # Chuyen Inventory theo nhom thanh map server
  servers = merge([
    for env, instances in var.server_groups : {
      for key, name in instances :
      key => {
        server_name = name
        env         = env
      }
    }
  ]...)
}

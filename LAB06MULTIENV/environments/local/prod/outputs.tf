
output "server_details" {
  description = "Thong tin server da trien khai trong PROD"

  value = {
    for key, server in module.servers :
    key => {
      server_name  = server.server_name
      environment  = server.environment
      created_file = server.created_file
    }
  }
}

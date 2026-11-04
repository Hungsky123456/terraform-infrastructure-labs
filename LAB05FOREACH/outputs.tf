
output "server_files" {
  description = "Danh sach file cau hinh server"

  value = {
    for key, server in module.servers :
    key => server.created_file
  }
}

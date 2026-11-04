
output "dev_server_name" {
  value = module.dev_server.server_name
}

output "dev_created_file" {
  value = module.dev_server.created_file
}


output "test_server_name" {
  value = module.test_server.server_name
}

output "test_created_file" {
  value = module.test_server.created_file
}

output "prod_server_name" {
  value = module.prod_server.server_name
}

output "prod_created_file" {
  value = module.prod_server.created_file
}
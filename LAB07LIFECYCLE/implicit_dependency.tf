
# Resource 1 - Database Setup
resource "terraform_data" "database_setup" {
  input = "database-ready"
}

# Resource 2 - Backend Service
resource "terraform_data" "backend_service" {
  input = "backend-requires-${terraform_data.database_setup.output}"
}

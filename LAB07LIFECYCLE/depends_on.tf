
# Resource 1 - Network Setup
resource "terraform_data" "network_setup" {
  input = "network-configured"
}

# Resource 2 - Application Deployment
resource "terraform_data" "application_deploy" {
  input = "application-deployed"

  depends_on = [
    terraform_data.network_setup
  ]
}

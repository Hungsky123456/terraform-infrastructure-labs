
resource "terraform_data" "app_settings" {
  input = {
    application = "nginx-web"
    log_level   = "DEBUG"
  }
}


resource "terraform_data" "deployment" {
  input            = "release-v2"
  triggers_replace = "release-v2"

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = true
  }
}

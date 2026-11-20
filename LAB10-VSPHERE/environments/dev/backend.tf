terraform {
  backend "s3" {
    bucket = "terraform-state"
    key    = "lab10/dev/terraform.tfstate"
    region = "us-east-1"

    endpoints = {
      s3 = "https://192.168.232.177:9000"
    }

    use_path_style              = true
    use_lockfile                = true
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
  }
}
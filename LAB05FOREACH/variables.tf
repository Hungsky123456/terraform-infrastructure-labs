
variable "server_groups" {
  description = "Danh sach server phan theo moi truong DEV, TEST, PROD"

  type = map(map(string))
}

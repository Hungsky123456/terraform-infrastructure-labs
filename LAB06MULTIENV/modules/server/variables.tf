
variable "server_name" {
  description = "Ten server can trien khai"
  type        = string
}

variable "server_cpu" {
  description = "So luong vCPU"
  type        = number
}

variable "server_ram" {
  description = "Dung luong RAM (MB)"
  type        = number
}

variable "environment" {
  description = "Moi truong DEV, TEST hoac PROD"
  type        = string
}

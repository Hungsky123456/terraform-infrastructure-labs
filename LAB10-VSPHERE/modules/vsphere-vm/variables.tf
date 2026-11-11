
variable "vm_name" {
  description = "Ten VM trong vSphere"
  type        = string
}

variable "num_cpus" {
  description = "So luong vCPU"
  type        = number
}

variable "memory" {
  description = "RAM tinh bang MB"
  type        = number
}

variable "disk_size" {
  description = "Dung luong disk tinh bang GB"
  type        = number
}

variable "resource_pool_id" {
  description = "vSphere Resource Pool ID"
  type        = string
}

variable "datastore_id" {
  description = "vSphere Datastore ID"
  type        = string
}

variable "network_id" {
  description = "vSphere Network ID"
  type        = string
}

variable "template_uuid" {
  description = "UUID cua Golden Template"
  type        = string
}

variable "guest_id" {
  description = "Guest OS ID"
  type        = string
}

variable "scsi_type" {
  description = "SCSI Controller Type"
  type        = string
}

variable "adapter_type" {
  description = "Network Adapter Type"
  type        = string
}

variable "domain" {
  description = "Linux DNS Domain"
  type        = string
  default     = "lab.local"
}

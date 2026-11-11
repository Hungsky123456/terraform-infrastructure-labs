
terraform {
  required_version = ">= 1.17.0"

  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = "~> 2.15"
    }
  }
}

variable "vsphere_user" {
  type = string
}

variable "vsphere_password" {
  type      = string
  sensitive = true
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = "192.168.174.152"
  allow_unverified_ssl = true
}

# Datacenter
data "vsphere_datacenter" "dc" {
  name = "DC-LAB10"
}

# Datastore
data "vsphere_datastore" "datastore" {
  name          = "datastore1"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# ESXi Host
data "vsphere_host" "esxi" {
  name          = "192.168.174.151"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Golden Template
data "vsphere_virtual_machine" "golden_v2" {
  name          = "ubuntu-golden-v2"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Network
data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Outputs
output "template_id" {
  value = data.vsphere_virtual_machine.golden_v2.id
}

output "esxi_host_id" {
  value = data.vsphere_host.esxi.id
}

# PROD Environment
locals {
  vm_configs = {
    prod = {
      name     = "ubuntu-prod"
      num_cpus = 2
      memory   = 2048
    }
  }
}
# Shared vSphere VM Module
module "vm" {
  source   = "../../modules/vsphere-vm"
  for_each = local.vm_configs

  vm_name  = each.value.name
  num_cpus = each.value.num_cpus
  memory   = each.value.memory

  disk_size = data.vsphere_virtual_machine.golden_v2.disks[0].size

  resource_pool_id = data.vsphere_host.esxi.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  network_id       = data.vsphere_network.network.id

  template_uuid = data.vsphere_virtual_machine.golden_v2.id
  guest_id      = data.vsphere_virtual_machine.golden_v2.guest_id
  scsi_type     = data.vsphere_virtual_machine.golden_v2.scsi_type
  adapter_type  = data.vsphere_virtual_machine.golden_v2.network_interface_types[0]

  domain = "lab.local"
}

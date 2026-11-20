
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

data "vsphere_datacenter" "dc" {
  name = "DC-LAB10"
}

data "vsphere_datastore" "datastore" {
  name          = "datastore1"
  datacenter_id = data.vsphere_datacenter.dc.id
}


data "vsphere_host" "esxi" {
  name          = "192.168.174.151"
  datacenter_id = data.vsphere_datacenter.dc.id
}

output "template_id" {
  value = data.vsphere_virtual_machine.golden_v2.id
}

data "vsphere_virtual_machine" "golden_v2" {
  name          = "ubuntu-golden-v2"
  datacenter_id = data.vsphere_datacenter.dc.id
}

output "esxi_host_id" {
  value = data.vsphere_host.esxi.id
}


data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "dev" {
  name             = "ubuntu-dev"
  resource_pool_id = data.vsphere_host.esxi.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  firmware = "efi"

  num_cpus = 1
  memory   = 1024

  guest_id  = "ubuntu64Guest"
  scsi_type = "pvscsi"

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = "vmxnet3"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [clone]
  }

  disk {
    label            = "disk0"
    size             = 25
    thin_provisioned = false
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.golden_v2.id
  }
}


resource "vsphere_virtual_machine" "this" {
  name             = var.vm_name
  resource_pool_id = var.resource_pool_id
  datastore_id     = var.datastore_id

  firmware = "efi"

  num_cpus = var.num_cpus
  memory   = var.memory

  guest_id  = var.guest_id
  scsi_type = var.scsi_type

  network_interface {
    network_id   = var.network_id
    adapter_type = var.adapter_type
  }

  disk {
    label            = "disk0"
    size             = var.disk_size
    thin_provisioned = false
  }

  clone {
    template_uuid = var.template_uuid

    customize {
      linux_options {
        host_name = var.vm_name
        domain    = var.domain
      }

      network_interface {
        ipv4_address = ""
      }

      ipv4_gateway = ""
    }
  }
}

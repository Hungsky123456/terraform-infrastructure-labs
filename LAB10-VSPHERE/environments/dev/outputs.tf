output "ansible_inventory" {
  description = "DEV virtual machine information for Ansible automation"

  value = {
    environment = "dev"
    hostname    = vsphere_virtual_machine.dev.name
    ip_address  = vsphere_virtual_machine.dev.default_ip_address
    vm_uuid     = vsphere_virtual_machine.dev.id
  }
}

output "vm_id" {
  description = "UUID cua VM tren vSphere"
  value       = vsphere_virtual_machine.this.id
}

output "vm_name" {
  description = "Ten VM"
  value       = vsphere_virtual_machine.this.name
}

output "vm_ip" {
  description = "Dia chi IP cua VM"
  value       = vsphere_virtual_machine.this.default_ip_address
}

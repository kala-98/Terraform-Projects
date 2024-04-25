output "tls_private_key_vm1" {
  value     = tls_private_key.example_ssh_vm1.private_key_pem
  sensitive = true
}

output "tls_private_key_vm2" {
  value     = tls_private_key.example_ssh_vm2.private_key_pem
  sensitive = true
}

output "public_ip_addresses" {
  value = [
    for vm in azurerm_linux_virtual_machine.vmLinux: vm.public_ip_address
  ]
}
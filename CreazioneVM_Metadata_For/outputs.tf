output "tls_private_key_vm1" {
  value     = module.vm.tls_private_key_vm1
  sensitive = true
}

output "tls_private_key_vm2" {
  value     = module.vm.tls_private_key_vm2
  sensitive = true
}

# output "public_ip_address_linux" {
#   value = module.vm.public_ip_address_linux
# }

output "public_ip_addresses" {
 # value = module.vm.public_ip_addresses
  value = [
    for vm in module.vm.public_ip_addresses : vm
    ]
}

output "lista_ip_pubblici" {
  value = module.rete.public_ip_addresses
}
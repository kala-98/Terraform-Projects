output "subnet_id" {
  value = azurerm_subnet.subnet.id
}
output "nsg_id" {
  value = azurerm_network_security_group.nsg.id
}
# output "public_ip_id" {
#   value = azurerm_public_ip.example.id
# }

output "public_ip_addresses" {
  value = [ for ip in azurerm_public_ip.example : ip.id]
  # {
  #   for key, public_ip in azurerm_public_ip.example :
  #   key => public_ip.id
  # }
}

# output "public_ip_vm1" {
#   value = azurerm_public_ip.example["vm1"].ip_address
# }

# output "public_ip_vm2" {
#   value = azurerm_public_ip.example["vm2"].ip_address
# }
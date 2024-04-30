output "private_ip_address_server_1" {
  value = azurerm_network_interface.dc01_nic.private_ip_address
}

output "private_ip_address_client_1" {
  value = azurerm_network_interface.client01_nic.private_ip_address
}

output "private_ip_address_server_2" {
  value = azurerm_network_interface.dc02_nic.private_ip_address
}

output "private_ip_address_server_3" {
  value = azurerm_network_interface.dc03_nic.private_ip_address
}

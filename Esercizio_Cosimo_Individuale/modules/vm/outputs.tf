output "private_ip_address_server" {
  value = azurerm_network_interface.dc01_nic.private_ip_address
}

output "private_ip_address_client" {
  value = azurerm_network_interface.client01_nic.private_ip_address
}


output "private_ip_address_server_thirdvnet" {
  value = azurerm_network_interface.dc03_nic.private_ip_address
}


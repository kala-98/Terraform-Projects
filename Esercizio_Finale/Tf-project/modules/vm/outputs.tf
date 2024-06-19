output "private_ip_address_server_1_vnet1" {
  value = azurerm_network_interface.dc01_nic.private_ip_address
}

output "user_server_1_vnet1" {
  value = azurerm_windows_virtual_machine.dc01.admin_username
}

output "private_ip_address_client_1_vnet1" {
  value = azurerm_network_interface.client01_nic.private_ip_address
}

output "user_client_1_vnet1" {
  value = azurerm_windows_virtual_machine.client01.admin_username
}

output "private_ip_address_server_2_vnet2" {
  value = azurerm_network_interface.dc02_nic.private_ip_address
}

output "user_server_2_vnet2" {
  value = azurerm_windows_virtual_machine.dc02.admin_username
}

output "private_ip_address_server_3_vnet2" {
  value = azurerm_network_interface.dc03_nic.private_ip_address
}

output "user_server_3_vnet2" {
  value = azurerm_windows_virtual_machine.dc03.admin_username
}


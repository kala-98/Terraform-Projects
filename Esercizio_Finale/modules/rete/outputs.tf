
output "firstvnet" {
  value = azurerm_virtual_network.firstvnet.name
}

output "secondvnet" {
  value = azurerm_virtual_network.secondvnet.name
}

output "firstvnetsub1" {
  value = azurerm_subnet.firstvnetsub1.name
}

output "secondvnetsub1" {
  value = azurerm_subnet.secondvnetsub1.name
}

output "vpngateway" {
    value = azurerm_virtual_network_gateway.vpngateway.name
}
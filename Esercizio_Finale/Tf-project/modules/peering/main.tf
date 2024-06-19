

data "azurerm_virtual_network" "vpeeringvnet01" {
  name = var.first_vnet
  resource_group_name = var.rg_name
}
data "azurerm_virtual_network" "vpeeringvnet02" {
  name = var.second_vnet
  resource_group_name = var.rg_name
}

data "azurerm_virtual_network_gateway" "vpngateway" {
  name = var.vpngateway
  resource_group_name = var.rg_name
}

###############################################################################################

# Peering VNet01 to VNet02
resource "azurerm_virtual_network_peering" "vnet01-vnet02-peer" {
    name                      = "vnet01tovnet02"
    resource_group_name       = var.rg_name
    virtual_network_name      = var.first_vnet
    remote_virtual_network_id = data.azurerm_virtual_network.vpeeringvnet02.id

    allow_virtual_network_access = true
    allow_forwarded_traffic = true
    allow_gateway_transit   = true
    use_remote_gateways     = false
    depends_on = [data.azurerm_virtual_network.vpeeringvnet01, data.azurerm_virtual_network.vpeeringvnet02, data.azurerm_virtual_network_gateway.vpngateway]
}
# Peering VNet02 to VNet01
resource "azurerm_virtual_network_peering" "vnet02-vnet01-peer" {
    name                      = "vnet02tovnet01"
    resource_group_name       = var.rg_name
    virtual_network_name      = data.azurerm_virtual_network.vpeeringvnet02.name
    remote_virtual_network_id = data.azurerm_virtual_network.vpeeringvnet01.id
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
    allow_gateway_transit   = false
    use_remote_gateways     = true
    depends_on = [data.azurerm_virtual_network.vpeeringvnet01, data.azurerm_virtual_network.vpeeringvnet02, data.azurerm_virtual_network_gateway.vpngateway]
}

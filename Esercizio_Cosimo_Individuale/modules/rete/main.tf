

# creazione prima vnet con annessa subnet
resource "azurerm_virtual_network" "firstvnet" {
  name          = var.first_vnet
  location      = var.location-1
  address_space = [var.first_vnet_AddressSpace]
  resource_group_name = var.rg_name
}
# subnet 1
resource "azurerm_subnet" "firstvnetsub1" {
  name = var.first_vnet_sub1_name
  resource_group_name = var.rg_name
  virtual_network_name = azurerm_virtual_network.firstvnet.name
  address_prefixes = [ var.first_vnet_sub1_AddressSpace ]

  depends_on = [ azurerm_virtual_network.firstvnet ]
}

# subnet 2 (per la vpn)
resource "azurerm_subnet" "firstvnetsub2" {
  name = var.first_vnet_sub2_name
  resource_group_name = var.rg_name
  virtual_network_name = azurerm_virtual_network.firstvnet.name
  address_prefixes = [ var.first_vnet_sub2_AddressSpace ]

  depends_on = [ azurerm_virtual_network.firstvnet ]
}

################################################################

# creazione seconda vnet
resource "azurerm_virtual_network" "secondvnet" {
  name  = var.second_vnet
  address_space = [var.second_vnet_AddressSpace]
  location = var.location-2
  resource_group_name=  var.rg_name
}
# subnet 1
resource "azurerm_subnet" "secondvnetsub1" {
  name = var.first_vnet_sub3_name
  resource_group_name = var.rg_name
  virtual_network_name = azurerm_virtual_network.secondvnet.name
  address_prefixes = [ var.secod_vnet_sub1_AddressSpace ]

  depends_on = [ azurerm_virtual_network.secondvnet ]
}

#################################################################

# VPN GATEWAY

# Create Public IP for VPN Gateway 
resource "azurerm_public_ip" "vpnPiptf" {
    name                         = "vpnpip"
    location                     = var.location-1
    resource_group_name          = var.rg_name
    allocation_method            = "Dynamic"

}

# Crete VPN Gateway
resource "azurerm_virtual_network_gateway" "vpngateway" {
  name                = "VNet1GW"
  location            = var.location-1
  resource_group_name = var.rg_name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "Basic"
  #generation    = "Generation2"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpnPiptf.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.firstvnetsub2.id
  }

  vpn_client_configuration {
    address_space = ["172.16.101.0/24"]

    root_certificate {
      name = "p2s-jvn-root-cert"

      public_cert_data = <<EOF
MIIC+TCCAeGgAwIBAgIQI9E7JncrQp1OB7dsdJ4bTDANBgkqhkiG9w0BAQsFADAf
MR0wGwYDVQQDDBRQMlNSb290Q2VydEVydmluT2dnaTAeFw0yNDA0MjQxMDM3MjFa
Fw0yNjA0MjQxMDQ3MjFaMB8xHTAbBgNVBAMMFFAyU1Jvb3RDZXJ0RXJ2aW5PZ2dp
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA08CJgqVR+5bZ1DpRjkPR
tD9uqQCQqX27K4ByM97BmM65nsRhUriiCQPndOWONDXpJBMtrKa8wOU+Td53LQxo
RXDOzBPNi1gUIla/EQa7V9EgwdsqyTK4CnUMwGo5BH8GddrVshz9L8AMiVbKLPjn
rPA2kUmATgyhIhg2XxZDMun++no+dmMx4AquGtKOeetflSW92RsNY6IjmZeliDoD
Hkj7oJ6AjOrWYvssn0AB5JtBA7medTpXo4fl95pCS5IGSOvDtNu901T/yMk6+w3v
LhcYXozllIm85eyyON/YtXaJZpQuGjddIbjZHh7Q1wB/Scb+nWj810c9D1ROkL20
pQIDAQABozEwLzAOBgNVHQ8BAf8EBAMCAgQwHQYDVR0OBBYEFE0mm9NnXRULqnkL
0l8/q+CLo5FUMA0GCSqGSIb3DQEBCwUAA4IBAQCaCATBeUDMXF9Z70rPPOIn3LgC
O/gBCgbweZp8REaOS8vXnccMt38t0sB/ZVKQJ9wjho6NnSVCtURmAVNvkiCS7XgX
h8LDYgtfVcytCcWPZWB9GSXJ0319wBgqZq+o72/T6ctBjne3Vcda/PT0FeuG37nS
BivWxIk51qPe6/RbA9oIxwGv+WjMio1a1UVTjbgYwmvlVwaamAzEDStSn8WRpCZ+
+ev7YnH066BEXLUr0iHrDhSCNdtcBJSmpCB6wljq0S5Ripx+YfIYBRAkyP3VJBAw
AuUgdyInpZxRqoox5SkU+r44vF7jojjr61o/5cvpqxsG8L0bwbShuv5Edt/F
EOF
    }
  }
}



# Creazione terza vnet
resource "azurerm_virtual_network" "thirdvnet" {
  name          = "VNet03"
  location      = var.location-3
  address_space = ["10.30.0.0/16"]
  resource_group_name = var.rg_name
}

# subnet per la terza vnet
resource "azurerm_subnet" "thirdvnetsub3" {
  name = "Subnet-3"
  resource_group_name = var.rg_name
  virtual_network_name = azurerm_virtual_network.thirdvnet.name
  address_prefixes = ["10.30.0.0/24"]

  depends_on = [ azurerm_virtual_network.thirdvnet ]
}



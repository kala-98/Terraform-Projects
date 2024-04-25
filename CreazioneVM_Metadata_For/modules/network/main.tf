
# Creazione rete virtuale
resource "azurerm_virtual_network" "vnet" {
  name                = "VNet01"
  location            = var.rg_location
  resource_group_name = var.rg_name
  address_space       = ["10.0.0.0/16"]
  tags = {
    environment = "Laboratory"
  }
}

# Creazione SubNet
resource "azurerm_subnet" "subnet" {
  name                 = "mySubnet1"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

# Configurazione IP pubblico per 2 macchine
resource "azurerm_public_ip" "example" {
  for_each = toset([
    "vm1",
    "vm2",
  ])

  name                = "public-ip-${each.key}"
  resource_group_name = var.rg_name
  location            = var.rg_location
  allocation_method   = "Dynamic"

  tags = {
    environment = "Laboratory"
  }
}


# Creazione gruppo di sicurezza
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg24042024"
  location            = var.rg_location
  resource_group_name = var.rg_name

  security_rule {
    name                       = "Consenti-SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Laboratory"
  }
}
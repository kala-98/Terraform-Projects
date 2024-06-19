
# Creazione interfaccia di rete
resource "azurerm_network_interface" "nic" {
  for_each = toset(["1", "2",])
  name                = "nic-${each.key}"
  location            = var.rg_location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip_addresses[each.key - 1]
  }
}

# Associazione dell'nsg all'interfaccia di rete
resource "azurerm_network_interface_security_group_association" "association" {
  # network_interface_id      = azurerm_network_interface.nic.id
  # network_security_group_id = var.nsg_id
  for_each                  = azurerm_network_interface.nic
  network_interface_id      = each.value.id
  network_security_group_id = var.nsg_id
}

# Creazione chiave per l'accesso SSH
resource "tls_private_key" "example_ssh_vm1" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_private_key" "example_ssh_vm2" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Creazione VM Linux
resource "azurerm_linux_virtual_machine" "vmLinux" {
  for_each = toset(["1", "2",])
  name                  = "myVmLinux-${each.key}"
  location              = var.rg_location
  resource_group_name   = var.rg_name
  network_interface_ids = [azurerm_network_interface.nic[each.key].id]
  size                  = "Standard_B2ms"

  os_disk {
    name                 = "myOsDisk-${each.key}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "myVmLinux-${each.key}"
  admin_username                  = var.user
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.user
    public_key = each.key == "1" ? tls_private_key.example_ssh_vm1.public_key_openssh : tls_private_key.example_ssh_vm2.public_key_openssh
  }
}
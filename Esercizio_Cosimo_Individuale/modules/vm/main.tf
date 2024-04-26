
##################################### CREAZIONE VM #####################################


# Recupero la password d'accesso per la configurazione delle VM dal Key Vault
data "azurerm_key_vault" "kv"{
  name                = "keystr12345678"
  resource_group_name =  "myResourceGroup"
}

data "azurerm_key_vault_secret" "password" {
  name = "password-terraform"
  key_vault_id = data.azurerm_key_vault.kv.id
}

##################################### VM Server con AD #####################################

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "myNetworkSecurityGroup-01"
    location                     = var.location-1
    resource_group_name          = var.rg_name

    security_rule {
        name                       = "AllowRDP"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

}

data "azurerm_subnet" "firstvnetsub1" {
  name = var.firstsubnet
  resource_group_name = var.rg_name
  virtual_network_name = var.firstvnet
}

#Creates a vNIC for the VM
resource "azurerm_network_interface" "dc01_nic" {
  name                = "dc01_nic"
  location            = var.location-1
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "dc01_nic"
    subnet_id                     = data.azurerm_subnet.firstvnetsub1.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.10.0.4"
    #public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id #Added by ca
  }
}

# Create public IPs
# resource "azurerm_public_ip" "myterraformpublicip" {
#     name                         = "myPublicIP"
#     location                     = var.location-1
#     resource_group_name          = var.rg_name
#     allocation_method            = "Dynamic"

# }

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = azurerm_network_interface.dc01_nic.id
    network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}

#Creates the Azure VM
resource "azurerm_windows_virtual_machine" "dc01" {
  name                = "DC01"
  resource_group_name = var.rg_name
  location            = var.location-1
  size                = var.vm_size
  admin_username      = var.win_username_server
  admin_password      = data.azurerm_key_vault_secret.password.value
  network_interface_ids = [
    azurerm_network_interface.dc01_nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}



#Install Active Directory on the DC01 VM
resource "azurerm_virtual_machine_extension" "install_ad" {
  name                 = "install_ad"
#  resource_group_name  = azurerm_resource_group.main.name
  virtual_machine_id   = azurerm_windows_virtual_machine.dc01.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  protected_settings = <<SETTINGS
  {    
    "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.ADDS.rendered)}')) | Out-File -filepath ADDS.ps1\" && powershell -ExecutionPolicy Unrestricted -File ADDS.ps1 -Domain_DNSName ${data.template_file.ADDS.vars.Domain_DNSName} -Domain_NETBIOSName ${data.template_file.ADDS.vars.Domain_NETBIOSName} -SafeModeAdministratorPassword ${data.template_file.ADDS.vars.SafeModeAdministratorPassword}"
  }
  SETTINGS
}

#Variable input for the ADDS.ps1 script
data "template_file" "ADDS" {
    template = "${file("ADDS.ps1")}"
    vars = {
        Domain_DNSName          = "${var.Domain_DNSName}"
        Domain_NETBIOSName      = "${var.netbios_name}"
        SafeModeAdministratorPassword = "${data.azurerm_key_vault_secret.password.value}"
  }
}

#Export public IP
# data "azurerm_public_ip" "myterraformpublicip" {
#   name                = azurerm_public_ip.myterraformpublicip.name
#   resource_group_name = var.rg_name
#   depends_on          = [azurerm_windows_virtual_machine.dc01]
# }
# output "public_ip_address_dc" {
#   value = data.azurerm_public_ip.myterraformpublicip.ip_address
# }


##################################### VM-2 con Join Domain #####################################

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg2" {
    name                = "myNetworkSecurityGroup-02"
    location                     = var.location-2
    resource_group_name          = var.rg_name

    security_rule {
        name                       = "AllowRDP"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

}


data "azurerm_subnet" "firstvnetsub2" {
  name = var.secondsubnet
  resource_group_name = var.rg_name
  virtual_network_name = var.secondvnet
}

#Creates a vNIC for the VM
resource "azurerm_network_interface" "client01_nic" {
  name                = "client01_nic"
  location            = var.location-2
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "client01_nic"
    subnet_id                     = data.azurerm_subnet.firstvnetsub2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myterraformpublicip2.id
  }
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip2" {
    name                         = "myPublicIP"
    location                     = var.location-2
    resource_group_name          = var.rg_name
    allocation_method            = "Dynamic"

}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example2" {
    network_interface_id      = azurerm_network_interface.client01_nic.id
    network_security_group_id = azurerm_network_security_group.myterraformnsg2.id
}

#Creates the Azure VM
resource "azurerm_windows_virtual_machine" "client01" {
  name                = "client01"
  resource_group_name = var.rg_name
  location            = var.location-2
  size                = var.vm_size
  admin_username      = var.win_username
  admin_password      = data.azurerm_key_vault_secret.password.value
  network_interface_ids = [
    azurerm_network_interface.client01_nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "20h2-evd"
    version   = "latest"
  }

  depends_on = [ azurerm_windows_virtual_machine.dc01, azurerm_virtual_machine_extension.install_ad ]
}


#Install Join Domain on the client01 VM
resource "azurerm_virtual_machine_extension" "join_domain" {
  name                 = "join_domain"
  virtual_machine_id   = azurerm_windows_virtual_machine.client01.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  protected_settings = <<SETTINGS
  {    
    "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.JOINDOMAIN.rendered)}')) | Out-File -filepath JOINDOM.ps1\" && powershell -ExecutionPolicy Unrestricted -File JOINDOM.ps1"
  }
  SETTINGS
}

#Variable input for the JOINDOM.ps1 script
data "template_file" "JOINDOMAIN" {
    template = "${file("JOINDOM.ps1")}"
#     vars = {
#         Domain_DNSName          = "${var.Domain_DNSName}"
#         Domain_NETBIOSName      = "${var.netbios_name}"
#         SafeModeAdministratorPassword = "${data.azurerm_key_vault_secret.password.value}"
#   }

  depends_on = [ azurerm_virtual_machine_extension.install_ad ]
}

#Export public IP
data "azurerm_public_ip" "myterraformpublicip2" {
  name                = azurerm_public_ip.myterraformpublicip2.name
  resource_group_name = var.rg_name
  depends_on          = [azurerm_windows_virtual_machine.client01]
}
output "public_ip_address_client" {
  value = data.azurerm_public_ip.myterraformpublicip2.ip_address
}

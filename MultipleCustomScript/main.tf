
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.99.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.0.0"
    }
  }
}


provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Create resource group
resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location-1
}

data "azurerm_key_vault" "kv"{
  name                = "keystr12345678"
  resource_group_name =  "myResourceGroup"
}

data "azurerm_key_vault_secret" "password" {
  name = "password-terraform"
  key_vault_id = data.azurerm_key_vault.kv.id
}


####################################### RETE #######################################

# Creazione prima vnet con annessa subnet
resource "azurerm_virtual_network" "firstvnet" {
  name          = var.first_vnet
  location      = var.location-1
  address_space = [var.first_vnet_AddressSpace]
  resource_group_name = var.rg_name

  depends_on = [ azurerm_resource_group.rg ]
}
# Creazione subnet
resource "azurerm_subnet" "firstvnetsub1" {
  name = var.first_vnet_sub1_name
  resource_group_name = var.rg_name
  virtual_network_name = azurerm_virtual_network.firstvnet.name
  address_prefixes = [ var.first_vnet_sub1_AddressSpace ]

  depends_on = [ azurerm_virtual_network.firstvnet ]
}

####################################### STORAGE #######################################

# Create a storage account
resource "azurerm_storage_account" "sa" {
  name                     = "examplestorage28042024"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  depends_on = [ azurerm_resource_group.rg ]
}

# Create a blob container
resource "azurerm_storage_container" "sc" {
  name                  = "blobcontainer"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "container"

  depends_on = [ azurerm_storage_account.sa ]
}

# Upload file per l'installazione di AD
resource "azurerm_storage_blob" "script1" {
  name                   = "ADDS.ps1"
  storage_account_name   = azurerm_storage_account.sa.name
  storage_container_name = azurerm_storage_container.sc.name
  type                   = "Block"
  source                 = "scripts/ADDS.ps1"

  depends_on = [ azurerm_storage_container.sc ]
}

# Upload file per la creazione della struttura utenti
resource "azurerm_storage_blob" "script2" {
  name                   = "CreaOrganizzazioneAD.ps1"
  storage_account_name   = azurerm_storage_account.sa.name
  storage_container_name = azurerm_storage_container.sc.name
  type                   = "Block"
  source                 = "scripts/CreaOrganizzazioneAD.ps1"

  depends_on = [ azurerm_storage_container.sc ]
}

resource "azurerm_storage_blob" "fileCSV" {
  name                   = "Organizzazione.csv"
  storage_account_name   = azurerm_storage_account.sa.name
  storage_container_name = azurerm_storage_container.sc.name
  type                   = "Block"
  source                 = "scripts/Organizzazione.csv"

  depends_on = [ azurerm_storage_container.sc ]
}

####################################### VM #######################################

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
  name                = "myPublicIP"
  location            = var.location-1
  resource_group_name = var.rg_name
  allocation_method   = "Dynamic"

  depends_on = [ azurerm_resource_group.rg ]
}

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
  depends_on = [ azurerm_resource_group.rg ]
}

#Creates a vNIC for the VM
resource "azurerm_network_interface" "dc01_nic" {
  name                = "dc01_nic"
  location            = var.location-1
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "dc01_nic"
    subnet_id                     = azurerm_subnet.firstvnetsub1.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.10.0.5"
    public_ip_address_id = azurerm_public_ip.myterraformpublicip.id
  }
  depends_on = [ azurerm_resource_group.rg ]
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = azurerm_network_interface.dc01_nic.id
    network_security_group_id = azurerm_network_security_group.myterraformnsg.id

    depends_on = [ azurerm_network_interface.dc01_nic ]
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

####################################### CUSTOM SCRIPT #######################################

resource "azurerm_virtual_machine_extension" "install_scripts" {
  name                 = "install_scripts"
  virtual_machine_id   = azurerm_windows_virtual_machine.dc01.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  protected_settings = <<SETTINGS
  {     
    "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.install_scripts.rendered)}')) | Out-File -filepath master_script.ps1\" && powershell -ExecutionPolicy Unrestricted -File master_script.ps1 -url ${data.template_file.install_scripts.vars.url} -output ${data.template_file.install_scripts.vars.output} -Domain_DNSName ${data.template_file.install_scripts.vars.Domain_DNSName} -Domain_NETBIOSName ${data.template_file.install_scripts.vars.Domain_NETBIOSName} -SafeModeAdministratorPassword ${data.template_file.install_scripts.vars.SafeModeAdministratorPassword} -url2 ${data.template_file.install_scripts.vars.url2} -output2 ${data.template_file.install_scripts.vars.output2} -Dom1 ${data.template_file.install_scripts.vars.Dom1} -Dom2 ${data.template_file.install_scripts.vars.Dom2} -url3 ${data.template_file.install_scripts.vars.url3} -output3 ${data.template_file.install_scripts.vars.output3}"
   
  }
  SETTINGS
  depends_on = [ azurerm_windows_virtual_machine.dc01, azurerm_storage_blob.script1 ]
}

data "template_file" "install_scripts" {
    template = "${file("scripts/master_script.ps1")}"
      vars = {
        # Installazione AD e Dominio
        url = "https://${azurerm_storage_account.sa.name}.blob.core.windows.net/${azurerm_storage_container.sc.name}/${azurerm_storage_blob.script1.name}"
        output = "C:/Temp/script_install_ad.ps1"
        Domain_DNSName = var.Domain_DNSName
        Domain_NETBIOSName = var.netbios_name
        SafeModeAdministratorPassword = "${data.azurerm_key_vault_secret.password.value}"

        #######################################################
      
        ## Creazione organizzazione

        # Recupero lo script
        url2 = "https://${azurerm_storage_account.sa.name}.blob.core.windows.net/${azurerm_storage_container.sc.name}/${azurerm_storage_blob.script2.name}"
        output2 = "C:/Temp/script_create_org.ps1"    

        # Recupero il csv
        url3 = "https://${azurerm_storage_account.sa.name}.blob.core.windows.net/${azurerm_storage_container.sc.name}/${azurerm_storage_blob.fileCSV.name}"
        output3 = "C:/Temp/Organizzazione.csv"
        Dom1 = "dom"
        Dom2 = "it"
    }
}

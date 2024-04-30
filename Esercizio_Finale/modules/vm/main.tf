
##################################### CREAZIONE STORAGE E VM #####################################

# Recupero la password d'accesso per la configurazione delle VM dal Key Vault
data "azurerm_key_vault" "kv"{
  name                = "keystr12345678"
  resource_group_name =  "myResourceGroup"
}

data "azurerm_key_vault_secret" "password" {
  name = "password-terraform"
  key_vault_id = data.azurerm_key_vault.kv.id
}

####################################### STORAGE #######################################

# Create a storage account
resource "azurerm_storage_account" "sa" {
  name                     = "examplestorage30042024"
  resource_group_name      = var.rg_name
  location                 = var.location-1
  account_tier             = "Standard"
  account_replication_type = "LRS"
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

# Upload file csv per l'organizzazione di dom01.it
resource "azurerm_storage_blob" "fileCSV" {
  name                   = "Organizzazione.csv"
  storage_account_name   = azurerm_storage_account.sa.name
  storage_container_name = azurerm_storage_container.sc.name
  type                   = "Block"
  source                 = "scripts/Organizzazione.csv"

  depends_on = [ azurerm_storage_container.sc ]
}

# Upload file csv per l'organizzazione di dom02.it
resource "azurerm_storage_blob" "fileCSV2" {
  name                   = "Organizzazione2.csv"
  storage_account_name   = azurerm_storage_account.sa.name
  storage_container_name = azurerm_storage_container.sc.name
  type                   = "Block"
  source                 = "scripts/Organizzazione2.csv"

  depends_on = [ azurerm_storage_container.sc ]
}

####################################### VM SERVER-1 #######################################

data "azurerm_subnet" "firstvnetsub1" {
  name = var.firstsubnet
  resource_group_name = var.rg_name
  virtual_network_name = var.firstvnet
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg_server1" {
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

#Creates a vNIC for the VM
resource "azurerm_network_interface" "dc01_nic" {
  name                = "dc01_nic"
  location            = var.location-1
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "dc01_nic"
    subnet_id                     = data.azurerm_subnet.firstvnetsub1.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.10.0.6"
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example1" {
    network_interface_id      = azurerm_network_interface.dc01_nic.id
    network_security_group_id = azurerm_network_security_group.myterraformnsg_server1.id

    depends_on = [ azurerm_network_interface.dc01_nic ]
}

#Creates the Azure VM
resource "azurerm_windows_virtual_machine" "dc01" {
  name                = "Pdc01"
  resource_group_name = var.rg_name
  location            = var.location-1
  size                = var.vm_size
  admin_username      = var.win_username_server_1
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
    template = "${file("scripts/master_script1.ps1")}"
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
        Dom1 = "dom01"
        Dom2 = "it"
    }
}

####################################### VM SERVER-2 VNet-2 #######################################

data "azurerm_subnet" "secondvnetsub1" {
  name = var.secondsubnet
  resource_group_name = var.rg_name
  virtual_network_name = var.secondvnet
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg_server2" {
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

#Creates a vNIC for the VM
resource "azurerm_network_interface" "dc02_nic" {
  name                = "dc02_nic"
  location            = var.location-2
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "dc02_nic"
    subnet_id                     = data.azurerm_subnet.secondvnetsub1.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.20.0.6"
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example2" {
    network_interface_id      = azurerm_network_interface.dc02_nic.id
    network_security_group_id = azurerm_network_security_group.myterraformnsg_server2.id

    depends_on = [ azurerm_network_interface.dc02_nic ]
}

#Creates the Azure VM
resource "azurerm_windows_virtual_machine" "dc02" {
  name                = "Pdc02"
  resource_group_name = var.rg_name
  location            = var.location-2
  size                = var.vm_size
  admin_username      = var.win_username_server_2
  admin_password      = data.azurerm_key_vault_secret.password.value
  network_interface_ids = [
    azurerm_network_interface.dc02_nic.id
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


resource "azurerm_virtual_machine_extension" "install_scripts2" {
  name                 = "install_scripts"
  virtual_machine_id   = azurerm_windows_virtual_machine.dc02.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  protected_settings = <<SETTINGS
  {     
    "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.install_scripts2.rendered)}')) | Out-File -filepath master_script.ps1\" && powershell -ExecutionPolicy Unrestricted -File master_script.ps1 -url ${data.template_file.install_scripts2.vars.url} -output ${data.template_file.install_scripts2.vars.output} -Domain_DNSName ${data.template_file.install_scripts2.vars.Domain_DNSName} -Domain_NETBIOSName ${data.template_file.install_scripts2.vars.Domain_NETBIOSName} -SafeModeAdministratorPassword ${data.template_file.install_scripts2.vars.SafeModeAdministratorPassword} -url2 ${data.template_file.install_scripts2.vars.url2} -output2 ${data.template_file.install_scripts2.vars.output2} -Dom1 ${data.template_file.install_scripts2.vars.Dom1} -Dom2 ${data.template_file.install_scripts2.vars.Dom2} -url3 ${data.template_file.install_scripts2.vars.url3} -output3 ${data.template_file.install_scripts2.vars.output3}"
   
  }
  SETTINGS
  depends_on = [ azurerm_windows_virtual_machine.dc02, azurerm_storage_blob.script1 ]
}

data "template_file" "install_scripts2" {
    template = "${file("scripts/master_script1.ps1")}"
      vars = {
        # Installazione AD e Dominio
        url = "https://${azurerm_storage_account.sa.name}.blob.core.windows.net/${azurerm_storage_container.sc.name}/${azurerm_storage_blob.script1.name}"
        output = "C:/Temp/script_install_ad.ps1"
        Domain_DNSName = var.Domain2_DNSName
        Domain_NETBIOSName = var.netbios2_name
        SafeModeAdministratorPassword = "${data.azurerm_key_vault_secret.password.value}"

        #######################################################
      
        ## Creazione organizzazione

        # Recupero lo script
        url2 = "https://${azurerm_storage_account.sa.name}.blob.core.windows.net/${azurerm_storage_container.sc.name}/${azurerm_storage_blob.script2.name}"
        output2 = "C:/Temp/script_create_org.ps1"    

        # Recupero il csv
        url3 = "https://${azurerm_storage_account.sa.name}.blob.core.windows.net/${azurerm_storage_container.sc.name}/${azurerm_storage_blob.fileCSV2.name}"
        output3 = "C:/Temp/Organizzazione.csv"
        Dom1 = "dom02"
        Dom2 = "it"

    }
}



####################################### VM CLIENT-1 VNet1 #######################################

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsgclient01" {
    name                = "myNetworkSecurityGroup-03"
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

#Creates a vNIC for the VM
resource "azurerm_network_interface" "client01_nic" {
  name                = "client01_nic"
  location            = var.location-1
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "client01_nic"
    subnet_id                     = data.azurerm_subnet.firstvnetsub1.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [ azurerm_network_interface.dc01_nic ]
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example3" {
    network_interface_id      = azurerm_network_interface.client01_nic.id
    network_security_group_id = azurerm_network_security_group.myterraformnsgclient01.id
}

#Creates the Azure VM
resource "azurerm_windows_virtual_machine" "client01" {
  name                = "ClientW10"
  resource_group_name = var.rg_name
  location            = var.location-1
  size                = var.vm_size
  admin_username      = var.win_username_client_1
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

  depends_on = [ azurerm_windows_virtual_machine.dc01, azurerm_virtual_machine_extension.install_scripts ]
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
    "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.JOINDOMAIN_PARAM.rendered)}')) | Out-File -filepath JOINDOM_PARAM.ps1\" && powershell Start-Sleep -Seconds 300; powershell -ExecutionPolicy Unrestricted -File JOINDOM_PARAM.ps1 -Domain ${data.template_file.JOINDOMAIN_PARAM.vars.Domain} -ipServer ${data.template_file.JOINDOMAIN_PARAM.vars.ipServer} -username ${data.template_file.JOINDOMAIN_PARAM.vars.username} -password ${data.template_file.JOINDOMAIN_PARAM.vars.password}"
  }
  SETTINGS
}

#Variable input for the JOINDOM.ps1 script
data "template_file" "JOINDOMAIN_PARAM" {
    template = "${file("scripts/JOINDOM_PARAM.ps1")}"
    vars = {
        Domain          = "${var.Domain_DNSName}"
        ipServer     = azurerm_network_interface.dc01_nic.private_ip_address
        username = "${var.win_username_server_1}"
        password = "${data.azurerm_key_vault_secret.password.value}"
  }
  depends_on = [ azurerm_virtual_machine_extension.install_scripts ]
}


####################################### VM SERVER-3 VNet2 CON JOIN DOMAIN E FS #######################################

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg_server3" {
    name                = "myNetworkSecurityGroup-04"
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

#Creates a vNIC for the VM
resource "azurerm_network_interface" "dc03_nic" {
  name                = "dc03_nic"
  location            = var.location-2
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "dc03_nic"
    subnet_id                     = data.azurerm_subnet.secondvnetsub1.id
    #private_ip_address_allocation = "Dynamic"
    private_ip_address_allocation = "Static"
    private_ip_address = "10.20.0.4"
  }

  depends_on = [ azurerm_network_interface.dc03_nic ]
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example4" {
    network_interface_id      = azurerm_network_interface.dc03_nic.id
    network_security_group_id = azurerm_network_security_group.myterraformnsg_server3.id
}

#Creates the Azure VM
resource "azurerm_windows_virtual_machine" "dc03" {
  name                = "FS01"
  resource_group_name = var.rg_name
  location            = var.location-2
  size                = var.vm_size
  admin_username      = var.win_username_server_3
  admin_password      = data.azurerm_key_vault_secret.password.value
  network_interface_ids = [
    azurerm_network_interface.dc03_nic.id
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

  depends_on = [ azurerm_windows_virtual_machine.dc03, azurerm_virtual_machine_extension.install_scripts2 ]
}

# Creo il disco aggiuntivo
resource "azurerm_managed_disk" "example" {
  name                 = "disk_aggiuntivo"
  location             = var.location-2
  resource_group_name  =  var.rg_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 16

  depends_on = [ azurerm_windows_virtual_machine.dc03 ]
}

resource "azurerm_virtual_machine_data_disk_attachment" "example" {
  managed_disk_id    = azurerm_managed_disk.example.id
  virtual_machine_id = azurerm_windows_virtual_machine.dc03.id
  lun                = "0"
  caching            = "ReadWrite"

  depends_on = [ azurerm_managed_disk.example ]
}

#Install Join Domain 
resource "azurerm_virtual_machine_extension" "join_domain2" {
  name                 = "join_domain"
  virtual_machine_id   = azurerm_windows_virtual_machine.dc03.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  protected_settings = <<SETTINGS
  {    
    "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.JOINDOMAIN_PARAM2.rendered)}')) | Out-File -filepath JOINDOM_PARAM.ps1\" && powershell Start-Sleep -Seconds 300; powershell -ExecutionPolicy Unrestricted -File JOINDOM_PARAM.ps1 -Domain ${data.template_file.JOINDOMAIN_PARAM2.vars.Domain} -ipServer ${data.template_file.JOINDOMAIN_PARAM2.vars.ipServer} -username ${data.template_file.JOINDOMAIN_PARAM2.vars.username} -password ${data.template_file.JOINDOMAIN_PARAM2.vars.password}"
  }
  SETTINGS
}

#Variable input for the JOINDOM.ps1 script
data "template_file" "JOINDOMAIN_PARAM2" {
    template = "${file("scripts/JOINDOM_PARAM.ps1")}"
    vars = {
        Domain          = "${var.Domain2_DNSName}"
        ipServer     = azurerm_network_interface.dc02_nic.private_ip_address
        username = "${var.win_username_server_2}"
        password = "${data.azurerm_key_vault_secret.password.value}"
  }
  depends_on = [ azurerm_virtual_machine_extension.install_scripts2 ]
}



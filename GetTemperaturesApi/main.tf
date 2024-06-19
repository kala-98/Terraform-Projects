
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
# test

provider "azurerm" {
  features {
  }
}

provider "http" {}

data "azurerm_key_vault" "kv" {
  name                = "keystr12345678"
  resource_group_name = "myResourceGroup"
}

data "azurerm_key_vault_secret" "password" {
  name         = "apiweather"
  key_vault_id = data.azurerm_key_vault.kv.id
}

resource "azurerm_resource_group" "rg" {
  name     = var.my_resource_group.nome
  location = var.my_resource_group.location
}

resource "azurerm_storage_account" "sa" {
  name                     = var.my_Storage_account
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }

  depends_on = [azurerm_resource_group.rg]
}

resource "azurerm_storage_container" "mycon" {
  name                  = var.my_container
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"

  depends_on = [azurerm_storage_account.sa]
}

resource "null_resource" "uploadfile" {

  provisioner "local-exec" {

    # upload del file dentro un blob
    command = <<-EOT
  $storageAcct = Get-AzStorageAccount -ResourceGroupName "${azurerm_resource_group.rg.name}" -Name "${azurerm_storage_account.sa.name}"
   Set-AzStorageBlobContent `
   -Context $storageAcct.Context `
   -Container "${azurerm_storage_container.mycon.name}" `
   -File ".\MyDom.ps1" `
   -Blob "MyDom.ps1"

  EOT

    interpreter = ["PowerShell", "-Command"]
    #interpreter = ["pwsh", "-Command"]
  }

  depends_on = [azurerm_storage_container.mycon]
}

# upload dentro un blob
resource "azurerm_storage_blob" "myblob" {
  name                   = "exampleblob"
  storage_account_name   = var.my_Storage_account
  storage_container_name = var.my_container
  type                   = "Block"
  source                 = "C:/MyTemp/test.txt"

  depends_on = [azurerm_storage_container.mycon]

}

# Creazione file share
resource "azurerm_storage_share" "myshare2024" {
  name                 = "sharename24042024"
  storage_account_name = var.my_Storage_account
  quota                = 50

  depends_on = [azurerm_storage_account.sa]
}

# Upload di un contenuto dentro il file share
resource "azurerm_storage_share_file" "testfile" {
  name             = "testfile.txt"
  storage_share_id = azurerm_storage_share.myshare2024.id
  source           = "./example.txt"

  depends_on = [azurerm_storage_share.myshare2024]
}



# Creazione tabella
resource "azurerm_storage_table" "table24042024" {
  name                 = "tabella24042024"
  storage_account_name = var.my_Storage_account

  depends_on = [azurerm_storage_account.sa]
}


# Definisco delle variabili d'appoggio per le città e le temperature
locals {
  lista_citta = toset(["Milan", "Moscow", "Lagos"])

  lista_temperature = {
    for city, response in data.http.temperature : city => jsondecode(response.body)["current"]["temp_c"]
  }
}

# Accedo ai dati delle temperature attraverso l'api di weatherapi
data "http" "temperature" {
  for_each = local.lista_citta
  url      = "http://api.weatherapi.com/v1/current.json?key=${data.azurerm_key_vault_secret.password.value}&q=${each.key}&aqi=no"

  request_headers = {
    Accept = "application/json"
  }
}


# Creazione entità nella tabella
resource "azurerm_storage_table_entity" "table240420241" {
  storage_table_id = azurerm_storage_table.table24042024.id
  for_each         = local.lista_citta
  partition_key    = "Città"
  row_key          = each.key
  entity = {
    temperatura = local.lista_temperature[each.key]
  }
}

# Creazione coda
resource "azurerm_storage_queue" "example" {
  name                 = "mysamplequeue"
  storage_account_name = var.my_Storage_account

  depends_on = [azurerm_storage_account.sa]
}


# Inserimento messaggio in una coda
resource "null_resource" "message" {
  provisioner "local-exec" {
    command = "az storage message put --connection-string ${azurerm_storage_account.sa.primary_connection_string} --queue-name mysamplequeue --account-name ${azurerm_storage_account.sa.name} --content 'okkk'"
  }
  depends_on = [azurerm_storage_queue.example]
}


output "temperatures_per_city" {
  value = local.lista_temperature
}
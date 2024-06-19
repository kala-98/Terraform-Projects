terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.99.0"
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

# Creazione di un gruppo di risorse
resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.rg_location
}

# Accedo al KeyVault
data "azurerm_key_vault" "kv" {
  name                = "keystr12345678"
  resource_group_name = "myResourceGroup"
}

data "azurerm_key_vault_secret" "user" {
  name         = "username"
  key_vault_id = data.azurerm_key_vault.kv.id
}


# Importazione moduli
module "rete" {
  source      = "./modules/network"
  rg_name     = var.rg_name
  rg_location = var.rg_location
  depends_on  = [azurerm_resource_group.rg]
}

module "vm" {
  source      = "./modules/vm"
  rg_name     = var.rg_name
  rg_location = var.rg_location
  nsg_id      = module.rete.nsg_id
  #public_ip_id = module.rete.public_ip_addresses
  public_ip_addresses = module.rete.public_ip_addresses
  subnet_id           = module.rete.subnet_id
  user                = data.azurerm_key_vault_secret.user.value
  depends_on          = [azurerm_resource_group.rg, module.rete]
}

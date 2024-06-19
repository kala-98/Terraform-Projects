
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

module "rete" {
  source     = "./modules/rete"
  rg_name    = var.rg_name
  location-1 = var.location-1
  location-2 = var.location-2

  depends_on = [azurerm_resource_group.rg]
}

module "peering" {
  source     = "./modules/peering"
  rg_name    = var.rg_name
  location-1 = var.location-1
  location-2 = var.location-2

  depends_on = [module.rete]
}

module "vm" {
  source     = "./modules/vm"
  rg_name    = var.rg_name
  location-1 = var.location-1
  location-2 = var.location-2

  depends_on = [module.rete]
}


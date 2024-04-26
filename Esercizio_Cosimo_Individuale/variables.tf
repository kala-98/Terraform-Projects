variable "rg_name" {
    type = string
    description = "Nome gruppo di risorsa"
    default = "ResourceGroup_Esercizio"
}

variable "location-1" {
    type = string
    description = "RG and resources location"
    default = "West US"
}

variable "location-2" {
    type = string
    description = "RG and resources location"
    default = "East US"
}

# variable "win_username" {
#   description = "Windows node username"
#   type        = string
#   sensitive   = false
#   default = "ca"
# }

# # variable "win_userpass" {
# #   description = "Windows node password"
# #   type        = string
# #   sensitive   = true
# #   default     = data.azurerm_key_vault_secret.password.value
# # }

# variable "Domain_DNSName" {
#   description = "FQDN for the Active Directory forest root domain"
#   type        = string
#   sensitive   = false
#   default = "dom.it"
# }

# variable "netbios_name" {
#   description = "NETBIOS name for the AD domain"
#   type        = string
#   sensitive   = false
#   default = "dom"
# }

# # variable "SafeModeAdministratorPassword" {
# #   description = "Password for AD Safe Mode recovery"
# #   type        = string
# #   sensitive   = true
# #   default     = data.azurerm_key_vault_secret.password.value
# # }

# variable "vm_size" {
#   description = "Size of the VM"
#   type        = string 
#   sensitive   = false 
#   default     = "Standard_D2as_V4"
# }
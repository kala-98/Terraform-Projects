
variable "rg_name" {
  default = "ResourceGroup_MultipleCS"
}

variable "location-1" {
    default = "West US"
}

variable "first_vnet" {
    default = "VNet-01"
}

variable "first_vnet_AddressSpace" {
    default = "10.10.0.0/16"
    description = "Addres space of first virtual network"
}

variable "first_vnet_sub1_name" {
    default = "Subnet-1"
    description ="Name of the first subnet into first Virtual network"
}

variable "first_vnet_sub1_AddressSpace" {
    default = "10.10.0.0/24"
    description = "Addres space of first subnet into first virtual network"
}

variable "win_username_server" {
  description = "Windows node username"
  type        = string
  sensitive   = false
  default = "fsAdmin"
}




variable "Domain_DNSName" {
  description = "FQDN for the Active Directory forest root domain"
  type        = string
  sensitive   = false
  default = "dom.it"
}

variable "netbios_name" {
  description = "NETBIOS name for the AD domain"
  type        = string
  sensitive   = false
  default = "dom"
}

variable "vm_size" {
  description = "Size of the VM"
  type        = string 
  sensitive   = false 
  default     = "Standard_D2as_V4"
}

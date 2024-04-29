
variable "rg_name" {
  default = "trust-rg"
}

variable "location-1" {
  default = "West US"
}

variable "location-2" {
  default = "East US"
}

variable "first_vnet" {
  default = "VNet01"
}

variable "second_vnet" {
  default = "VNet02"
}

variable "first_vnet_AddressSpace" {
  default = "10.0.0.0/16"
}

variable "first_vnet_sub1_name" {
  default = "sub01"
}

variable "first_vnet_sub1_AddressSpace" {
  default = "10.0.0.0/24"
}

variable "second_vnet_AddressSpace" {
  default = "10.10.0.0/16"
}

variable "second_vnet_sub1_name" {
  default = "sub02"
}

variable "second_vnet_sub1_AddressSpace" {
  default = "10.10.0.0/24"
}

variable "vm_size" {
  description = "Size of the VM"
  type        = string 
  sensitive   = false 
  default     = "Standard_D2as_V4"
}

variable "win_username_server" {
  description = "Windows node username"
  type        = string
  sensitive   = false
  default = "fsAdmin"
}

variable "win_username_client" {
  description = "Windows node username"
  type        = string
  sensitive   = false
  default = "ca"
}

variable "Domain_DNSName" {
  description = "FQDN for the Active Directory forest root domain"
  type        = string
  sensitive   = false
  default = "dom.net"
}

variable "netbios_name" {
  description = "NETBIOS name for the AD domain"
  type        = string
  sensitive   = false
  default = "dom"
}

variable "Domain2_DNSName" {
  description = "FQDN for the Active Directory forest root domain"
  type        = string
  sensitive   = false
  default = "dom2.net"
}


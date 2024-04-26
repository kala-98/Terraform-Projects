variable "rg_name" {
  
}

variable "location-1" {
  
}

variable "location-2" {
  
}

variable "location-3" {
  default = "Central US"
}

variable "firstvnet" {
    default = "VNet01"
}

variable "secondvnet" {
    default = "VNet02"
}

variable "thirdvnet" {
    default = "VNet03"
}

variable "firstsubnet" {
    default = "Subnet-1"
}

variable "secondsubnet" {
    default = "Subnet-2"
}

variable "thirdsubnet" {
    default = "Subnet-3"
}

variable "win_username_server" {
  description = "Windows node username"
  type        = string
  sensitive   = false
  default = "fsAdmin"
}

variable "win_username" {
  description = "Windows node username"
  type        = string
  sensitive   = false
  default = "ca"
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

variable "Domain_DNSName_thirdvnet" {
  description = "FQDN for the Active Directory forest root domain"
  type        = string
  sensitive   = false
  default = "dom2.it"
}

variable "netbios_name_thirdvnet" {
  description = "NETBIOS name for the AD domain"
  type        = string
  sensitive   = false
  default = "dom2"
}
variable "rg_name" {
  
}

variable "location-1" {
  
}

variable "location-2" {
  
}

variable "firstvnet" {
}

variable "secondvnet" {
}


variable "firstsubnet" {
}

variable "secondsubnet" {
}

variable "win_username_server_1" {
  description = "Windows node username"
  type        = string
  sensitive   = false
  default = "fsAdmin"
}

variable "win_username_client_1" {
  description = "Windows node username"
  type        = string
  sensitive   = false
  default = "client01"
}

variable "win_username_server_2" {
  description = "Windows node username"
  type        = string
  sensitive   = false
  default = "fsAdmin"
}

variable "win_username_server_3" {
  description = "Windows node username"
  type        = string
  sensitive   = false
  default = "pdc01Admin"
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
  default = "dom01.it"
}

variable "netbios_name" {
  description = "NETBIOS name for the AD domain"
  type        = string
  sensitive   = false
  default = "dom01"
}

variable "vm_size" {
  description = "Size of the VM"
  type        = string 
  sensitive   = false 
  default     = "Standard_D2as_V4"
}

variable "Domain2_DNSName" {
  description = "FQDN for the Active Directory forest root domain"
  type        = string
  sensitive   = false
  default = "dom02.it"
}


variable "rg_name" {
  
}

variable "location-1" {
  
}

variable "location-2" {
  
}

variable "first_vnet" {
    default = "VNet01"
    description ="Name of first Virtual network"
}

variable "second_vnet" {
    default = "VNet02"
    description ="Name of second Virtual network"
}

variable "third_vnet" {
    default = "VNet03"
    description ="Name of second Virtual network"
}

variable "vpngateway" {
    default = "VNet1GW"
}
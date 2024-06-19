variable "rg_name" {
  
}

variable "location-1" {
  
}

variable "location-2" {
  
}

variable "location-3" {
  default = "Central US"
}

variable "first_vnet" {
    default = "VNet01"
    description ="Name of first Virtual network"
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

variable "first_vnet_sub2_name" {
    default = "GatewaySubnet"
    description ="Name of the VPN Gateway subnet into first Virtual network"
}

variable "first_vnet_sub2_AddressSpace" {
    default = "10.10.255.0/27"
    description = "Addres space for Gateway VPN subnet into first virtual network"
}

variable "second_vnet" {
    default = "VNet02"
    description ="Name of second Virtual network"
}

variable "second_vnet_AddressSpace" {
    default = "10.20.0.0/16"
    description = "Addres space of second virtual network"
}

variable "first_vnet_sub3_name" {
    default = "Subnet-2"
    description ="Name of the first subnet into first Virtual network"
}



variable "secod_vnet_sub1_AddressSpace" {
    default = "10.20.0.0/24"
    description = "Addres space for 1 subnet into second virtual network"
}

variable "third_vnet" {
    default = "VNet03"
    description ="Name of third Virtual network"
}
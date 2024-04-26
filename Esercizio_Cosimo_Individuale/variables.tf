variable "rg_name" {
  type        = string
  description = "Nome gruppo di risorsa"
  default     = "ResourceGroup_Esercizio"
}

variable "location-1" {
  type        = string
  description = "RG and resources location"
  default     = "West US"
}

variable "location-2" {
  type        = string
  description = "RG and resources location"
  default     = "East US"
}

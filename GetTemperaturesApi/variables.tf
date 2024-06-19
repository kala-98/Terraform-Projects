variable "my_resource_group" {
  type = map(string)
  default = {
    nome     = "rg-storage24042024"
    location = "West Europe"
  }
  description = "Nome e Locazione del Resource Group da creare."
}
variable "my_Storage_account" {
  type    = string
  default = "storage240420242024"
}
variable "my_container" {
  type        = string
  default     = "container24042024"
  description = "Nome del Container"
}
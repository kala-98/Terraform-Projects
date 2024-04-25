# Obiettivo

Definire un progetto su Terraform affinché vengano rispettati questi requisiti:
  - Creazione di una rete virtuale, subnet e nsg
  - Creazione di 2 VM Linux --> *utilizzare i metadata per crearle*

## Steps

Dividere gli script nei moduli, pertanto la struttura sarà pressoché questa:
-  main.tf
-  variables.tf
-  outputs.tf
-  modules
    - network
        - main.tf
        - variables.tf
        - outputs.tf
    - vm
        - main.tf
        - variables.tf
        - outputs.tf

---

[Consulta la documentazione completa qui](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
  
  
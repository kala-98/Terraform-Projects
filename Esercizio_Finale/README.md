# Creazione di un Key Vault e VM Windows



## Descrizione Progetto

- Definizione del progetto Terraform con 3 moduli:
  1. Configurazione del **key-vault** con creazione di un segreto al suo interno
  
  2. Configurazione di una **VM Windows** con password d'accesso da recuperare dal Vault


## Struttura grafica
- **root**
  - main.tf
  - variables.tf
  - outputs.tf
  - **modules**
    - **rete**
      - main.tf
      - variables.tf
      - outputs.tf
    - **peering**
      - main.tf
      - variables.tf
    - **vm**
      - main.tf
      - variables.tf
      - outputs.tf


## Steps

- root main.tf
  1. Definizione e creazione del gruppo di risorse
  1. Importazione dei moduli "secret-vault" e "vm"

- secret-vault main.tf
  1. Recupero della variabile per il gruppo di risorse
  1. Configurazione e creazione del Key Vault. Sono state abilitate queste impostazioni:
     - **purge_soft_deleted_secrets_on_destroy**
     - **recover_soft_deleted_secrets**
  
  1. output:
     - Il valore della password da passare alla configurazione della vm

- vm main.tf
  1. Recupero della variabile per il gruppo di risorse, nonché della password dal modulo secret-vault
  2. Configurazione di una VM Windows Server 2016
  3. Configurazione delle impostazioni di rete:
     - Virtual Network + Subnet
     - Network Security Group
     - Public IP Address
     -  Network Interface Card

  ---
  [Per ulteriori approfondimenti consultare la documentazione qui](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)


# Pipeline KeyVault – Lit le Resource Group (Pipeline 1) et les infos du Storage (Pipeline 3)
# et déploie le Key Vault en utilisant le module ./modules/keyvault

# ---- Récupération des infos du Resource Group existant ----
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

variable "linked_storage_account_name" {
  description = "Nom du Storage Account lié (optionnel)"
  type        = string
  default     = ""
}

# ---- Infos du service principal courant ----
data "azurerm_client_config" "current" {}

# ---- Suffixe aléatoire pour le nom du Key Vault ----
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# ---- Module KeyVault (réutilise le module existant) ----
module "keyvault" {
  source              = "../../modules/keyvault"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  key_vault_name      = var.key_vault_name
  suffix              = random_string.suffix.result
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id

  keyvault_sku              = var.keyvault_sku
  keyvault_retention_days   = var.keyvault_retention_days
  keyvault_purge_protection = var.keyvault_purge_protection
  keyvault_disk_encryption  = var.keyvault_disk_encryption
  keyvault_deployment       = var.keyvault_deployment
  vm_admin_password         = var.vm_admin_password
}

# ---- Secret bonus : storage connection string depuis paramètre ----
resource "azurerm_key_vault_secret" "storage_connection" {
  count        = var.linked_storage_account_name != "" ? 1 : 0
  name         = "storage-account-name"
  value        = var.linked_storage_account_name
  key_vault_id = module.keyvault.key_vault_id

  depends_on = [module.keyvault]
}

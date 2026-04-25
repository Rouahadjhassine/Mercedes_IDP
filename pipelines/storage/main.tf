# Pipeline Storage – Lit le Resource Group depuis le remote state du Pipeline 1
# et déploie le Storage Account en utilisant le module ./modules/storage

# ---- Récupération des infos du Resource Group existant ----
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# ---- Suffixe aléatoire pour le nom du Storage Account ----
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# ---- Module Storage (réutilise le module existant) ----
module "storage" {
  source               = "../../modules/storage"
  resource_group_name  = data.azurerm_resource_group.rg.name
  location             = data.azurerm_resource_group.rg.location
  storage_account_name = var.storage_account_name
  suffix              = random_string.suffix.result

  storage_account_tier     = var.storage_account_tier
  storage_replication_type = var.storage_replication_type
  storage_access_tier      = var.storage_access_tier
  storage_kind             = var.storage_kind
  storage_retention_days   = var.storage_retention_days
}

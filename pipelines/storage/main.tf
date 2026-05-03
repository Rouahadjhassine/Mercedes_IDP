# Pipeline Storage – Déploie le Storage Account dans le Resource Group cible

# ---- Récupération des infos du Resource Group existant ----
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# ---- Module Storage (réutilise le module existant) ----
module "storage" {
  source               = "../../modules/storage"
  resource_group_name  = data.azurerm_resource_group.rg.name
  location             = data.azurerm_resource_group.rg.location
  storage_account_name = var.storage_account_name
  suffix               = ""  # L'utilisateur fournit un nom unique (max 24 chars)

  storage_account_tier     = var.storage_account_tier
  storage_replication_type = var.storage_replication_type
  storage_access_tier      = var.storage_access_tier
  storage_kind             = var.storage_kind
  storage_retention_days   = var.storage_retention_days
}

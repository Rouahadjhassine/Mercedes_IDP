# Pipeline Storage – Lit le Resource Group depuis le remote state du Pipeline 1
# et déploie le Storage Account en utilisant le module ./modules/storage

# ---- Lecture du remote state du Pipeline Resource Group ----
data "terraform_remote_state" "rg" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "pfetfstate"
    container_name       = "tfstate"
    key                  = "resource-group.tfstate"
  }
}

# ---- Suffixe aléatoire pour le nom du Storage Account ----
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# ---- Module Storage (réutilise le module existant) ----
module "storage" {
  source              = "../../modules/storage"
  prefix              = data.terraform_remote_state.rg.outputs.prefix
  environment         = data.terraform_remote_state.rg.outputs.environment
  location            = data.terraform_remote_state.rg.outputs.resource_group_location
  resource_group_name = data.terraform_remote_state.rg.outputs.resource_group_name
  suffix              = random_string.suffix.result

  storage_account_tier     = var.storage_account_tier
  storage_replication_type = var.storage_replication_type
  storage_access_tier      = var.storage_access_tier
  storage_kind             = var.storage_kind
  storage_retention_days   = var.storage_retention_days
}

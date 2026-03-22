# Pipeline KeyVault – Lit le Resource Group (Pipeline 1) et les infos du Storage (Pipeline 3)
# et déploie le Key Vault en utilisant le module ./modules/keyvault

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

# ---- Lecture optionnelle du remote state du Pipeline Storage ----
# (pour stocker la connection string du storage dans le Key Vault)
data "terraform_remote_state" "storage" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "pfetfstate"
    container_name       = "tfstate"
    key                  = "storage.tfstate"
  }
}

# ---- Infos du service principal courant ----
data "azurerm_client_config" "current" {}

# ---- Module KeyVault (réutilise le module existant) ----
module "keyvault" {
  source              = "../../modules/keyvault"
  key_vault_name      = var.key_vault_name
  environment         = data.terraform_remote_state.rg.outputs.environment
  location            = data.terraform_remote_state.rg.outputs.resource_group_location
  resource_group_name = data.terraform_remote_state.rg.outputs.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id

  keyvault_sku              = var.keyvault_sku
  keyvault_retention_days   = var.keyvault_retention_days
  keyvault_purge_protection = var.keyvault_purge_protection
  keyvault_disk_encryption  = var.keyvault_disk_encryption
  keyvault_deployment       = var.keyvault_deployment
  vm_admin_password         = var.vm_admin_password
}

# ---- Secret bonus : storage connection string depuis le Pipeline Storage ----
resource "azurerm_key_vault_secret" "storage_connection" {
  count        = data.terraform_remote_state.storage.outputs.storage_account_name != "" ? 1 : 0
  name         = "storage-account-name"
  value        = data.terraform_remote_state.storage.outputs.storage_account_name
  key_vault_id = module.keyvault.key_vault_id

  depends_on = [module.keyvault]
}

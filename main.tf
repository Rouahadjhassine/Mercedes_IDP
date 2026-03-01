terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
  subscription_id = var.subscription_id
}

data "azurerm_client_config" "current" {}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_resource_group" "pfe_rg" {
  name     = "${var.prefix}-rg-${var.environment}"
  location = var.location
  tags = {
    Environment = var.environment
    Project     = "PFE"
    ManagedBy   = "Terraform"
    Owner       = var.owner
  }
}

# ---- Module VM ----
module "vm" {
  source              = "./modules/vm"
  prefix              = var.prefix
  environment         = var.environment
  location            = azurerm_resource_group.pfe_rg.location
  resource_group_name = azurerm_resource_group.pfe_rg.name

  # Nouvelles variables généralisées
  vm_count          = var.vm_count
  vm_size           = var.vm_size
  vm_os_type        = var.vm_os_type
  vm_os_image       = var.vm_os_image
  vm_disk_type      = var.vm_disk_type
  vm_admin_username = var.vm_admin_username
  vm_admin_password = var.vm_admin_password
}

# ---- Module Storage ----
module "storage" {
  source              = "./modules/storage"
  prefix              = var.prefix
  environment         = var.environment
  location            = azurerm_resource_group.pfe_rg.location
  resource_group_name = azurerm_resource_group.pfe_rg.name
  suffix              = random_string.suffix.result

  # Nouvelles variables généralisées
  storage_account_tier     = var.storage_account_tier
  storage_replication_type = var.storage_replication_type
  storage_access_tier      = var.storage_access_tier
  storage_kind             = var.storage_kind
  storage_retention_days   = var.storage_retention_days
}

# ---- Module KeyVault ----
module "keyvault" {
  source              = "./modules/keyvault"
  prefix              = var.prefix
  environment         = var.environment
  location            = azurerm_resource_group.pfe_rg.location
  resource_group_name = azurerm_resource_group.pfe_rg.name
  suffix              = random_string.suffix.result
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id

  # Nouvelles variables généralisées
  keyvault_sku              = var.keyvault_sku
  keyvault_retention_days   = var.keyvault_retention_days
  keyvault_purge_protection = var.keyvault_purge_protection
  keyvault_disk_encryption  = var.keyvault_disk_encryption
  keyvault_deployment       = var.keyvault_deployment
  vm_admin_password         = var.vm_admin_password
}
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

module "vm" {
  source = "./modules/vm"

  prefix              = var.prefix
  environment         = var.environment
  location            = azurerm_resource_group.pfe_rg.location
  resource_group_name = azurerm_resource_group.pfe_rg.name
  vm_size             = var.vm_size
  vm_admin_username   = var.vm_admin_username
  vm_admin_password   = var.vm_admin_password
}

module "storage" {
  source = "./modules/storage"

  prefix              = var.prefix
  environment         = var.environment
  location            = azurerm_resource_group.pfe_rg.location
  resource_group_name = azurerm_resource_group.pfe_rg.name
  suffix              = random_string.suffix.result
}

module "keyvault" {
  source = "./modules/keyvault"

  prefix              = var.prefix
  environment         = var.environment
  location            = azurerm_resource_group.pfe_rg.location
  resource_group_name = azurerm_resource_group.pfe_rg.name
  suffix              = random_string.suffix.result
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id
  vm_admin_password   = var.vm_admin_password
}
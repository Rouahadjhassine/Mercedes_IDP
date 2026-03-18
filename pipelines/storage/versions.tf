terraform {
  required_version = ">= 1.3.0"
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

  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "pfetfstate"
    container_name       = "tfstate"
    key                  = "storage.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

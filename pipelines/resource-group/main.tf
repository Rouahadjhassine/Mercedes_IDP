# Pipeline Resource Group – Crée uniquement le Resource Group Azure
# Les autres pipelines (VM, Storage, KeyVault) liront son output via le remote state

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg-${var.environment}"
  location = var.location

  tags = {
    Environment = var.environment
    Project     = "PFE-IDP"
    ManagedBy   = "Terraform"
    Owner       = var.owner
    Pipeline    = "resource-group"
  }
}

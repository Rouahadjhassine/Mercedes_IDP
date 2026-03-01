variable "prefix"              { type = string }
variable "environment"         { type = string }
variable "location"            { type = string }
variable "resource_group_name" { type = string }
variable "suffix"              { type = string }

resource "azurerm_storage_account" "storage" {
  name                            = "${var.prefix}st${var.suffix}"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  tags = { Environment = var.environment }
}

resource "azurerm_storage_container" "data" {
  name                  = "pfe-data"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "scripts" {
  name                  = "pfe-scripts"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "logs" {
  name                  = "pfe-logs"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

output "storage_account_name"     { value = azurerm_storage_account.storage.name }
output "storage_account_id"       { value = azurerm_storage_account.storage.id }
output "storage_primary_endpoint" { value = azurerm_storage_account.storage.primary_blob_endpoint }
output "storage_connection_string" {
  value     = azurerm_storage_account.storage.primary_connection_string
  sensitive = true
}
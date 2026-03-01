variable "prefix"              { type = string }
variable "environment"         { type = string }
variable "location"            { type = string }
variable "resource_group_name" { type = string }
variable "suffix"              { type = string }
variable "tenant_id"           { type = string }
variable "object_id"           { type = string }
variable "vm_admin_password" {
  type      = string
  sensitive = true
}
resource "azurerm_key_vault" "kv" {
  name                        = "${var.prefix}-kv-${var.suffix}"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = var.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  enabled_for_disk_encryption = true
  enabled_for_deployment      = true

  access_policy {
    tenant_id = var.tenant_id
    object_id = var.object_id

    key_permissions    = ["Get", "List", "Create", "Delete", "Update", "Recover", "Purge"]
    secret_permissions = ["Get", "List", "Set", "Delete", "Recover", "Purge"]
    certificate_permissions = ["Get", "List", "Create", "Delete", "Recover", "Purge"]
  }

  tags = { Environment = var.environment }
}

resource "azurerm_key_vault_secret" "vm_password" {
  name         = "vm-admin-password"
  value        = var.vm_admin_password
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_key_vault.kv]
}

resource "azurerm_key_vault_secret" "environment_name" {
  name         = "environment-name"
  value        = var.environment
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_key_vault.kv]
}

output "key_vault_name" { value = azurerm_key_vault.kv.name }
output "key_vault_id"   { value = azurerm_key_vault.kv.id }
output "key_vault_uri"  { value = azurerm_key_vault.kv.vault_uri }
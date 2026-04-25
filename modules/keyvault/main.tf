# ---- Variables reçues depuis main.tf racine ----
variable "location"                  { type = string }
variable "resource_group_name"       { type = string }
variable "key_vault_name"            { type = string }
variable "suffix"                    { type = string }
variable "tenant_id"                 { type = string }
variable "object_id"                 { type = string }
variable "keyvault_sku"              { type = string }
variable "keyvault_retention_days"   { type = number }
variable "keyvault_purge_protection" { type = bool   }
variable "keyvault_disk_encryption"  { type = bool   }
variable "keyvault_deployment"       { type = bool   }
variable "vm_admin_password" {
  type      = string
  sensitive = true
}

resource "azurerm_key_vault" "kv" {
  name                        = "${var.key_vault_name}-${var.suffix}"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = var.tenant_id
  sku_name                    = var.keyvault_sku
  soft_delete_retention_days  = var.keyvault_retention_days
  purge_protection_enabled    = var.keyvault_purge_protection
  enabled_for_disk_encryption = var.keyvault_disk_encryption
  enabled_for_deployment      = var.keyvault_deployment

  access_policy {
    tenant_id = var.tenant_id
    object_id = var.object_id
    key_permissions         = ["Get","List","Create","Delete","Update","Recover","Purge"]
    secret_permissions      = ["Get","List","Set","Delete","Recover","Purge"]
    certificate_permissions = ["Get","List","Create","Delete","Recover","Purge"]
  }

  tags = { Module = "KeyVault" }
}

resource "azurerm_key_vault_secret" "vm_password" {
  name         = "vm-admin-password"
  value        = var.vm_admin_password
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_key_vault.kv]
}

# Secrètes liées à l'environnement supprimées car l'environnement n'est plus passé

output "key_vault_name" { value = azurerm_key_vault.kv.name }
output "key_vault_id"   { value = azurerm_key_vault.kv.id }
output "key_vault_uri"  { value = azurerm_key_vault.kv.vault_uri }
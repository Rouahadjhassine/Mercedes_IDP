output "resource_group_name" {
  description = "Resource Group utilisé par le Key Vault"
  value       = data.azurerm_resource_group.rg.name
}

output "key_vault_name" {
  description = "Nom du Key Vault créé"
  value       = module.keyvault.key_vault_name
}

output "key_vault_uri" {
  description = "URI du Key Vault (pour les applications)"
  value       = module.keyvault.key_vault_uri
}

output "key_vault_id" {
  description = "ID du Key Vault"
  value       = module.keyvault.key_vault_id
}

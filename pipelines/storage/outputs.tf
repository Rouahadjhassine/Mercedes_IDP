output "resource_group_name" {
  description = "Resource Group utilisé par le Storage"
  value       = data.terraform_remote_state.rg.outputs.resource_group_name
}

output "storage_account_name" {
  description = "Nom du Storage Account créé"
  value       = module.storage.storage_account_name
}

output "storage_primary_endpoint" {
  description = "Endpoint principal du Storage Account"
  value       = module.storage.storage_primary_endpoint
}

output "storage_account_id" {
  description = "ID du Storage Account (utile pour les accès RBAC)"
  value       = module.storage.storage_account_id
}

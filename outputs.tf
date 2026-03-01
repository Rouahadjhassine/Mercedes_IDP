output "resource_group_name" {
  value = azurerm_resource_group.pfe_rg.name
}

output "vm_name" {
  value = module.vm.vm_name
}

output "vm_public_ip" {
  value = module.vm.vm_public_ip
}

output "vm_admin_username" {
  value = module.vm.vm_admin_username
}

output "storage_account_name" {
  value = module.storage.storage_account_name
}

output "storage_primary_endpoint" {
  value = module.storage.storage_primary_endpoint
}

output "key_vault_name" {
  value = module.keyvault.key_vault_name
}

output "key_vault_uri" {
  value = module.keyvault.key_vault_uri
}
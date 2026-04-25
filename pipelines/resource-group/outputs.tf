output "resource_group_name" {
  description = "Nom du Resource Group créé (lu par les autres pipelines via remote state)"
  value       = azurerm_resource_group.rg.name
}

output "resource_group_location" {
  description = "Région du Resource Group"
  value       = azurerm_resource_group.rg.location
}

output "resource_group_id" {
  description = "ID complet du Resource Group"
  value       = azurerm_resource_group.rg.id
}


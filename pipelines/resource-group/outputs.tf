output "resource_group_name" {
  description = "Nom du Resource Group créé (lu par les autres pipelines via remote state)"
  value       = azurerm_resource_group.rg.name
}

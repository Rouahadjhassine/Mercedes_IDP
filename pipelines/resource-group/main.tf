# Pipeline Resource Group – Crée uniquement le Resource Group Azure
# Tous les tags viennent des paramètres du pipeline (listes déroulantes)

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = coalesce(var.location, "West Europe")

  tags = {
    Environment        = coalesce(var.environment, "dev")
    Owner              = var.owner
    Project            = var.tag_project
    CostCenter         = var.tag_cost_center
    ManagedBy          = var.tag_managed_by
    Criticality        = var.tag_criticality
    DataClassification = var.tag_data_classification
    Pipeline           = "resource-group"
    CreatedBy          = "Azure-DevOps"
  }
}

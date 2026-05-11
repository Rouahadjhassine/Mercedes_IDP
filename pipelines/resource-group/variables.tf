variable "subscription_id" {
  description = "ID de la subscription Azure"
  type        = string
}

variable "environment" {
  description = "Environnement de déploiement (ex: dev, test, staging, prod, sandbox, poc)"
  type        = string
  default     = "dev"
  validation {
    condition     = var.environment == "" || contains(["dev", "test", "staging", "prod", "sandbox", "poc"], var.environment)
    error_message = "L'environnement doit être 'dev', 'test', 'staging', 'prod', 'sandbox', ou 'poc'."
  }
}

variable "resource_group_name" {
  description = "Nom exact du Resource Group à créer dans Azure"
  type        = string
  validation {
    condition     = length(var.resource_group_name) >= 1 && length(var.resource_group_name) <= 90
    error_message = "Le nom du Resource Group doit avoir entre 1 et 90 caractères."
  }
}

variable "location" {
  description = "Région Azure"
  type        = string
  default     = "West Europe"
}

variable "owner" {
  description = "Équipe propriétaire de la ressource"
  type        = string
  default     = "MIC-SECOPS"
}

variable "tag_project" {
  description = "Nom du projet"
  type        = string
  default     = "IDP-PFE"
}

variable "tag_cost_center" {
  description = "Centre de coût"
  type        = string
  default     = "MIC-001"
}

variable "tag_managed_by" {
  description = "Outil de gestion de l'infrastructure"
  type        = string
  default     = "Terraform"
}

variable "tag_criticality" {
  description = "Niveau de criticité de la ressource"
  type        = string
  default     = "Medium"
}

variable "tag_data_classification" {
  description = "Classification des données hébergées"
  type        = string
  default     = "Internal"
}

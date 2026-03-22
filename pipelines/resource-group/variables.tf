variable "subscription_id" {
  description = "ID de la subscription Azure"
  type        = string
}

variable "resource_group_name" {
  description = "Nom exact du Resource Group"
  type        = string
}

variable "environment" {
  description = "Environnement cible"
  type        = string
  default     = "dev"
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

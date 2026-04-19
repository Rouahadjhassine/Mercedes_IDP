variable "subscription_id" {
  description = "ID de la subscription Azure"
  type        = string
}

variable "prefix" {
  description = "Préfixe pour nommer le Resource Group (ex: mic-rg-dev)"
  type        = string
  default     = "mic"
  validation {
    condition     = length(var.prefix) >= 2 && length(var.prefix) <= 10
    error_message = "Le préfixe doit avoir entre 2 et 10 caractères (non vide)."
  }
}

variable "environment" {
  description = "Environnement cible"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "test", "staging", "prod", "sandbox", "poc"], var.environment)
    error_message = "Environnement invalide. Choix: dev | test | staging | prod | sandbox | poc"
  }
}

variable "location" {
  description = "Région Azure"
  type        = string
  default     = "West Europe"
  validation {
    condition     = length(var.location) > 0
    error_message = "La région Azure ne peut pas être vide."
  }
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

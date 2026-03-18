variable "subscription_id" {
  description = "ID de la subscription Azure"
  type        = string
}

variable "prefix" {
  description = "Préfixe pour nommer les ressources"
  type        = string
  default     = "mic"
}

variable "environment" {
  description = "Environnement cible (dev, test, staging, prod)"
  type        = string
  default     = "dev"
}

variable "storage_account_tier" {
  description = "Tier du storage account (Standard ou Premium)"
  type        = string
  default     = "Standard"
}

variable "storage_replication_type" {
  description = "Type de réplication (LRS, ZRS, GRS, GZRS)"
  type        = string
  default     = "LRS"
}

variable "storage_access_tier" {
  description = "Tier d'accès (Hot, Cool, Archive)"
  type        = string
  default     = "Hot"
}

variable "storage_kind" {
  description = "Kind du storage account"
  type        = string
  default     = "StorageV2"
}

variable "storage_retention_days" {
  description = "Jours de rétention pour les soft deletes"
  type        = number
  default     = 7
}

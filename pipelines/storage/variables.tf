variable "subscription_id" {
  description = "ID de la subscription Azure"
  type        = string
}

variable "resource_group_name" {
  description = "Nom du Resource Group cible"
  type        = string
}

variable "storage_account_name" {
  description = "Nom du compte de stockage (doit être unique)"
  type        = string
  validation {
    condition     = length(var.storage_account_name) >= 3 && length(var.storage_account_name) <= 24
    error_message = "Le nom du compte de stockage doit avoir entre 3 et 24 caractères."
  }
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

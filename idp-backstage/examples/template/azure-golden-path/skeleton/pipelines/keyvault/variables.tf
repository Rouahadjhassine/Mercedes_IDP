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

variable "keyvault_sku" {
  description = "SKU du Key Vault (standard ou premium)"
  type        = string
  default     = "standard"
}

variable "keyvault_retention_days" {
  description = "Jours de rétention soft delete"
  type        = number
  default     = 7
}

variable "keyvault_purge_protection" {
  description = "Activer la protection contre la suppression définitive"
  type        = bool
  default     = false
}

variable "keyvault_disk_encryption" {
  description = "Autoriser le chiffrement de disque"
  type        = bool
  default     = true
}

variable "keyvault_deployment" {
  description = "Autoriser le déploiement depuis le KV"
  type        = bool
  default     = true
}

variable "vm_admin_password" {
  description = "Mot de passe VM à stocker dans le Key Vault (optionnel)"
  type        = string
  sensitive   = true
  default     = ""
}

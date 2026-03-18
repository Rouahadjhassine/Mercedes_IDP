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

variable "location" {
  description = "Région Azure"
  type        = string
  default     = "West Europe"
}

variable "owner" {
  description = "Propriétaire du projet"
  type        = string
  default     = "MIC-SECOPS"
}

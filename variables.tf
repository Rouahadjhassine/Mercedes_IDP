variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "location" {
  description = "Région Azure"
  type        = string
  default     = "West Europe"
}

variable "prefix" {
  description = "Préfixe pour nommer les ressources"
  type        = string
  default     = "pfe"
}

variable "environment" {
  description = "Environnement: dev, test, prod"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Nom du responsable"
  type        = string
  default     = "etudiant-pfe"
}

variable "vm_size" {
  description = "Taille de la VM Azure"
  type        = string
  default     = "Standard_B2s"
}

variable "vm_admin_username" {
  description = "Nom d'utilisateur admin VM"
  type        = string
  default     = "adminpfe"
}

variable "vm_admin_password" {
  description = "Mot de passe admin VM"
  type        = string
  sensitive   = true
}
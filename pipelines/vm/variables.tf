variable "subscription_id" {
  description = "ID de la subscription Azure"
  type        = string
}

variable "prefix" {
  description = "Préfixe pour nommer les ressources"
  type        = string
  default     = "mic"
  validation {
    condition     = length(var.prefix) >= 2 && length(var.prefix) <= 10
    error_message = "Le préfixe doit avoir entre 2 et 10 caractères (non vide)."
  }
}

variable "environment" {
  description = "Environnement cible (dev, test, staging, prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "test", "staging", "prod", "sandbox", "poc"], var.environment)
    error_message = "Environnement invalide. Choix: dev | test | staging | prod | sandbox | poc"
  }
}

variable "vm_count" {
  description = "Nombre de VMs à créer"
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "Taille de la VM Azure"
  type        = string
  default     = "Standard_B2s"
}

variable "vm_os_type" {
  description = "Système d'exploitation (windows ou linux)"
  type        = string
  default     = "windows"
}

variable "vm_os_image" {
  description = "Image OS à utiliser"
  type        = string
  default     = "WindowsServer2022"
}

variable "vm_disk_type" {
  description = "Type de disque OS (Standard_LRS, Premium_LRS, etc.)"
  type        = string
  default     = "Standard_LRS"
}

variable "vm_admin_username" {
  description = "Nom d'utilisateur administrateur"
  type        = string
  default     = "azureadmin"
}

variable "vm_admin_password" {
  description = "Mot de passe administrateur"
  type        = string
  sensitive   = true
}

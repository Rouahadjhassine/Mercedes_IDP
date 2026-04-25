variable "subscription_id" {
  description = "ID de la subscription Azure"
  type        = string
}

variable "resource_group_name" {
  description = "Nom du Resource Group cible"
  type        = string
}

variable "vm_name" {
  description = "Nom de base de la Machine Virtuelle (max 15 caractères)"
  type        = string
  validation {
    condition     = length(var.vm_name) >= 1 && length(var.vm_name) <= 15
    error_message = "Le nom de la VM doit avoir entre 1 et 15 caractères."
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

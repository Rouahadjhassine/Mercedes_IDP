variable "subscription_id" {
  description = "Azure Subscription ID (fourni automatiquement par le pipeline)"
  type        = string
  default     = ""
}

variable "location" {
  description = "Région Azure | Choix: West Europe / North Europe / France Central / East US / UK South"
  type        = string
  default     = "West Europe"
  validation {
    condition = contains([
      "West Europe", "North Europe", "France Central",
      "East US", "East US 2", "West US",
      "UK South", "Germany West Central",
      "Southeast Asia", "Australia East"
    ], var.location)
    error_message = "Région invalide. Choix: West Europe | North Europe | France Central | East US | UK South"
  }
}

variable "prefix" {
  description = "Préfixe des ressources (2 à 10 caractères)"
  type        = string
  default     = "pfe"
  validation {
    condition     = length(var.prefix) >= 2 && length(var.prefix) <= 10
    error_message = "Le préfixe doit avoir entre 2 et 10 caractères."
  }
}

variable "environment" {
  description = "Environnement | Choix: dev / test / staging / prod"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "test", "staging", "prod"], var.environment)
    error_message = "Environnement invalide. Choix: dev | test | staging | prod"
  }
}

variable "owner" {
  description = "Responsable du projet"
  type        = string
  default     = "equipe-pfe"
}

# ============================================================
# VIRTUAL MACHINE
# ============================================================

variable "vm_count" {
  description = "Nombre de VMs | Choix: 1 / 2 / 3 / 5"
  type        = number
  default     = 1
  validation {
    condition     = contains([1, 2, 3, 5], var.vm_count)
    error_message = "Nombre de VMs invalide. Choix: 1 | 2 | 3 | 5"
  }
}

variable "vm_size" {
  description = <<EOT
Taille VM Azure. Choix disponibles:
  Standard_B1s    = 1  CPU | 1GB  RAM | dev léger
  Standard_B2s    = 2  CPU | 4GB  RAM | dev/test      ← défaut
  Standard_B4ms   = 4  CPU | 16GB RAM | moyen
  Standard_B8ms   = 8  CPU | 32GB RAM | grand
  Standard_D2s_v3 = 2  CPU | 8GB  RAM | usage général
  Standard_D4s_v3 = 4  CPU | 16GB RAM | usage général
  Standard_E2s_v3 = 2  CPU | 16GB RAM | mémoire
  Standard_F2s_v2 = 2  CPU | 4GB  RAM | calcul
EOT
  type    = string
  default = "Standard_B2s"
  validation {
    condition = contains([
      "Standard_B1s", "Standard_B2s", "Standard_B4ms", "Standard_B8ms",
      "Standard_D2s_v3", "Standard_D4s_v3", "Standard_D8s_v3",
      "Standard_E2s_v3", "Standard_E4s_v3",
      "Standard_F2s_v2", "Standard_F4s_v2"
    ], var.vm_size)
    error_message = "Taille VM invalide. Voir description pour les choix disponibles."
  }
}

variable "vm_os_type" {
  description = "Type OS | Choix: windows / linux"
  type        = string
  default     = "windows"
  validation {
    condition     = contains(["windows", "linux"], var.vm_os_type)
    error_message = "OS invalide. Choix: windows | linux"
  }
}

variable "vm_os_image" {
  description = <<EOT
Image OS. Choix disponibles:
  Windows:
    WindowsServer2022  ← défaut
    WindowsServer2019
    WindowsServer2016
  Linux:
    UbuntuServer2204
    UbuntuServer2004
    CentOS8
    RedHat9
EOT
  type    = string
  default = "WindowsServer2022"
  validation {
    condition = contains([
      "WindowsServer2022", "WindowsServer2019", "WindowsServer2016",
      "UbuntuServer2204",  "UbuntuServer2004",
      "CentOS8", "RedHat9"
    ], var.vm_os_image)
    error_message = "Image invalide. Voir description pour les choix disponibles."
  }
}

variable "vm_disk_type" {
  description = <<EOT
Type disque VM. Choix:
  Standard_LRS    = HDD standard  - moins cher     ← défaut
  StandardSSD_LRS = SSD standard  - équilibré
  Premium_LRS     = SSD premium   - haute perf
  UltraSSD_LRS    = SSD ultra     - très haute perf
EOT
  type    = string
  default = "Standard_LRS"
  validation {
    condition = contains([
      "Standard_LRS", "StandardSSD_LRS",
      "Premium_LRS",  "UltraSSD_LRS"
    ], var.vm_disk_type)
    error_message = "Type disque invalide. Choix: Standard_LRS | StandardSSD_LRS | Premium_LRS | UltraSSD_LRS"
  }
}

variable "vm_admin_username" {
  description = "Nom utilisateur admin VM (4 à 20 caractères)"
  type        = string
  default     = "adminpfe"
  validation {
    condition     = length(var.vm_admin_username) >= 4 && length(var.vm_admin_username) <= 20
    error_message = "Username doit avoir entre 4 et 20 caractères."
  }
}

variable "vm_admin_password" {
  description = "Mot de passe admin VM (fourni par le pipeline - secret)"
  type        = string
  sensitive   = true
  default     = "P@ssw0rdPFE2024!"
}

# ============================================================
# STORAGE ACCOUNT
# ============================================================

variable "storage_account_tier" {
  description = "Tier Storage | Choix: Standard / Premium"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "Tier invalide. Choix: Standard | Premium"
  }
}

variable "storage_replication_type" {
  description = <<EOT
Réplication Storage. Choix:
  LRS    = 3 copies même datacenter              ← défaut
  ZRS    = 3 copies 3 zones même région
  GRS    = copies dans 2 régions différentes
  GZRS   = ZRS + GRS combinés
  RAGRS  = GRS + lecture région secondaire
  RAGZRS = GZRS + lecture région secondaire
EOT
  type    = string
  default = "LRS"
  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "GZRS", "RAGRS", "RAGZRS"], var.storage_replication_type)
    error_message = "Réplication invalide. Choix: LRS | ZRS | GRS | GZRS | RAGRS | RAGZRS"
  }
}

variable "storage_access_tier" {
  description = <<EOT
Tier accès Storage. Choix:
  Hot     = accès fréquent    ← défaut
  Cool    = accès rare
  Archive = archivage longue durée
EOT
  type    = string
  default = "Hot"
  validation {
    condition     = contains(["Hot", "Cool", "Archive"], var.storage_access_tier)
    error_message = "Access tier invalide. Choix: Hot | Cool | Archive"
  }
}

variable "storage_kind" {
  description = <<EOT
Type Storage. Choix:
  StorageV2         = recommandé, supporte tout  ← défaut
  Storage           = usage général ancien
  BlobStorage       = blobs uniquement
  FileStorage       = fichiers uniquement
  BlockBlobStorage  = blobs haute performance
EOT
  type    = string
  default = "StorageV2"
  validation {
    condition = contains([
      "Storage", "StorageV2", "BlobStorage",
      "FileStorage", "BlockBlobStorage"
    ], var.storage_kind)
    error_message = "Kind invalide. Choix: Storage | StorageV2 | BlobStorage | FileStorage | BlockBlobStorage"
  }
}

variable "storage_retention_days" {
  description = "Jours rétention fichiers supprimés (1 à 365)"
  type        = number
  default     = 7
  validation {
    condition     = var.storage_retention_days >= 1 && var.storage_retention_days <= 365
    error_message = "Rétention doit être entre 1 et 365 jours."
  }
}

# ============================================================
# KEY VAULT
# ============================================================

variable "keyvault_sku" {
  description = "SKU Key Vault | Choix: standard / premium"
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard", "premium"], var.keyvault_sku)
    error_message = "SKU invalide. Choix: standard | premium"
  }
}

variable "keyvault_retention_days" {
  description = "Jours rétention après suppression KV (7 à 90)"
  type        = number
  default     = 7
  validation {
    condition     = var.keyvault_retention_days >= 7 && var.keyvault_retention_days <= 90
    error_message = "Rétention doit être entre 7 et 90 jours."
  }
}

variable "keyvault_purge_protection" {
  description = "Protection suppression KV | false=dev/test | true=prod"
  type        = bool
  default     = false
}

variable "keyvault_disk_encryption" {
  description = "Autoriser chiffrement disques VM | true / false"
  type        = bool
  default     = true
}

variable "keyvault_deployment" {
  description = "Autoriser VMs à lire secrets | true / false"
  type        = bool
  default     = true
}
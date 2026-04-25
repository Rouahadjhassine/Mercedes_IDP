# Pipeline VM – Lit le Resource Group depuis le remote state du Pipeline 1
# et déploie la VM en utilisant le module ./modules/vm

# ---- Récupération des infos du Resource Group existant ----
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# ---- Module VM (réutilise le module existant) ----
module "vm" {
  source              = "../../modules/vm"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  vm_name             = var.vm_name

  vm_count          = var.vm_count
  vm_size           = var.vm_size
  vm_os_type        = var.vm_os_type
  vm_os_image       = var.vm_os_image
  vm_disk_type      = var.vm_disk_type
  vm_admin_username = var.vm_admin_username
  vm_admin_password = var.vm_admin_password
}

# Pipeline VM – Lit le Resource Group depuis le remote state du Pipeline 1
# et déploie la VM en utilisant le module ./modules/vm

# ---- Lecture du remote state du Pipeline Resource Group ----
data "terraform_remote_state" "rg" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "pfetfstate"
    container_name       = "tfstate"
    key                  = "resource-group.tfstate"
  }
}

# ---- Module VM (réutilise le module existant) ----
module "vm" {
  source              = "../../modules/vm"
  virtual_machine_name = var.virtual_machine_name
  environment         = data.terraform_remote_state.rg.outputs.environment
  location            = data.terraform_remote_state.rg.outputs.resource_group_location
  resource_group_name = data.terraform_remote_state.rg.outputs.resource_group_name

  vm_count          = var.vm_count
  vm_size           = var.vm_size
  vm_os_type        = var.vm_os_type
  vm_os_image       = var.vm_os_image
  vm_disk_type      = var.vm_disk_type
  vm_admin_username = var.vm_admin_username
  vm_admin_password = var.vm_admin_password
}

output "resource_group_name" {
  description = "Resource Group utilisé par la VM"
  value       = data.terraform_remote_state.rg.outputs.resource_group_name
}

output "vm_names" {
  description = "Noms des VMs créées"
  value       = module.vm.vm_name
}

output "vm_public_ips" {
  description = "Adresses IP publiques des VMs"
  value       = module.vm.vm_public_ip
}

output "vm_admin_username" {
  description = "Nom d'utilisateur administrateur"
  value       = module.vm.vm_admin_username
}

output "vm_ids" {
  description = "IDs des VMs créées (utile pour le Key Vault)"
  value       = module.vm.vm_id
}

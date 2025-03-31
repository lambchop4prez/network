module "assets" {
  source              = "./modules/assets"
  talos_version       = var.talos_version
  proxmox_target_node = var.proxmox_target_node
  # proxmox_storage_pool = var.proxmox_storage_pool

}

output "assets" {
  value = {
    schematics = module.assets.schematics
    # boot_disk  = module.assets.boot_disk
  }
}

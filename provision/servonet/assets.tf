module "assets" {
  source              = "./modules/assets"
  talos_version       = var.talos_version
  proxmox_target_node = var.proxmox_target_node
}

output "assets" {
  value = {
    schematics = module.assets.schematics
  }
}

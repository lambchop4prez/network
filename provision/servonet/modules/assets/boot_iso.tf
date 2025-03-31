data "talos_image_factory_urls" "this" {
  talos_version = var.talos_version
  schematic_id  = talos_image_factory_schematic.vm.id
  platform      = "nocloud"
}

resource "proxmox_virtual_environment_download_file" "boot_disk" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = var.proxmox_target_node
  url          = data.talos_image_factory_urls.this.urls.iso
  file_name    = "talos-${var.talos_version}-nocloud-amd64.iso"
}

output "boot_disk" {
  value = {
    proxmox = proxmox_virtual_environment_download_file.boot_disk
  }
}

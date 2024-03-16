resource "proxmox_virtual_environment_file" "talos_iso" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = var.proxmox_target_node

  source_file {
    path      = "https://github.com/siderolabs/talos/releases/download/${var.talos_version}/metal-amd64.iso"
    file_name = "talos-${var.talos_version}-metal-amd64.iso"
  }
}

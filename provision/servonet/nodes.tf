locals {
  controlplane_ips   = formatlist("10.4.32.5%s", range(0, length(random_id.controlplane_node_id)))
  controlplane_hosts = formatlist("tom-%s", random_id.controlplane_node_id[*].hex)
  controlplane_macs = [
    for id in random_id.controlplane_node_id : format("DE:AD:BE:EF:%s:%s", substr(id.hex, 0, 2), substr(id.hex, 2, 4))
  ]
}

resource "random_id" "controlplane_node_id" {
  byte_length = 2
  count       = var.controlplane_count
}

module "node" {
  source               = "./modules/node"
  count                = length(local.controlplane_hosts)
  common_tags          = var.common_tags
  boot_disk_id         = module.assets.boot_disk.proxmox.id
  bridge_interface     = var.proxmox_bridge_interface
  cores                = var.controlplane_cores
  hostname             = local.controlplane_hosts[count.index]
  ipv4_address         = local.controlplane_ips[count.index]
  ipv4_gateway         = var.cluster_gateway
  mac_address          = local.controlplane_macs[count.index]
  memory               = var.controlplane_memory
  opnsense_lan_subnet  = var.opnsense_lan_subnet
  proxmox_target_node  = var.proxmox_target_node
  proxmox_storage_pool = var.proxmox_storage_pool
  storage_size         = var.controlplane_storage_size
  vm_id                = "${var.proxmox_vm_prefix}${count.index}"
}

resource "proxmox_virtual_environment_vm" "controlplane" {
  name        = var.name
  description = "Servonet node"
  tags        = var.tags
  node_name   = var.proxmox_target_node
  vm_id       = "${var.proxmox_vm_prefix}${count.index}"

  agent {
    enabled = true
    timeout = "1s"
  }

  bios    = "seabios"
  machine = "q35"

  cpu {
    cores = var.cores
    type  = "host"
  }

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = var.proxmox_storage_pool
    interface    = "scsi0"
    size         = var.storage_size
    file_format  = "raw"
  }

  network_device {
    bridge      = var.proxmox_bridge_interface
    mac_address = local.controlplane_macs[count.index]
  }

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id = var.proxmox_storage_pool
    ip_config {
      ipv4 {
        address = "${local.controlplane_ips[count.index]}/16"
        gateway = var.cluster_gateway
      }
    }
  }
}

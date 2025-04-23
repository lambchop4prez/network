
resource "proxmox_virtual_environment_vm" "this" {
  name        = var.hostname
  description = "Servonet node"
  tags        = concat(var.common_tags, ["controlplane"])

  node_name = var.proxmox_target_node
  vm_id     = var.vm_id

  agent {
    enabled = true
    timeout = "10s"
  }

  bios    = "ovmf"
  machine = "q35"

  cpu {
    cores = var.cores
    type  = "host"
  }

  memory {
    dedicated = var.memory
    floating  = var.memory
  }

  cdrom {
    file_id = var.boot_disk_id
  }

  disk {
    datastore_id = var.proxmox_storage_pool
    interface    = "scsi0"
    file_format  = "raw"
    size         = var.storage_size
  }
  
  disk {
    datastore_id = "fio"
    interface = "scsi1"
    file_format = "raw"
    size = 900
  }

  efi_disk {
    datastore_id = var.proxmox_storage_pool
  }

  network_device {
    bridge      = var.bridge_interface
    mac_address = var.mac_address
  }

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id = var.proxmox_storage_pool
    ip_config {
      ipv4 {
        address = "${var.ipv4_address}/16"
        gateway = var.ipv4_gateway
      }
    }
  }
}

output "vm" {
  value = proxmox_virtual_environment_vm.this
}

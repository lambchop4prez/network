resource "proxmox_virtual_environment_vm" "server_init" {
  name        = local.server_hostnames[0]
  description = "Servonet node"
  tags        = ["servonet"]

  node_name = "gpc"
  vm_id     = 4200

  agent {
    enabled = true
  }

  bios = "seabios"

  clone {
    vm_id = var.server_template_id
  }

  cpu {
    cores = var.server_cores
    host  = true
  }

  disk {
    datastore_id = var.proxmox_storage_pool
    interface    = "scsi"
    size         = var.server_storage_size
  }

  initialization {
    datastore_id = var.proxmox_storage_pool
    ip_config {
      ipv4 {
        address = local.server_ips[0]
      }
    }
    user_account {
      password = data.vault_generic_secret.servonet.data["tom_password"]
      username = "tom"
    }


  }
}

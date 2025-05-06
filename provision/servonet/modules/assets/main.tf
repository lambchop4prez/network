terraform {
  required_version = ">= 1.0"
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "0.8.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.77.1"
    }
  }
}

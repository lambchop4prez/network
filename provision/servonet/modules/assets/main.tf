terraform {
  required_version = ">= 1.0"
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "0.9.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.85.1"
    }
  }
}

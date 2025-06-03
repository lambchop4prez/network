terraform {
  required_version = ">= 1.0"
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "0.8.1"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.78.1"
    }
  }
}

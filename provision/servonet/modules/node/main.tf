terraform {
  required_version = ">= 1.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.85.0"
    }
    opnsense = {
      source  = "browningluke/opnsense"
      version = "0.15.0"
    }
  }
}

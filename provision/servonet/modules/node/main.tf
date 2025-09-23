terraform {
  required_version = ">= 1.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.84.0"
    }
    opnsense = {
      source  = "browningluke/opnsense"
      version = "0.13.0"
    }
  }
}

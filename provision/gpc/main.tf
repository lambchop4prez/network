terraform {
  required_version = ">= 1.0"
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "4.6.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.73.1"
    }
  }
}

provider "proxmox" {
  endpoint = "https://${data.vault_generic_secret.proxmox.data["proxmox_host"]}/"
  username = data.vault_generic_secret.proxmox_auth.data["proxmox_username"]
  password = data.vault_generic_secret.proxmox_auth.data["proxmox_password"]
  insecure = data.vault_generic_secret.proxmox_auth.data["proxmox_allow_unverified_tls"]
  tmp_dir  = "/var/tmp"
}

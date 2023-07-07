terraform {
  required_providers {
    proxmox = {
      source = "terraform.local/telmate/proxmox"
      version = "2.9.15"
    }
  }

  required_version = ">= 0.14"
}

provider "proxmox" {
  pm_tls_insecure = true
  pm_api_url = "https://${data.vault_generic_secret.proxmox_auth.data["proxmox_host"]}:8006/api2/json"
  pm_user = data.vault_generic_secret.proxmox_auth.data["proxmox_user"]
  pm_password = data.vault_generic_secret.proxmox_auth.data["proxmox_password"]
  # pm_debug = true
  # pm_log_enable = true
  # pm_log_levels = {
  #   _default    = "debug"
  #   _capturelog = ""
  # }
}

provider "vault" {}
provider "cloudinit" {}

data "vault_generic_secret" "proxmox_auth" {
  path = "secrets/proxmox/auth/terraform"
}

data "vault_generic_secret" "servonet" {
  path = "secrets/servonet"
}

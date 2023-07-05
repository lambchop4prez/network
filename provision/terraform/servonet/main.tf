terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
  }

  required_version = ">= 0.14"
}

provider "proxmox" {
  pm_tls_insecure = true
  pm_api_url = "https://gpc.lan:8006/api2/json"
  pm_user = data.vault_generic_secret.proxmox_auth.data["proxmox_user"]
  pm_password = data.vault_generic_secret.proxmox_auth.data["proxmox_password"]
}

provider "vault" {}
provider "cloudinit" {}

data "vault_generic_secret" "proxmox_auth" {
  path = "secrets/proxmox/auth/terraform"
}

data "vault_generic_secret" "servonet" {
  path = "secrets/servonet"
}

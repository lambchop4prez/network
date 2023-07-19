terraform {
  required_providers {
    proxmox = {
      source = "terraform.local/telmate/proxmox"
      version = "2.9.15"
    }
    opnsense = {
      source = "terraform.local/gxben/opnsense"
      version = "0.3.2"
    }
    remote = {
      source = "tenstad/remote"
      version = "0.1.2"
    }
    flux = {
      source = "fluxcd/flux"
    }
    github = {
      source  = "integrations/github"
      version = ">=5.18.0"
    }
  }

  required_version = ">= 1.1.5"
}

provider "proxmox" {
  pm_tls_insecure = data.vault_generic_secret.proxmox_auth.data["proxmox_allow_unverified_tls"]
  pm_api_url = "https://${data.vault_generic_secret.proxmox_auth.data["proxmox_host"]}:8006/api2/json"
  pm_user = data.vault_generic_secret.proxmox_auth.data["proxmox_user"]
  pm_password = data.vault_generic_secret.proxmox_auth.data["proxmox_password"]
}

provider "opnsense" {
  uri = "https://${data.vault_generic_secret.opnsense_auth.data["opnsense_url"]}"
  user = data.vault_generic_secret.opnsense_auth.data["opnsense_user"]
  password = data.vault_generic_secret.opnsense_auth.data["opnsense_password"]
  allow_unverified_tls = data.vault_generic_secret.opnsense_auth.data["opnsense_allow_unverified_tls"]
}

provider "github" {
  owner = "lambchop4prez"
  token = data.vault_generic_secret.servonet.data["github_access_token"]
}

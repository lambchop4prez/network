terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.17.0"
    }
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.14"
    }
    opnsense = {
      source  = "xyhhx/opnsense"
      version = "0.3.1-rc2"
    }
    remote = {
      source  = "tenstad/remote"
      version = "0.1.2"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "1.0.1"
    }
    github = {
      source  = "integrations/github"
      version = ">=5.18.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }
  }

  required_version = ">= 1.1.5"
}

provider "proxmox" {
  pm_tls_insecure = data.vault_generic_secret.proxmox_auth.data["proxmox_allow_unverified_tls"]
  pm_api_url      = "https://${data.vault_generic_secret.proxmox_auth.data["proxmox_host"]}:8006/api2/json"
  pm_user         = data.vault_generic_secret.proxmox_auth.data["proxmox_user"]
  pm_password     = data.vault_generic_secret.proxmox_auth.data["proxmox_password"]
}

provider "opnsense" {
  uri                  = "https://${data.vault_generic_secret.opnsense_auth.data["opnsense_url"]}"
  user                 = data.vault_generic_secret.opnsense_auth.data["opnsense_user"]
  password             = data.vault_generic_secret.opnsense_auth.data["opnsense_password"]
  allow_unverified_tls = data.vault_generic_secret.opnsense_auth.data["opnsense_allow_unverified_tls"]
}

provider "github" {
  owner = "lambchop4prez"
  token = data.vault_generic_secret.servonet.data["github_access_token"]
}

terraform {
  required_version = ">= 1.0"
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "4.5.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.66.3"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.6.1"
    }
    opnsense = {
      source  = "terraform.local/gxben/opnsense"
      version = "0.3.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }
    github = {
      source  = "integrations/github"
      version = ">=5.18.0"
    }
    kustomization = {
      source  = "kbst/kustomization"
      version = "0.9.6"
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


provider "opnsense" {
  uri                  = "https://${data.vault_generic_secret.opnsense_auth.data["opnsense_url"]}"
  user                 = data.vault_generic_secret.opnsense_auth.data["opnsense_user"]
  password             = data.vault_generic_secret.opnsense_auth.data["opnsense_password"]
  allow_unverified_tls = data.vault_generic_secret.opnsense_auth.data["opnsense_allow_unverified_tls"]
}

provider "talos" {}

provider "github" {
  owner = "lambchop4prez"
}

provider "kustomization" {
  kubeconfig_raw = data.talos_cluster_kubeconfig.this.kubeconfig_raw
}

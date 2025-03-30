terraform {
  required_version = ">= 1.0"
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "4.7.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.73.2"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.7.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }
    github = {
      source  = "integrations/github"
      version = ">=5.18.0"
    }
    opnsense = {
      source  = "browningluke/opnsense"
      version = "0.11.0"
    }
    kustomization = {
      source  = "kbst/kustomization"
      version = "0.9.6"
    }
  }
}

provider "proxmox" {
  endpoint = "https://${var.proxmox_host}:8006/"
  username = var.proxmox_username
  password = var.proxmox_password
  insecure = true
  tmp_dir  = "/var/tmp"
}

provider "opnsense" {
  uri            = "https://${var.opnsense_host}"
  api_key        = var.opnsense_api_key
  api_secret     = var.opnsense_api_secret
  allow_insecure = var.opnsense_allow_insecure
}

provider "talos" {}

provider "github" {
  owner = "lambchop4prez"
}

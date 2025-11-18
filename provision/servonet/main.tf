terraform {
  required_version = ">= 1.0"
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "5.4.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.86.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.9.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.1.0"
    }
    github = {
      source  = "integrations/github"
      version = ">=5.18.0"
    }
    opnsense = {
      source  = "browningluke/opnsense"
      version = "0.16.0"
    }
    kustomization = {
      source  = "kbst/kustomization"
      version = "0.9.7"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "1.7.4"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.27"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.13.1"
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

provider "kubernetes" {
  host                   = module.cluster.kubernetes_client_configuration.host
  client_certificate     = base64decode(module.cluster.kubernetes_client_configuration.client_certificate)
  client_key             = base64decode(module.cluster.kubernetes_client_configuration.client_key)
  cluster_ca_certificate = base64decode(module.cluster.kubernetes_client_configuration.ca_certificate)
}

resource "tls_private_key" "flux" {
  algorithm = "ED25519"
}

provider "flux" {
  kubernetes = {
    host                   = module.cluster.kubernetes_client_configuration.host
    client_certificate     = base64decode(module.cluster.kubernetes_client_configuration.client_certificate)
    client_key             = base64decode(module.cluster.kubernetes_client_configuration.client_key)
    cluster_ca_certificate = base64decode(module.cluster.kubernetes_client_configuration.ca_certificate)
  }
  git = {
    url = "ssh://git@github.com/lambchop4prez/network.git"
    ssh = {
      username    = "git"
      private_key = tls_private_key.flux.private_key_pem
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = module.cluster.kubernetes_client_configuration.host
    client_certificate     = base64decode(module.cluster.kubernetes_client_configuration.client_certificate)
    client_key             = base64decode(module.cluster.kubernetes_client_configuration.client_key)
    cluster_ca_certificate = base64decode(module.cluster.kubernetes_client_configuration.ca_certificate)
  }
}

provider "kustomization" {
  kubeconfig_raw = module.cluster.kubeconfig
}

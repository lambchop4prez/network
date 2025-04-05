terraform {
  required_version = ">= 1.0"
  required_providers {
    github = {
      source  = "integrations/github"
      version = ">=5.18.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "1.5.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.27"
    }
    kustomization = {
      source  = "kbst/kustomization"
      version = "0.9.6"
    }
  }
}

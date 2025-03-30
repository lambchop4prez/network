terraform {
  required_version = ">= 1.0"
  required_providers {
    github = {
      source  = "integrations/github"
      version = ">=5.18.0"
    }
    kustomization = {
      source  = "kbst/kustomization"
      version = "0.9.6"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
  }
}

variable "kubernetes_client_configuration" {
  type = object({
    host               = string
    ca_certificate     = string
    client_certificate = string
    client_key         = string
  })
}
provider "helm" {
  kubernetes {
    host                   = var.kubernetes_client_configuration.host
    client_certificate     = base64decode(var.kubernetes_client_configuration.client_certificate)
    client_key             = base64decode(var.kubernetes_client_configuration.client_key)
    cluster_ca_certificate = base64decode(var.kubernetes_client_configuration.ca_certificate)
  }
}

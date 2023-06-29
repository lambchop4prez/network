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
  pm_user = var.pve_user
  pm_password = var.pve_password
}

provider "vault" {}

data "vault_secret_generic" "proxmox_auth" {
  path = "secret/terraform/proxmox"
}

data "vault_secret_generic" "proxmox_password" {
  path = "secret/proxmox/data/proxmox_password"
}

module "server-nodes" {

  for_each = var.server-nodes
  source = "./node"


  name = each.key
  ip = each.value
  cores = 2

  gateway = "10.4.1.1"
  bridge = "vmbr0"
  storage_size = "32G"
  storage_pool = "local-lvm"
  target_node = "gpc"
  pve_host = var.pve_host
  pve_user = data.vault_secret_generic.proxmox_auth.data["username"]
  pve_password = data.vault_secret_generic.proxmox_auth.data["password"]
  ciuser = "tom"
  cipassword_hashed = var.cipassword_hashed
}

module "agent-nodes" {

}


variable "pve_host" {
  type = string
}

variable "pve_user" {
  type = string
}

variable "pve_password" {
  type = string
  sensitive = true
}

variable "cipassword_hashed" {
  type = string
  sensitive = true
}

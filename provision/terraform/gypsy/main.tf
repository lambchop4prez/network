terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
  }

  required_version = ">= 0.12"
}

provider "proxmox" {
  pm_tls_insecure = true
  pm_api_url = "https://gypsy:8006/api2/json"
}

locals {
  macaddrs = [
    "1a:83:b1:6e:ca:26",
    "7a:9e:b7:26:20:ce"
  ]
}

module "servonet-cluster" {
  source = "./servonet-node"

  count = length(local.macaddrs)

  name = "tom-${count.index + 4}"
  ip = "10.4.88.12${count.index + 4}"
  macaddr = local.macaddrs[count.index]

  gateway = "10.4.20.1"
  bridge = "vmbr0"
  storage_size = "32G"
  storage_pool = "local-lvm"
  target_node = "gypsy"
  pve_host = var.pve_host
  pve_user = var.pve_user
  pve_password = var.pve_password
  ciuser = "tom"
  cipassword_hashed = var.cipassword_hashed
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

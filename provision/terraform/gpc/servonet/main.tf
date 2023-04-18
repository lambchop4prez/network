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
  pm_api_url = "https://gpc.lan:8006/api2/json"
  pm_user = var.pve_user
  pm_password = var.pve_password
}

locals {
    nodes = [
        {ip = "10.4.212.1", cpus = 2, storage_size = "32G"},
        # {ip = "10.4.212.2", cpus = 2, storage_size = "32G"},
        # {ip = "10.4.212.3", cpus = 2, storage_size = "32G"},
        # {ip = "10.4.212.4", cpus = 4, storage_size = "64G"},
        # {ip = "10.4.212.5", cpus = 4, storage_size = "64G"},
        # {ip = "10.4.212.6", cpus = 4, storage_size = "64G"}
    ]
}



module "servonet-cluster" {
  source = "./node"
  
  count = length(local.nodes)

  name = "tom-${count.index}"
  ip = local.nodes[count.index].ip
  cores = local.nodes[count.index].cpus

  gateway = "10.4.20.1"
  bridge = "vmbr0"
  storage_size = local.nodes[count.index].storage_size
  storage_pool = "local-lvm"
  target_node = "gpc"
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

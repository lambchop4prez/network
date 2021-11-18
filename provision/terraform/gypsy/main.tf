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

module "servonet-cluster" {
  source = "./servonet-node"

  for_each = {
    "tom-3" = "10.4.88.123"
    "tom-4" = "10.4.88.124"
    "tom-5" = "10.4.88.125"
    "tom-6" = "10.4.88.126"
  }

  name = each.key
  ip = each.value

  sshkeys = <<EOF
  ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBLXLbp5bWpHIQkEf/5yhLftPbp93DGMLW+8lsG+hcC5imyprs/xQ7hq7Oiok+51XZKcpom2p7zZ7uXXAdkPLz6s= tcosgriff@Rudy.local
  ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBLhQjJ5dDqq1bU26WDhy+GiyaiJ7TJR0+jHrgoG9gX37FTn+cE4hsaA9vDk0G1V9YgSM4xR1Aq9b1555TUudAbM= tmc@Tims-Mac-mini.lan
  EOF

  gateway = "10.4.20.1"
  bridge = "vmbr0"
  storage_size = "32G"
  storage_pool = "local-lvm"
  target_node = "gypsy"
  pve_host = var.pve_host
  pve_user = var.pve_user
  pve_password = var.pve_password
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

variable "ip" {
  description = "List of IPs for nodes"
  type = string
}

variable "name" {
  description = "prefix for node name"
  type = string
}

variable "cores" {
  description = "number of cores for each vm"
  type = number
  default = 2
}

variable "memory" {
  description = "Amount of memory for each node"
  type = number
  default = 2048
}

variable "gateway" {
  description = "gateway for cluster"
  type = string
}

variable "bridge" {
  description = "bridge for network"
  type = string
  default = "vmbr0"
}

variable "storage_size" {
  description = "amount of storage for each nodes"
  type = string
  default = "8G"
}

variable "storage_pool" {
  description = "storage pool for disk"
  type = string
  default = "local"
}

variable "target_node" {
  description = "node to deploy on"
  type = string
}

variable "template_name" {
  description = "template to use"
  type = string
  default = "ubuntu-ci"
}

variable "pve_host" {
  description = "proxmox host"
  type = string
}

variable "pve_user" {
  description = "proxmox user"
  type = string
}

variable "pve_password" {
  description = "proxmox password"
  type = string
  sensitive = true
}

variable "ciuser" {
  type = string
}

variable "cipassword_hashed" {
  type = string
  sensitive = true
}

variable "macaddr" {
  type = string
}
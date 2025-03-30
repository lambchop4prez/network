variable "proxmox_target_node" {
  type        = string
  description = "Compute node for proxmox provisioning."
  default     = "gpc-2"
}
variable "proxmox_storage_pool" {
  type = string
}
variable "boot_disk_id" {
  type = string
}
variable "vm_id" {
  type = string
}
variable "hostname" {
  type = string
}
variable "cores" {
  type    = number
  default = 4
}
variable "common_tags" {
  type    = list(string)
  default = []
}
variable "memory" {
  type    = number
  default = 8192
}
variable "storage_size" {
  type    = number
  default = 0
}
variable "bridge_interface" {
  type = string
}
variable "mac_address" {
  type = string
}
variable "ipv4_address" {
  type = string
}
variable "ipv4_gateway" {
  type = string
}
variable "opnsense_lan_subnet" {
  type = string
}

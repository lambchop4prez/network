variable "talos_version" {
  type = string
}
variable "proxmox_target_node" {
  type        = string
  description = "Compute node for proxmox provisioning."
  default     = "gpc-2"
}

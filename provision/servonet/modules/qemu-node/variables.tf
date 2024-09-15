###
# VM Parameters
###
variable "name" {
  type        = string
  description = "Name of the VM"
  default     = "tom-1.servonet.lan"
}

variable "tags" {
  type        = list(string)
  description = "Tags for the VM"
  default     = ["servonet"]
}

variable "cores" {
  type        = number
  description = "Number of vCPU cores to give to controlplane nodes"
  default     = 4
}

variable "memory" {
  type        = number
  description = "Amount of memory for controlplane nodes"
  default     = 8192
}

variable "storage_size" {
  type        = number
  description = "Disk size (in GB) for controlplane nodes"
  default     = 32
}

###
# Proxmox Variables
variable "proxmox_target_node" {
  type        = string
  description = "Compute node for proxmox provisioning."
  default     = "gpc"
}

variable "proxmox_bridge_interface" {
  type        = string
  description = "Bridge interface for provisioned nodes."
  default     = "vmbr0"
}

variable "proxmox_storage_pool" {
  type        = string
  description = "Storage pool for all disk images"
  default     = "fio"
}
variable "proxmox_vm_prefix" {
  type        = number
  description = "First three digits of the cluster's vmid"
  default     = 800
}

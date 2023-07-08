variable "server_count" {
  type = number
  description = "Number of server nodes to provision"
  default = 3
}

variable "agent_count" {
  type = number
  description = "Number of agent nodes to provision"
  default = 2
}

variable "vm_template" {
  type = string
  description = "VM Template to use for provisioning."
  default = "alpine-3.18"
}

variable server_cores {
  type = number
  description = "Number of vCPU cores to give to server nodes"
  default = 2
}

variable server_memory {
  type = number
  description = "Ammount of memory for server nodes"
  default = 2048
}

variable server_storage_size {
  type = string
  description = "Disk size for server nodes"
  default = "32G"
}

variable gateway {
  type = string
  description = "Network gateway for nodes"
  default = "10.4.1.1"
}

variable proxmox_target_node {
  type = string
  description = "Compute node for proxmox provisioning."
  default = "gpc"
}

variable proxmox_bridge_interface {
  type = string
  description = "Bridge interface for provisioned nodes."
  default = "vmbr0"
}

variable proxmox_storage_pool {
  type = string
  description = "Storage pool for all disk images"
  default = "local-lvm"
}

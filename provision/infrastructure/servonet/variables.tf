##
# Cluster
##
variable "cluster_name" {
  type        = string
  description = "Name of the cluster"
  default     = "servonet.lan"
}
variable "common_tags" {
  type        = list(string)
  description = "Common tags for all VMs"
  default     = ["talos", "servonet"]
}

###
# Versions
###
variable "talos_version" {
  type        = string
  description = "Found at https://github.com/siderolabs/talos/releases"
  default     = "v1.6.6"
}
variable "kubernetes_version" {
  type        = string
  description = "Found at https://github.com/siderolabs/kubelet/pkgs/container/kubelet"
  default     = "v1.29.2"
}
variable "qemu_guest_agent_version" {
  type        = string
  description = "Found at https://github.com/siderolabs/extensions/pkgs/container/qemu-guest-agent"
  default     = "8.2.2"
}
##
# Networking
##
variable "cluster_gateway" {
  type        = string
  description = "Network gateway for cluster"
  default     = "10.4.1.1"
}

variable "virtual_ip_address" {
  type        = string
  description = "Virtual IP Address to use for Kubernetes API"
  default     = "10.4.16.16"
}

##
# Controlplane
##
variable "controlplane_count" {
  type        = number
  description = "Number of controlplane nodes to provision"
  default     = 3
}

variable "controlplane_cores" {
  type        = number
  description = "Number of vCPU cores to give to controlplane nodes"
  default     = 4
}

variable "controlplane_memory" {
  type        = number
  description = "Amount of memory for controlplane nodes"
  default     = 6144
}

variable "controlplane_storage_size" {
  type        = number
  description = "Disk size (in GB) for controlplane nodes"
  default     = 32
}

##
# Workers
##
variable "workers" {
  type        = list(object({ cores : number, memory : number, storage : number, devices = list(string) }))
  description = "Specs for worker nodes"
  default = [{
    cores   = 4
    memory  = 6144
    storage = 32
    devices = ["nvme-1"]
    }, {
    cores   = 4
    memory  = 6144
    storage = 32
    devices = ["nvme-2"]
    }, {
    cores   = 4
    memory  = 6144
    storage = 32
    devices = ["tesla-p4"]
  }]
}

##
# Proxmox
##
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
  default     = "local-lvm"
}
variable "proxmox_vm_prefix" {
  type        = number
  description = "First three digits of the cluster's vmid"
  default     = 800
}

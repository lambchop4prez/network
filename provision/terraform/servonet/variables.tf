variable "cluster_domain" {
  type        = string
  description = "Domain name to use for the internal cluster"
  default     = "servonet.lan"
}

variable "server_count" {
  type        = number
  description = "Number of server nodes to provision"
  default     = 3
}

variable "agent_count" {
  type        = number
  description = "Number of agent nodes to provision"
  default     = 4
}

variable "vm_template" {
  type        = string
  description = "VM Template to use for provisioning."
  default     = "alpine-3.18"
}

variable "server_cores" {
  type        = number
  description = "Number of vCPU cores to give to server nodes"
  default     = 2
}

variable "server_memory" {
  type        = number
  description = "Amount of memory for server nodes"
  default     = 6144
}

variable "server_storage_size" {
  type        = string
  description = "Disk size for server nodes"
  default     = "32G"
}

variable "agent_cores" {
  type        = number
  description = "Number of vCPU cores to give to agent nodes"
  default     = 4
}

variable "agent_memory" {
  type        = number
  description = "Amount of memory for agent nodes"
  default     = 8196
}

variable "agent_storage_size" {
  type        = string
  description = "Disk size for agent nodes"
  default     = "64G"
}

variable "gateway" {
  type        = string
  description = "Network gateway for nodes"
  default     = "10.4.1.1"
}

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

variable "cluster_vip_address" {
  type        = string
  description = "IP Address for the cluster to advertize on."
  default     = "10.4.88.212"
}

variable "cluster_cidr" {
  type        = string
  description = "Address space for pod IPs."
  default     = "10.42.0.0/16"
}

variable "service_cidr" {
  type        = string
  description = "Adress space for service IPs"
  default     = "10.43.0.0/16"
}

variable "external_cidr" {
  type        = string
  description = "Address space for external IPs"
  default     = "10.10.100.0/24"
}

variable "bgp_router_address" {
  type        = string
  description = "IP Address for BGP router"
  default     = "10.4.1.1/16"
}

variable "bgp_router_asn" {
  type        = number
  description = "AS number for bgp router"
  default     = 65551
}

variable "bgp_node_asn" {
  type        = number
  description = "AS number for nodes"
  default     = 64512
}

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
  default     = ["k8s", "talos", "servonet"]
}

###
# Versions
###
variable "talos_version" {
  type        = string
  description = "Found at https://github.com/siderolabs/talos/releases"
  default     = "v1.9.5"
}
variable "kubernetes_version" {
  type        = string
  description = "Found at https://github.com/siderolabs/kubelet/pkgs/container/kubelet"
  default     = "v1.31.1"
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
  default     = 8192
}

variable "controlplane_storage_size" {
  type        = number
  description = "Disk size (in GB) for controlplane nodes"
  default     = 80
}

##
# Proxmox
##
variable "proxmox_target_node" {
  type        = string
  description = "Compute node for proxmox provisioning."
  default     = "gpc-2"
}

variable "proxmox_host" {
  type        = string
  description = "Hostname for proxmox"
  default     = "10.4.20.23"
}

variable "proxmox_bridge_interface" {
  type        = string
  description = "Bridge interface for provisioned nodes."
  default     = "vmbr0"
}
variable "proxmox_username" {
  type        = string
  description = "User to create vms."
  default     = "root"
}
variable "proxmox_password" {
  type        = string
  description = "Password for proxmox_username"
  sensitive   = true
}
variable "proxmox_storage_pool" {
  type        = string
  description = "Storage pool for all disk images"
  default     = "local-lvm"
}
variable "proxmox_vm_prefix" {
  type        = number
  description = "First three digits of the cluster's vmid"
  default     = 900
}

variable "opnsense_host" {
  type        = string
  description = "Hostname of OPNSense firewall"
  default     = "crow.lan"
}
variable "opnsense_api_key" {
  type        = string
  description = "OPNSense API Key"
}
variable "opnsense_api_secret" {
  type        = string
  description = "OPNSense API Secret"
  sensitive   = true
}
variable "opnsense_allow_insecure" {
  type        = bool
  description = "Allow self-signed cert for OPNSense"
  default     = false
}
variable "opnsense_lan_subnet" {
  type        = string
  description = "OPNSense LAN subnet id"
}
variable "bitwarden_token" {
  type        = string
  description = "Bitwarden Auth token"
  sensitive   = true
}
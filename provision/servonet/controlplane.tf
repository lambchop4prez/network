data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${local.controlplane_ips[0]}:6443"
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets

  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
}

data "talos_client_configuration" "this" {
  cluster_name         = "servonet.lan"
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = local.controlplane_ips
  endpoints            = local.controlplane_ips
}

resource "talos_machine_configuration_apply" "controlplane" {
  count                       = length(random_id.controlplane_node_id)
  depends_on                  = [proxmox_virtual_environment_vm.controlplane]
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = local.controlplane_ips[count.index]
  endpoint                    = local.controlplane_ips[count.index]
  config_patches = [
    templatefile("configs/global.yaml", { talos_version = var.talos_version, disk = "/dev/sda", qemu_guest_agent_version = var.qemu_guest_agent_version }),
    # templatefile("configs/qemu-guest.yaml", { qemu_guest_agent_version = var.qemu_guest_agent_version }),
    templatefile("configs/controlplane.yaml", { static_ip_address = local.controlplane_ips[count.index], virtual_ip_address = var.virtual_ip_address }),
    file("configs/cni.yaml"),
    # file("configs/intel-ucode.yaml")
  ]
}

resource "talos_machine_bootstrap" "controlplane" {
  # count = length(random_id.controlplane_node_id)
  depends_on           = [proxmox_virtual_environment_vm.controlplane, talos_machine_configuration_apply.controlplane]
  node                 = local.controlplane_ips[0]
  client_configuration = talos_machine_secrets.this.client_configuration
}

resource "opnsense_dhcp_static_map" "controlplane_static_lease" {
  count     = length(random_id.controlplane_node_id)
  interface = "lan"
  mac       = local.controlplane_macs[count.index]
  ipaddr    = local.controlplane_ips[count.index]
  hostname  = local.controlplane_hosts[count.index]
}

resource "proxmox_virtual_environment_vm" "controlplane" {
  depends_on  = [proxmox_virtual_environment_file.talos_iso]
  count       = length(random_id.controlplane_node_id)
  name        = local.controlplane_hosts[count.index]
  description = "Servonet node"
  tags        = concat(var.common_tags, ["controlplane"])

  node_name = var.proxmox_target_node
  vm_id     = "${var.proxmox_vm_prefix}${count.index}"

  agent {
    enabled = true
    timeout = "1s"
  }

  bios    = "seabios"
  machine = "q35"

  cpu {
    cores = var.controlplane_cores
    type  = "host"
  }

  memory {
    dedicated = var.controlplane_memory
  }

  disk {
    datastore_id = var.proxmox_storage_pool
    interface    = "scsi0"
    size         = var.controlplane_storage_size
    file_format  = "raw"
  }

  cdrom {
    enabled   = true
    file_id   = proxmox_virtual_environment_file.talos_iso.id
    interface = "ide0"
  }

  network_device {
    bridge      = var.proxmox_bridge_interface
    mac_address = local.controlplane_macs[count.index]
  }

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id = var.proxmox_storage_pool
    ip_config {
      ipv4 {
        address = "${local.controlplane_ips[count.index]}/16"
        gateway = var.cluster_gateway
      }
    }
  }
}

data "talos_cluster_kubeconfig" "this" {
  depends_on           = [talos_machine_bootstrap.controlplane]
  client_configuration = talos_machine_secrets.this.client_configuration
  # endpoint = keys(local.controlplane)[0]
  node = local.controlplane_ips[0]
}

data "talos_machine_configuration" "worker" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${local.controlplane_ips[0]}:6443"
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.this.machine_secrets

  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
}

resource "talos_machine_configuration_apply" "workers" {
  count                = length((random_id.worker_node_id))
  depends_on           = [proxmox_virtual_environment_vm.worker]
  client_configuration = talos_machine_secrets.this.client_configuration

  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = local.worker_ips[count.index]
  endpoint                    = local.worker_ips[count.index]
  config_patches = [
    templatefile("configs/global.yaml", { talos_version = var.talos_version, qemu_guest_agent_version = var.qemu_guest_agent_version })
  ]
}

resource "opnsense_dhcp_static_map" "worker_static_lease" {
  count     = length(random_id.worker_node_id)
  interface = "lan"
  mac       = local.worker_macs[count.index]
  ipaddr    = local.worker_ips[count.index]
  hostname  = local.worker_hosts[count.index]
}

resource "proxmox_virtual_environment_vm" "worker" {
  depends_on  = [proxmox_virtual_environment_file.talos_iso]
  count       = length(random_id.worker_node_id)
  name        = local.worker_hosts[count.index]
  description = "Servonet worker"
  tags        = concat(var.common_tags, ["worker"])

  node_name = var.proxmox_target_node
  vm_id     = "${var.proxmox_vm_prefix}${count.index + var.controlplane_count}"

  agent {
    enabled = true
    timeout = "1s"
  }

  bios    = "seabios"
  machine = "q35"

  cpu {
    cores = var.workers[count.index].cores
    type  = "host"
  }

  memory {
    dedicated = var.workers[count.index].memory
  }

  disk {
    datastore_id = var.proxmox_storage_pool
    interface    = "scsi0"
    size         = var.workers[count.index].storage
    file_format  = "raw"
  }

  cdrom {
    enabled   = true
    file_id   = proxmox_virtual_environment_file.talos_iso.id
    interface = "ide0"
  }

  network_device {
    bridge      = var.proxmox_bridge_interface
    mac_address = local.worker_macs[count.index]
  }

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id = var.proxmox_storage_pool
    ip_config {
      ipv4 {
        address = "${local.worker_ips[count.index]}/16"
        gateway = var.cluster_gateway
      }
    }
  }

  dynamic "hostpci" {
    for_each = {
      for k, v in var.workers[count.index].devices : k => v
    }
    content {
      device  = hostpci.key
      mapping = hostpci.value
      pcie    = true
    }
  }
}

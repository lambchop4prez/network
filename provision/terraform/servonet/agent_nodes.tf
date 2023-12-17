resource "proxmox_vm_qemu" "agent_nodes" {
  depends_on  = [proxmox_vm_qemu.server_init, proxmox_vm_qemu.server_nodes]
  count       = length(var.vm_agents)
  name        = local.agent_hostnames[count.index]
  desc        = "Servonet agent node"
  target_node = var.proxmox_target_node

  vmid = 4500 + count.index

  clone      = var.vm_agents[count.index]
  full_clone = false

  qemu_os = "l26"
  agent   = 1

  cores   = var.agent_cores
  sockets = 1
  memory  = var.agent_memory

  disk {
    type    = "scsi"
    storage = var.proxmox_storage_pool
    size    = var.agent_storage_size
  }

  network {
    model  = "virtio"
    bridge = var.proxmox_bridge_interface
  }

  ipconfig0 = "ip=${local.agent_ips[count.index]}/24,gw=${var.gateway}"

  os_type                 = "cloud-init"
  cicustom                = "user=local:snippets/${local.agent_hostnames[count.index]}.yml"
  cloudinit_cdrom_storage = var.proxmox_storage_pool
}

resource "opnsense_dhcp_static_map" "agent_static_leases" {
  count     = length(var.vm_agents)
  interface = "lan"
  mac       = proxmox_vm_qemu.agent_nodes[count.index].network[0].macaddr
  ipaddr    = local.agent_ips[count.index]
  hostname  = proxmox_vm_qemu.agent_nodes[count.index].name
}

resource "terraform_data" "agent_cloud_init_config" {
  count = length(var.vm_agents)

  connection {
    type        = "ssh"
    host        = data.vault_generic_secret.proxmox_auth.data["proxmox_host"]
    private_key = data.local_sensitive_file.ssh_key.content
  }

  provisioner "file" {
    content     = local.agent_userdata[count.index]
    destination = "/var/lib/vz/snippets/${local.agent_hostnames[count.index]}.yml"
  }
}

resource "proxmox_vm_qemu" "agent_nodes" {
  depends_on = [ proxmox_vm_qemu.server_init ]
  count = var.agent_count
  name = local.agent_hostnames[count.index]
  desc = "Servonet agent node"
  target_node = var.proxmox_target_node

  clone = var.vm_template
  full_clone = false

  qemu_os = "l26"
  agent = 1

  cores = var.agent_cores
  sockets = 1
  memory = var.agent_memory

  disk {
    type = "scsi"
    storage = var.proxmox_storage_pool
    size = var.agent_storage_size
  }

  network {
    model = "virtio"
    bridge = var.proxmox_bridge_interface
  }

  ipconfig0 = "ip=${local.agent_ips[count.index]}/24,gw=${var.gateway}"

  os_type = "cloud-init"
  cicustom = "user=local:snippets/${local.agent_hostnames[count.index]}.yml"
  cloudinit_cdrom_storage = var.proxmox_storage_pool
}

resource "opnsense_dhcp_static_map" "agent_static_leases" {
  count = var.agent_count
  interface = "lan"
  mac       = "${proxmox_vm_qemu.agent_nodes[count.index].network[0].macaddr}"
  ipaddr    = "${local.agent_ips[count.index]}"
  hostname  = "${proxmox_vm_qemu.agent_nodes[count.index].name}"
}


resource "terraform_data" "agent_cloud_init_config" {
  count = var.agent_count
  connection {
    type = "ssh"
    host = data.vault_generic_secret.proxmox_auth.data["proxmox_host"]
    private_key = data.local_sensitive_file.ssh_key.content
  }

  provisioner "file" {
    content = templatefile(
      "${path.module}/files/user-data.tpl",
      {
        exec = "agent"
        hostname = local.agent_hostnames[count.index]
        username = "tom"
        password = data.vault_generic_secret.servonet.data["tom_password"]
        ip = local.agent_ips[count.index]
        gateway = var.gateway
        ssh_key = data.local_sensitive_file.ssh_pub_key.content
        k3s_config = base64gzip(templatefile("${path.module}/files/k3s-agent.yaml.tpl",
        {
          hostname = local.agent_hostnames[count.index]
          k3s_token = random_password.k3s_token.result
          kube_vip_address = var.cluster_vip_address
          cluster_cidr = var.cluster_cidr
          service_cidr = var.service_cidr
        }))
      }
    )
    destination = "/var/lib/vz/snippets/${local.agent_hostnames[count.index]}.yml"
  }
}

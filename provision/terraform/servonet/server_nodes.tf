resource "proxmox_vm_qemu" "server_nodes" {
  depends_on = [ proxmox_vm_qemu.server_init ]
  count = var.server_count - 1
  name = local.server_hostnames[count.index + 1]
  desc = "Servonet node"
  target_node = var.proxmox_target_node

  clone = var.vm_template
  full_clone = false

  qemu_os = "l26"
  agent = 1

  cores = var.server_cores
  sockets = 1
  memory = var.server_memory

  disk {
    type = "scsi"
    storage = var.proxmox_storage_pool
    size = var.server_storage_size
  }

  network {
    model = "virtio"
    bridge = var.proxmox_bridge_interface
  }

  ipconfig0 = "ip=${local.server_ips[count.index + 1]}/24,gw=${var.gateway}"

  os_type = "cloud-init"
  cicustom = "user=local:snippets/${local.server_hostnames[count.index + 1]}.yml"
  cloudinit_cdrom_storage = var.proxmox_storage_pool
}

resource "opnsense_dhcp_static_map" "server_static_lease" {
  count = var.server_count - 1
  interface = "lan"
  mac       = proxmox_vm_qemu.server_nodes[count.index].network[0].macaddr
  ipaddr    = local.server_ips[count.index + 1]
  hostname  = proxmox_vm_qemu.server_nodes[count.index].name
}

resource "terraform_data" "server_cloud_init_config" {
  count = var.server_count - 1
  connection {
    type = "ssh"
    host = data.vault_generic_secret.proxmox_auth.data["proxmox_host"]
    private_key = data.local_sensitive_file.ssh_key.content
  }

  provisioner "file" {
    content = templatefile(
      "${path.module}/files/user-data.tpl",
      {
        exec = "server"
        hostname = local.server_hostnames[count.index + 1]
        username = "tom"
        password = data.vault_generic_secret.servonet.data["tom_password"]
        ip = local.server_ips[count.index + 1]
        gateway = var.gateway
        ssh_key = data.local_sensitive_file.ssh_pub_key.content
        k3s_config = base64gzip(templatefile("${path.module}/files/k3s-server.yaml.tpl",
        {
          cluster_domain = var.cluster_domain
          hostname = local.server_hostnames[count.index + 1]
          k3s_token = random_password.k3s_token.result
          kube_vip_address = var.cluster_vip_address
          cluster_cidr = var.cluster_cidr
          service_cidr = var.service_cidr
        }))
      }
    )
    destination = "/var/lib/vz/snippets/${local.server_hostnames[count.index + 1]}.yml"
  }
}

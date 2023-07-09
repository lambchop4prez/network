
resource "proxmox_vm_qemu" "server_init" {
  count = 1
  name = "tom-${random_id.server_node_id[0].hex}-1"
  desc = "Servonet node"
  target_node = var.proxmox_target_node

  clone = var.vm_template
  full_clone = false

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

  ipconfig0 = "ip=${local.server_ips[0]}/24,gw=${var.gateway}"

  os_type = "cloud-init"
  cicustom = "user=local:snippets/tom-${random_id.server_node_id[0].hex}-1.yml"
  cloudinit_cdrom_storage = var.proxmox_storage_pool

  # connection {
  #   type = "ssh"
  #   user = "tom"
  #   host = local.server_ips[0]
  #   private_key = file("~/.ssh/id_ecdsa")
  # }
  # provisioner "remote-exec" {
  #   inline = [
  #     "cloud-init modules --mode final"
  #   ]
  # }
}

resource "opnsense_dhcp_static_map" "dhcp1" {
  interface = "lan"
  mac       = "${proxmox_vm_qemu.server_init[0].network[0].macaddr}"
  ipaddr    = "${local.server_ips[0]}"
  hostname  = "${proxmox_vm_qemu.server_init[0].name}"
}


resource "null_resource" "cloud_init_config_file" {
  connection {
    type = "ssh"
    host = data.vault_generic_secret.proxmox_auth.data["proxmox_host"]
    private_key = file("~/.ssh/id_ecdsa")
  }

  provisioner "file" {
    content = templatefile(
      "${path.module}/files/user-data.tpl",
      {
        hostname = "tom-${random_id.server_node_id[0].hex}-1"
        username = "tom"
        password = data.vault_generic_secret.servonet.data["tom_password"]
        ip = local.server_ips[0]
        gateway = var.gateway
        k3s_config = base64gzip(templatefile("${path.module}/files/k3s-server.yaml.tpl",
        {
          hostname = "tom-${random_id.server_node_id[0].hex}-1"
          k3s_token = random_password.k3s_token.result
          kubevip_address = var.cluster_vip_address
          cluster_cidr = var.cluster_cidr
          service_cidr = var.service_cidr
        }))
        k3s_init_script = base64gzip(file("${path.module}/files/k3s-server-init.sh"))
      }
    )
    destination = "/var/lib/vz/snippets/tom-${random_id.server_node_id[0].hex}-1.yml"
  }
}

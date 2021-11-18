terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
  }
  
  required_version = ">= 0.12"
}

resource "null_resource" "cloud_init_config_file" {
  connection {
    type = "ssh"
    user = "${var.pve_user}"
    password = "${var.pve_password}"
    host = "${var.pve_host}"
  }

  provisioner "file" {
    content = "${templatefile("${path.module}/files/user-data.tpl", {hostname = "${var.name}", username = "tom", passwd = "$1$BWIRY.Mm$/WlHfoaOnobjEfKoVgPKI."})}"
    destination = "/var/lib/vz/snippets/${var.name}.yml"
  }
}


resource "proxmox_vm_qemu" "servonet-node" {
  depends_on = [
    null_resource.cloud_init_config_file
  ]

  name = "${var.name}"
  desc = "servonet node"
  target_node = "gypsy"

  clone = var.template_name

  cores = var.cores
  sockets = 1
  memory = 2048

  disk {
    type = "scsi"
    storage = var.storage_pool
    size = var.storage_size
  }

  network {
    model = "virtio"
    bridge = var.bridge
  }

  cicustom = "user=local:snippets/${var.name}.yml"
  cloudinit_cdrom_storage = var.storage_pool
  
  ssh_user = var.ssh_user

  os_type = "cloud-init"
  ipconfig0 = "ip=${var.ip}/16,gw=${var.gateway}"

  sshkeys = var.sshkeys
}
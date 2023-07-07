terraform {
  required_providers {
    proxmox = {
      source = "terraform.local/telmate/proxmox"
      version = "2.9.15"
    }
  }

  required_version = ">= 0.14"
}

# data "cloudinit_config" "user_data" {
#   gzip = false
#   base64_encode = false
#   part {
#     filename = "user-data"
#     content_type = "cloud-config"
#     content = templatefile(
#       "${path.module}/files/user-data.tpl",
#       {
#         hostname = local.hostname,
#         username = var.ciuser
#         password = var.ciuserpassword
#       }
#     )
#   }
  # part {
  #   filename = "k3s.yaml"
  #   content_type = "text/yaml"
  #   content = templatefile("${path.module}/files/k3s-server.yaml.tpl")
  # }
  # part {
  #   filename = "setup-k3s.sh"
  #   content_type = "text/x-shellscript"
  #   content = templatefile("${path.module}/files/setup-k3s.sh")
  # }
# }

# resource "proxmox_cloud_init_disk" "ci" {
#   name = local.hostname
#   pve_node = var.target_node
#   storage = "local-lvm"
#   meta_data = yamlencode({
#     instance_id = sha1(local.hostname)
#     local-hostname = local.hostname
#   })
#   user_data = yamlencode(data.cloudinit_config.user_data.rendered)
# }

resource "null_resource" "cloud_init_config_file" {
  connection {
    type = "ssh"
    host = var.pve_host
    private_key = file("~/.ssh/id_ecdsa")
  }

  provisioner "file" {
    content = templatefile(
      "${path.module}/files/user-data.tpl",
      {
        hostname = local.hostname,
        username = var.ciuser
        password = var.ciuserpassword
        ip = var.ip
        gateway = var.gateway
      }
    )
    destination = local.cloud_init_file_path
  }
}


resource "proxmox_vm_qemu" "servonet_node" {
  name = local.hostname
  desc = "Servonet node"
  target_node = var.target_node

  clone = var.template_name
  full_clone = false

  agent = 1

  cores = var.cores
  sockets = 1
  memory = var.memory

  disk {
    type = "scsi"
    storage = var.storage_pool
    size = var.storage_size
  }

  # disk {
  #   type = "scsi"
  #   media = "cdrom"
  #   storage = "local-lvm"
  #   volume = proxmox_cloud_init_disk.ci.id
  #   size = proxmox_cloud_init_disk.ci.size
  # }

  network {
    model = "virtio"
    bridge = var.bridge
  }


  os_type = "cloud-init"
  cicustom = "user=local:snippets/${local.hostname}.yml"
  cloudinit_cdrom_storage = "local-lvm"

}

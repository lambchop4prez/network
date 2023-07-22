
resource "proxmox_vm_qemu" "server_init" {
  count = 1
  name = local.server_hostnames[0]
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

  ipconfig0 = "ip=${local.server_ips[0]}/24,gw=${var.gateway}"

  os_type = "cloud-init"
  cicustom = "user=local:snippets/${local.server_hostnames[0]}.yml"
  cloudinit_cdrom_storage = var.proxmox_storage_pool
}

resource "opnsense_dhcp_static_map" "server_init_static_lease" {
  interface = "lan"
  mac       = "${proxmox_vm_qemu.server_init[0].network[0].macaddr}"
  ipaddr    = "${local.server_ips[0]}"
  hostname  = "${proxmox_vm_qemu.server_init[0].name}"
}

resource "terraform_data" "server_init_cloud_init_config" {
  connection {
    type = "ssh"
    host = data.vault_generic_secret.proxmox_auth.data["proxmox_host"]
    private_key = data.local_sensitive_file.ssh_key.content
  }

  provisioner "file" {
    content = templatefile(
      "${path.module}/files/user-data.init.tpl",
      {
        hostname = local.server_hostnames[0]
        username = "tom"
        password = data.vault_generic_secret.servonet.data["tom_password"]
        ip = local.server_ips[0]
        gateway = var.gateway
        ssh_key = data.local_sensitive_file.ssh_pub_key.content
        k3s_config = base64gzip(templatefile("${path.module}/files/k3s-server.init.yaml.tpl",
        {
          cluster_domain = var.cluster_domain
          hostname = local.server_hostnames[0]
          k3s_token = random_password.k3s_token.result
          kube_vip_address = var.cluster_vip_address
          cluster_cidr = var.cluster_cidr
          service_cidr = var.service_cidr
        }))
        pod_kube_vip = base64gzip(templatefile("${path.module}/manifests/pod-kube-vip.yaml.tpl",
        {
          kube_vip_address = var.cluster_vip_address
        }))
        cilium_helmchart = base64gzip(templatefile("${path.module}/manifests/custom-cilium-helmchart.yaml.tpl",
        {
          cluster_cidr = var.cluster_cidr
          kube_vip_address = var.cluster_vip_address
          service_cidr = var.service_cidr
        }))
        cilium_l2 = base64gzip(templatefile("${path.module}/manifests/custom-cilium-l2.yaml.tpl",
        {
          service_cidr = var.service_cidr
        }))
      }
    )
    destination = "/var/lib/vz/snippets/${local.server_hostnames[0]}.yml"
  }
}

data "remote_file" "kubeconfig" {
  depends_on = [ proxmox_vm_qemu.server_init, opnsense_dhcp_static_map.server_init_static_lease ]
  conn {
    host = local.server_ips[0]
    user = "tom"
    private_key = data.local_sensitive_file.ssh_key.content
  }
  path = "/etc/rancher/k3s/k3s.yaml"
}

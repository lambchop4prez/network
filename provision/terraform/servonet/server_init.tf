module "server_init" {
  source = "./node"
  ip = "10.4.88.101"
  cores = 2

  gateway = "10.4.1.1"
  bridge = "vmbr0"
  storage_size = "32G"
  storage_pool = "local-lvm"
  target_node = "gpc"
  # pve_host = var.pve_host
  # pve_user = data.vault_generic_secret.proxmox_auth.data["proxmox_username"]
  # pve_password = data.vault_generic_secret.proxmox_auth.data["proxmox_password"]
  ciuser = "tom"
  ciuserpassword = data.vault_generic_secret.servonet.data["tom_password"]
  cluster_token = random_password.k3s_token.result
}

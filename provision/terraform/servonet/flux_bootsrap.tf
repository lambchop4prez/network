
resource "tls_private_key" "flux" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "github_repository_deploy_key" "flux_deploy" {
  title      = "Flux"
  repository = "network"
  key        = tls_private_key.flux.public_key_openssh
  read_only  = "false"
}

provider "flux" {
  kubernetes = {
    host                   = local.kubeconfig.clusters[0].cluster["server"]
    client_certificate     = base64decode(local.kubeconfig.users[0].user["client-certificate-data"])
    client_key             = base64decode(local.kubeconfig.users[0].user["client-key-data"])
    cluster_ca_certificate = base64decode(local.kubeconfig.clusters[0].cluster["certificate-authority-data"])
  }
  git = {
    url = "ssh://git@github.com/lambchop4prez/network.git"
    ssh = {
      username    = "git"
      private_key = data.local_sensitive_file.ssh_key.content
    }
  }
}

resource "flux_bootstrap_git" "flux_bootstrap" {
  depends_on = [
    github_repository_deploy_key.flux_deploy,
    proxmox_vm_qemu.server_init,
    proxmox_vm_qemu.server_nodes,
    proxmox_vm_qemu.agent_nodes
  ]
  cluster_domain = "servonet.lan"
  path = "cluster"
}

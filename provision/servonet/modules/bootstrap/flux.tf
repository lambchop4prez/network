resource "kubernetes_namespace" "flux_system" {
  metadata {
    name = "flux-system"
  }

  lifecycle {
    ignore_changes = [metadata]

  }
}

resource "kubernetes_secret" "ssh_keypair" {
  metadata {
    name      = "flux-system"
    namespace = "flux-system"
  }

  type = "Opaque"

  data = {
    "identity.pub" = var.deploy_key
    "identity"     = var.deploy_private_key
    "known_hosts"  = join("\n", formatlist("github.com %s", data.github_ssh_keys.this.keys))
  }

  depends_on = [kubernetes_namespace.flux_system]
}

resource "flux_bootstrap_git" "this" {
  depends_on = [github_repository_deploy_key.flux_deploy, kubernetes_secret.ssh_keypair, helm_release.cilium]

  disable_secret_creation = true
  embedded_manifests      = true
  path                    = "cluster/"
  cluster_domain          = var.cluster_domain
}

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
    name      = "github-token"
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

resource "helm_release" "flux2" {
  repository = "https://fluxcd-community.github.io/helm-charts"
  chart      = "flux2"
  version    = "2.12.4"

  name      = "flux2"
  namespace = "flux-system"

  set {
    name  = "clusterDomain"
    value = var.cluster_domain
  }

  depends_on = [kubernetes_namespace.flux_system]
}

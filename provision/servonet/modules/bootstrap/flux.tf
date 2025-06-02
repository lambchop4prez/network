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

  depends_on = [kubernetes_namespace.flux_system, helm_release.cilium]
}

data "github_repository_file" "flux_operator_values" {
  repository = "network"
  branch     = "main"
  file       = "cluster/apps/flux-system/flux-operator/app/values.yaml"
}

resource "helm_release" "flux_operator" {
  chart      = "oci://ghcr.io/controlplaneio-fluxcd/charts/flux-operator"
  version    = "0.21.0"
  name       = "flux-operator"
  namespace  = "flux-system"
  values     = [data.github_repository_file.flux_operator_values.content]
  depends_on = [kubernetes_namespace.flux_system, helm_release.cilium]

  lifecycle {
    ignore_changes = [version]
  }
}


data "github_repository_file" "flux_instance_values" {
  repository = "network"
  branch     = "main"
  file       = "cluster/apps/flux-system/flux-operator/instance/values.yaml"
}

resource "helm_release" "flux_instance" {
  chart      = "oci://ghcr.io/controlplaneio-fluxcd/charts/flux-instance"
  version    = "0.22.0"
  name       = "flux-instance"
  namespace  = "flux-system"
  values     = [data.github_repository_file.flux_instance_values.content]
  depends_on = [helm_release.flux_operator, kubernetes_secret.ssh_keypair]

  lifecycle {
    ignore_changes = [version]
  }
}

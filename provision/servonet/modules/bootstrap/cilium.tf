data "github_repository_file" "config" {
  repository = "network"
  branch     = "main"
  file       = "cluster/apps/kube-system/cilium/app/values.yaml"
}

resource "helm_release" "cilium" {
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  name       = "cilium"
  namespace  = "kube-system"
  version    = "1.17.2"
  values     = [data.github_repository_file.config.content]
  wait       = true
  depends_on = [helm_release.prometheus_crds]

  lifecycle {
    ignore_changes = [version]
  }
}

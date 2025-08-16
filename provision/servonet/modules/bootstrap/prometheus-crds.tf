resource "helm_release" "prometheus_crds" {
  name             = "prometheus-operator-crds"
  namespace        = "monitoring"
  chart            = "oci://ghcr.io/prometheus-community/charts/prometheus-operator-crds"
  version          = "22.0.2"
  create_namespace = true

  lifecycle {
    ignore_changes = [version]
  }
}

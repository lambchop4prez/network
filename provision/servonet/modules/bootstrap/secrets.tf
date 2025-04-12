
resource "kubernetes_secret" "bitwarden_token" {
  metadata {
    name      = "bitwarden-access-token"
    namespace = "kube-system"
  }
  type = "Opaque"
  data = {
    "token" = var.bitwarden_token
  }

  depends_on = [kubernetes_namespace.flux_system, helm_release.cilium]
}

resource "kubernetes_secret" "step_ca" {
  metadata {
    name      = "step-ca"
    namespace = "kube-system"
  }
  type = "Opaque"
  data = {
    "caBundle" = var.step_ca_cert
  }
}

resource "kubernetes_secret" "bitwarden_token" {
  metadata {
    name      = "bitwarden-access-token"
    namespace = "kube-system"
  }
  type = "Opaque"
  data = {
    "token" = var.bitwarden_token
  }

  depends_on = [helm_release.cilium]
}

resource "kubernetes_namespace" "networking" {
  metadata {
    name = "networking"
  }

  lifecycle {
    ignore_changes = [metadata]
  }
  depends_on = [ helm_release.cilium ]
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
  depends_on = [kubernetes_namespace.networking]
}
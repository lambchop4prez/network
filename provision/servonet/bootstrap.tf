###
# Flux manifests deployment
data "kustomization_build" "flux" {
  path = "github.com/fluxcd/flux2/manifests/install?ref=v2.2.3"
}

resource "kustomization_resource" "flux_prio0" {
  for_each = data.kustomization_build.flux.ids_prio[0]
  manifest = (
    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(data.kustomization_build.flux.manifests[each.value])
    : data.kustomization_build.flux.manifests[each.value]
  )
}

resource "kustomization_resource" "flux_prio1" {
  depends_on = [kustomization_resource.flux_prio0]
  for_each   = data.kustomization_build.flux.ids_prio[1]
  manifest = (
    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(data.kustomization_build.flux.manifests[each.value])
    : data.kustomization_build.flux.manifests[each.value]
  )
  wait = true
  timeouts {
    create = "2m"
    update = "2m"
  }
}

resource "kustomization_resource" "flux_prio2" {
  depends_on = [kustomization_resource.flux_prio1]
  for_each   = data.kustomization_build.flux.ids_prio[2]
  manifest = (
    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(data.kustomization_build.flux.manifests[each.value])
    : data.kustomization_build.flux.manifests[each.value]
  )
}

###
# Cillium
data "kustomization_overlay" "cillium" {
  kustomize_options {
    enable_helm = true
    helm_path   = "helm"
  }
  helm_charts {
    name         = "cilium"
    version      = "1.15.1"
    repo         = "https://helm.cilium.io/"
    include_crds = true
  }
}

resource "kustomization_resource" "cillium_prio0" {
  for_each = data.kustomization_overlay.cillium.ids_prio[0]
  manifest = (
    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(data.kustomization_overlay.cillium.manifests[each.value])
    : data.kustomization_overlay.cillium.manifests[each.value]
  )
}

resource "kustomization_resource" "cillium_prio1" {
  depends_on = [kustomization_resource.cillium_prio0]
  for_each   = data.kustomization_overlay.cillium.ids_prio[1]
  manifest = (
    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(data.kustomization_overlay.cillium.manifests[each.value])
    : data.kustomization_overlay.cillium.manifests[each.value]
  )
  wait = true
  timeouts {
    create = "2m"
    update = "2m"
  }
}

resource "kustomization_resource" "cillium_prio2" {
  depends_on = [kustomization_resource.cillium_prio1]
  for_each   = data.kustomization_overlay.cillium.ids_prio[2]
  manifest = (
    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(data.kustomization_overlay.cillium.manifests[each.value])
    : data.kustomization_overlay.cillium.manifests[each.value]
  )
}

###
# Flux cluster deployment
resource "tls_private_key" "flux" {
  algorithm = "ED25519"
}

resource "github_repository_deploy_key" "flux_deploy" {
  title      = "Flux Deploy Key"
  repository = "network"
  key        = tls_private_key.flux.public_key_openssh
  read_only  = "false"
}

data "github_ssh_keys" "this" {}

data "kustomization_overlay" "repository" {
  resources = ["../../cluster/base/flux"]
  secret_generator {
    name      = "github-token"
    namespace = "flux-system"
    type      = "Opaque"
    literals = [
      "identity=${tls_private_key.flux.private_key_openssh}",
      "identity.pub=${tls_private_key.flux.public_key_openssh}",
      "known_hosts=${join("\n", formatlist("github.com %s", data.github_ssh_keys.this.keys))}"
    ]
  }
}

resource "kustomization_resource" "repository_prio0" {
  for_each = data.kustomization_overlay.repository.ids_prio[0]
  manifest = (
    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(data.kustomization_overlay.repository.manifests[each.value])
    : data.kustomization_overlay.repository.manifests[each.value]
  )
}

resource "kustomization_resource" "repository_prio1" {
  depends_on = [kustomization_resource.repository_prio0]
  for_each   = data.kustomization_overlay.repository.ids_prio[1]
  manifest = (
    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(data.kustomization_overlay.repository.manifests[each.value])
    : data.kustomization_overlay.repository.manifests[each.value]
  )
  wait = true
  timeouts {
    create = "2m"
    update = "2m"
  }
}

resource "kustomization_resource" "repository_prio2" {
  depends_on = [kustomization_resource.repository_prio1]
  for_each   = data.kustomization_overlay.repository.ids_prio[2]
  manifest = (
    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(data.kustomization_overlay.repository.manifests[each.value])
    : data.kustomization_overlay.repository.manifests[each.value]
  )
}

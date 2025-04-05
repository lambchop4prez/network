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

data "kustomization_overlay" "flux" {
  resources = [

    "github.com/lambchop4prez/network/cluster/apps/flux",
  ]
}

# first loop through resources in ids_prio[0]
resource "kustomization_resource" "p0" {
  for_each = data.kustomization_overlay.flux.ids_prio[0]

  manifest = (
    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(data.kkustomization_overlay.flux.manifests[each.value])
    : data.kustomization_overlay.flux.manifests[each.value]
  )
}

# then loop through resources in ids_prio[1]
# and set an explicit depends_on on kustomization_resource.p0
# wait 2 minutes for any deployment or daemonset to become ready
resource "kustomization_resource" "p1" {
  for_each = data.kustomization_overlay.flux.ids_prio[1]

  manifest = (
    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(data.kustomization_overlay.flux.manifests[each.value])
    : data.kustomization_overlay.flux.manifests[each.value]
  )
  wait = true
  timeouts {
    create = "2m"
    update = "2m"
  }

  depends_on = [kustomization_resource.p0]
}

# finally, loop through resources in ids_prio[2]
# and set an explicit depends_on on kustomization_resource.p1
resource "kustomization_resource" "p2" {
  for_each = data.kustomization_overlay.flux.ids_prio[2]

  manifest = (
    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(data.kustomization_overlay.flux.manifests[each.value])
    : data.kustomization_overlay.flux.manifests[each.value]
  )

  depends_on = [kustomization_resource.p1]
}

# data "kustomization_overlay" "this" {
#   resources = [
#     "github.com/lambchop4prez/network/tree/main/cluster/apps/kube-system/cilium/app",
#     # "github.com/fluxcd/flux2/manifests/install?ref=v2.5.1",
#   ]
#   secret_generator {
#     name = "github-token"
#     namespace = "flux-system"
#     literals = [
#       "identity=${tls_private_key.flux.private_key_openssh}",
#       "identity.pub=${tls_private_key.flux.public_key_openssh}",
#       "know_hosts=${join("\n", formatlist("github.com %s", data.github_ssh_keys.this.keys))}"
#     ]
#   }
# }

# # first loop through resources in ids_prio[0]
# resource "kustomization_resource" "p0" {
#   for_each = data.kustomization_overlay.this.ids_prio[0]

#   manifest = (
#     contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
#     ? sensitive(data.kustomization_overlay.this.manifests[each.value])
#     : data.kustomization_overlay.this.manifests[each.value]
#   )
# }

# # then loop through resources in ids_prio[1]
# # and set an explicit depends_on on kustomization_resource.p0
# # wait 2 minutes for any deployment or daemonset to become ready
# resource "kustomization_resource" "p1" {
#   for_each = data.kustomization_overlay.this.ids_prio[1]

#   manifest = (
#     contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
#     ? sensitive(data.kustomization_overlay.this.manifests[each.value])
#     : data.kustomization_overlay.this.manifests[each.value]
#   )
#   wait = true
#   timeouts {
#     create = "2m"
#     update = "2m"
#   }

#   depends_on = [kustomization_resource.p0]
# }

# # finally, loop through resources in ids_prio[2]
# # and set an explicit depends_on on kustomization_resource.p1
# resource "kustomization_resource" "p2" {
#   for_each = data.kustomization_overlay.this.ids_prio[2]

#   manifest = (
#     contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
#     ? sensitive(data.kustomization_overlay.this.manifests[each.value])
#     : data.kustomization_overlay.this.manifests[each.value]
#   )

#   depends_on = [kustomization_resource.p1]
# }

# data "talos_cluster_kubeconfig" "this" {
#   depends_on           = [talos_machine_bootstrap.controlplane]
#   client_configuration = talos_machine_secrets.this.client_configuration
#   # endpoint = keys(local.controlplane)[0]
#   node = var.controlplane_ips[0]
# }
resource "talos_cluster_kubeconfig" "this" {
  depends_on = [
    talos_machine_bootstrap.controlplane
  ]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.controlplane_ips[0]
}
output "kubeconfig" {
  value     = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive = true
}
output "kubernetes_client_configuration" {
  value     = talos_cluster_kubeconfig.this.kubernetes_client_configuration
  sensitive = true
}

output "cluster_summary" {
  description = "Cluster Summary."
  value = {
    servers = local.servers
  }
}
output "kubeconfig" {
  description = "Cluster kubeconfig file"
  sensitive = true
  value = local.kubeconfig
}

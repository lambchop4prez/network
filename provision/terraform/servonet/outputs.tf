output "cluster_summary" {
  description = "Cluster Summary."
  value = {
    servers = local.servers
    agents = local.agents
  }
}
output "kubeconfig" {
  description = "Cluster kubeconfig file"
  sensitive = true
  value = local.kubeconfig
}

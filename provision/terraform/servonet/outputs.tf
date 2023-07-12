output "cluster_summary" {
  description = "Cluster Summary."
  value = {
    servers = local.servers
  }
}

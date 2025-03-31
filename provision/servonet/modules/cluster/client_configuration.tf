data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = var.controlplane_ips
  endpoints            = var.controlplane_ips
}
output "talosconfig" {
  value = data.talos_client_configuration.this.talos_config
}

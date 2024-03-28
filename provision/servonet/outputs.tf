output "kubeconfig" {
  value     = data.talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive = true
}

output "talosconfig" {
  value     = data.talos_client_configuration.this.talos_config
  sensitive = true
}

output "identity" {
  value     = tls_private_key.flux.private_key_openssh
  sensitive = true
}

output "identity_pub" {
  value = tls_private_key.flux.public_key_openssh
}

output "known_hosts" {
  value = join("\n", formatlist("github.com %s", data.github_ssh_keys.this.keys))
}

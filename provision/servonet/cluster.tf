module "cluster" {
  depends_on         = [module.node]
  source             = "./modules/cluster"
  cluster_name       = var.cluster_name
  controlplane_ips   = local.controlplane_ips
  kubernetes_version = var.kubernetes_version
  schematic          = module.assets.schematics.vm
  talos_version      = var.talos_version
  virtual_ip_address = var.virtual_ip_address
  step_ca_cert       = data.tls_certificate.step.certificates[*].cert_pem
}

output "talosconfig" {
  value     = module.cluster.talosconfig
  sensitive = true
}

output "kubeconfig" {
  value     = module.cluster.kubeconfig
  sensitive = true
}

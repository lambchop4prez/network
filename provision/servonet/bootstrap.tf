resource "time_sleep" "wait_10_seconds" {
  create_duration = "20s"
  depends_on      = [module.cluster]
}
module "bootstrap" {
  source = "./modules/bootstrap"
  # cluster_domain     = var.cluster_name
  deploy_key         = tls_private_key.flux.public_key_openssh
  deploy_private_key = tls_private_key.flux.private_key_pem
  bitwarden_token    = var.bitwarden_token
  step_ca_cert       = data.tls_certificate.step.certificates[0].cert_pem
  depends_on         = [time_sleep.wait_10_seconds]
}

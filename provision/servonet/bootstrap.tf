resource "time_sleep" "wait_10_seconds" {
  create_duration = "10s"
}
module "bootstrap" {
  source                          = "./modules/bootstrap"
  kubernetes_client_configuration = module.cluster.kubernetes_client_configuration
  cluster_domain                  = var.cluster_name
  deploy_key                      = tls_private_key.flux.public_key_openssh
  deploy_private_key              = tls_private_key.flux.private_key_pem
  depends_on                      = [time_sleep.wait_10_seconds]
}

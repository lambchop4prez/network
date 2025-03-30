module "bootstrap" {
  source                          = "./modules/bootstrap"
  kubernetes_client_configuration = module.cluster.kubernetes_client_configuration
}

###
# Flux cluster deployment key
resource "github_repository_deploy_key" "flux_deploy" {
  title      = "Flux Deploy Key"
  repository = "network"
  key        = var.deploy_key
  read_only  = "false"
}
data "github_ssh_keys" "this" {}

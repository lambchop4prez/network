###
# Flux cluster deployment key
resource "tls_private_key" "flux" {
  algorithm = "ED25519"
}

resource "github_repository_deploy_key" "flux_deploy" {
  title      = "Flux Deploy Key"
  repository = "network"
  key        = tls_private_key.flux.public_key_openssh
  read_only  = "false"
}
# data "github_ssh_keys" "this" {}

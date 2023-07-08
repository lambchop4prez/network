provider "vault" {}

data "vault_generic_secret" "proxmox_auth" {
  path = "secrets/proxmox/auth/terraform"
}

data "vault_generic_secret" "servonet" {
  path = "secrets/servonet"
}

data "vault_generic_secret" "opnsense_auth" {
  path = "secrets/opnsense/auth/terraform"
}

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

data "local_sensitive_file" "ssh_key" {
  filename = "/Users/tmc/.ssh/id_ecdsa"
}

data "local_sensitive_file" "ssh_pub_key" {
  filename = "/Users/tmc/.ssh/id_ecdsa.pub"
}

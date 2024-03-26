data "vault_generic_secret" "proxmox" {
  path = "secrets/proxmox"
}
data "vault_generic_secret" "proxmox_auth" {
  path = "secrets/proxmox/auth/root"
}
data "vault_generic_secret" "opnsense_auth" {
  path = "secrets/opnsense/auth/terraform"
}
data "vault_generic_secret" "servonet" {
  path = "secrets/servonet"
}

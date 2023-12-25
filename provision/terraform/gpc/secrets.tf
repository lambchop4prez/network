data "vault_generic_secret" "proxmox" {
  path = "secrets/proxmox"
}
data "vault_generic_secret" "proxmox_auth" {
  path = "secrets/proxmox/auth/root"
}
data "vault_generic_secret" "packer_auth" {
  path = "secrets/proxmox/auth/packer"
}
data "vault_generic_secret" "terraform_auth" {
  path = "secrets/proxmox/auth/terraform"
}

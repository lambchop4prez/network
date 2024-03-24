resource "proxmox_virtual_environment_role" "packer" {
  role_id = "packer"

  privileges = local.packer_privileges
}

resource "proxmox_virtual_environment_role" "terraform" {
  role_id = "terraform"

  privileges = local.terraform_privileges
}

resource "proxmox_virtual_environment_user" "packer" {
  acl {
    path      = "/"
    propagate = true
    role_id   = proxmox_virtual_environment_role.packer.role_id
  }

  comment  = "Managed by Terraform"
  password = data.vault_generic_secret.packer_auth.data["proxmox_password"]
  user_id  = "packer@pve"
}

resource "proxmox_virtual_environment_user" "terraform" {
  acl {
    path      = "/"
    propagate = true
    role_id   = proxmox_virtual_environment_role.terraform.role_id
  }

  comment  = "Managed by Terraform"
  password = data.vault_generic_secret.terraform_auth.data["proxmox_password"]
  user_id  = "terraform@pve"
}

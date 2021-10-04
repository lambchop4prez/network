source "proxmox-iso" "ubuntu-base" {
  proxmos_url = "https://gypsy.lan"
  username = "${var.username}"
  token = "${var.api_token}"
  iso_file = "local:iso/${local.iso_file_ubuntu_2004}"
}
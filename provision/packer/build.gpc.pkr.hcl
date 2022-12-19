# packer {
#   required_plugins {
#     proxmox = {
#       version = ">= 1.1.0"
#       source  = "github.com/hashicorp/proxmox"
#     }
#   }
# }

build {
    name = "ubuntu-server-base"

    sources = ["source.proxmox.ubuntu-server"]
    # source "proxmox-iso.ubuntu-desktop" {}
    # source "proxmox-iso.windows-desktop" {}

}
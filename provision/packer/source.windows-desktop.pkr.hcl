# source "proxmox-iso" "windows-desktop" {
#     proxmox_url = "${var.proxmox_url}"
#     username = "${var.proxmox_username}"
#     password = "${var.proxmox_password}"
#     insecure_skip_tls_verify = true
#     node = "gpc"
#     iso_file = "local:/iso/Win10_22H2_English_x64.iso"
#     iso_checksum = ""
#     iso_storage_pool = "vmstorage"
#     floppy_files = [
#         "windows-desktop/autounattend.xml"
#     ]

#     vm_name = "windows-10"
#     os = "win10"
#     network_adapters = [
#         {
#             model = "virtio"
#             bridge = "vmbr0"
#         }
#     ]
#     disks = [
#         {

#         }
#     ]

# }
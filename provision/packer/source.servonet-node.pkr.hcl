source "proxmox-clone" "servonet-node" {
    proxmox_url = "${var.proxmox_url}"
    username = "${var.proxmox_username}"
    password = "${var.proxmox_password}"
    insecure_skip_tls_verify = "true"
    node = "${var.proxmox_node}"

}
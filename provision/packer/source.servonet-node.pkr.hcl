source "proxmox-clone" "servonet-node" {
    proxmox_url = "${var.proxmox_url}"
    username = "${var.proxmox_username}"
    password = "${var.proxmox_password}"
    insecure_skip_tls_verify = "true"
    node = "${var.proxmox_node}"
    vm_name = "servonet-node"
    vm_id = "9001"
    clone_vm = "ubuntu-server"
    full_clone = true

    sockets = "${var.vm_cpu_sockets}"
    cores = "${var.vm_cpu_cores}"
    memory = "${var.vm_mem_size}"
    cpu_type = "${var.vm_cpu_type}"

    additional_iso_files {
        cd_files = [
            "./servonet-node/meta-data",
            "./servonet-node/user-data"
        ]
        cd_label         = "cidata"
        iso_storage_pool = "local"
    }
    scsi_controller = "virtio-scsi-pci"
    os = "l26"
    vga {
        type = "std"
        memory = 32
    }
    network_adapters {
        model = "virtio"
        bridge = "vmbr0"
    }

    template_name = "servonet-node"
    template_description = "Base template for servonet"
    
    qemu_agent = "true"
    cloud_init = true
    cloud_init_storage_pool="local"

    communicator = "ssh"
    ssh_username = "ubuntu"
    ssh_password = "ubuntu"
    ssh_handshake_attempts = "20"
    ssh_timeout = "30m"
}
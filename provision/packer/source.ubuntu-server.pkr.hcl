source "proxmox" "ubuntu-server" {
    proxmox_url = "${var.proxmox_url}"
    username = "${var.proxmox_username}"
    password = "${var.proxmox_password}"
    insecure_skip_tls_verify = "true"
    node = "${var.proxmox_node}"

    vm_name = "ubuntu-server"
    vm_id = "9000"

    sockets = "${var.vm_cpu_sockets}"
    cores = "${var.vm_cpu_cores}"
    memory = "${var.vm_mem_size}"
    cpu_type = "${var.vm_cpu_type}"

    boot_command = [
        "c",
      "linux /casper/vmlinuz --- autoinstall ds='nocloud'",
      "<enter><wait10>",
      "initrd /casper/initrd",
      "<enter><wait10>",
      "boot<enter>"
    ]
    boot_wait = "7s"

    additional_iso_files {
        cd_files = ["${path.cwd}/ubuntu-server/meta-data", "${path.cwd}/ubuntu-server/user-data"]
        cd_label = "CIDATA"
        iso_storage_pool = "local"
    }
    
    iso_checksum = "file:https://releases.ubuntu.com/22.04.1/SHA256SUMS"
    iso_file = "local:iso/ubuntu-22.04.1-live-server-amd64.iso"
    
    os = "l26"
    vga {
        type = "std"
        memory = 32
    }

    network_adapters {
        model = "virtio"
        bridge = "vmbr0"
    }

    disks {
        storage_pool = "local-lvm"
        storage_pool_type = "lvm"
        type = "scsi"
        disk_size = "${var.vm_os_disk_size}"
        cache_mode = "none"
    }

    template_name = "ubuntu-server"
    template_description = "Base template for ubuntu servers"
    unmount_iso = "true"
    qemu_agent = "true"
    cloud_init = true

    communicator = "ssh"
    ssh_username = "tmc"
    ssh_handshake_attempts = "20"
    ssh_timeout = "1h30m"
}
packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

build {
    name = "base.ubuntu-server"
    sources = ["source.proxmox.ubuntu-server"]
    
    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo apt -y autoremove --purge",
            "sudo apt -y clean",
            "sudo apt -y autoclean",
            "sudo cloud-init clean",
            "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
            "sudo sync"
        ]
    }

    provisioner "file" {
        source = "99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }

    provisioner "shell" {
        inline = [
            "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg"
        ]
    }
}

build {
    name = "template.servonet-node"
    sources = ["source.proxmox-clone.servonet-node"]

    provisioner "shell" {
      inline = [
        "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done"
      ]
    }

    provisioner "ansible" {
        playbook_file = "../ansible/playbooks/servonet.yaml"
        user = "ubuntu"
        inventory_directory = "../ansible/inventory"
        inventory_file_template = "servonet ansible_host={{ .Host }} ansible_user=ubuntu ansible_port={{ .Port }}\n"
    }
}
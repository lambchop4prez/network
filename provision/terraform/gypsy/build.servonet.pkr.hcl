build {
  name = "Servonet Nodes"
  description = "Ubuntu VM nodes for Servonet cluster"

  source "source.proxmox.base-ubuntu-amd64" {
    name = "tom-3"
    boot_command = [
      "<enter><enter><f6><esc><wait>",
      "autoinstall ds=nocloud-net;seedfrom=http://{{ .HTTPIP }}:{{ .HTTPPort}}/servonet/tom-3",
      "<enter><wait>"
    ]
    boot_wait = "5s"
    cloud_init = true
  }

  # source "source.proxmox.base-ubuntu-amd64" {
  #   name = "tom-4"
  #   boot_command = [
  #     "<wait20>",
  #     "<enter><enter><f6><esc><wait>",
  #     "autoinstall ds=nocloud-net;seedfrom=http://{{ .HTTPIP }}:{{ .HTTPPort}}/servonet/tom-4",
  #     "<enter><wait>"
  #   ]
  #   boot_wait = "10s"
  # }
}
locals {
  server_ips = formatlist("10.4.88.10%s", range(0, var.server_count))

  servers = concat(
    [
      for key, server in proxmox_vm_qemu.server_init:
      {
        name = server.name
      }
    ]
  )

}

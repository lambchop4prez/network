locals {
  server_ips = formatlist("10.4.88.10%s", range(0, var.server_count))

  servers = concat(
    [
      for key, server in proxmox_vm_qemu.server_init:
      {
        hostname = server.name
        ip = local.server_ips[0]
        mac = server.network[0].macaddr
      }
    ],
    [
      for i, server in proxmox_vm_qemu.server_nodes:
      {
        hostname = server.name
        ip = local.server_ips[i + 1]
        mac = server.network[0].macaddr
      }
    ]
  )
}

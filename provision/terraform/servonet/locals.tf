locals {
  server_ips = formatlist("10.4.20.5%s", range(0, var.server_count))

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

  kubeconfig = sensitive(replace(data.remote_file.kubeconfig.content, "127.0.0.1", var.cluster_vip_address))
}

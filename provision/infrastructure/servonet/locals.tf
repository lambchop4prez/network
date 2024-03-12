locals {
  controlplane_ips   = formatlist("10.4.32.5%s", range(0, length(random_id.controlplane_node_id)))
  controlplane_hosts = formatlist("tom-%s", random_id.controlplane_node_id[*].hex)
  controlplane_macs = [
    for id in random_id.controlplane_node_id : format("DE:AD:BE:EF:%s:%s", substr(id.hex, 0, 2), substr(id.hex, 2, 4))
  ]
}

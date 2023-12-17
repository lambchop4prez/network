locals {
  server_ips = formatlist("10.4.20.5%s", range(0, length(random_id.agent_node_id)))
  agent_ips  = formatlist("10.4.20.6%s", range(0, length(random_id.agent_node_id)))

  server_hostnames = formatlist("tom-%s-%s", random_id.server_node_id[*].hex, range(1, var.server_count + 1))
  agent_hostnames  = formatlist("tom-%s-%s", random_id.agent_node_id[*].hex, range(var.server_count + 1, var.server_count + length(random_id.agent_node_id) + 1))

  agent_userdata = [
    for i, hostname in local.agent_hostnames :
    templatefile(
      "${path.module}/files/user-data.tpl",
      {
        exec     = "agent"
        hostname = hostname
        username = "tom"
        password = data.vault_generic_secret.servonet.data["tom_password"]
        ip       = local.agent_ips[i]
        gateway  = var.gateway
        ssh_key  = data.local_sensitive_file.ssh_pub_key.content
        k3s_config = base64gzip(templatefile("${path.module}/files/k3s-agent.yaml.tpl",
          {
            hostname         = hostname
            k3s_token        = random_password.k3s_token.result
            kube_vip_address = var.cluster_vip_address
            cluster_cidr     = var.cluster_cidr
            service_cidr     = var.service_cidr
        }))
      }
    )
  ]

  servers = concat(
    [
      for key, server in proxmox_vm_qemu.server_init :
      {
        hostname = server.name
        ip       = local.server_ips[0]
        mac      = server.network[0].macaddr
      }
    ],
    [
      for i, server in proxmox_vm_qemu.server_nodes :
      {
        hostname = server.name
        ip       = local.server_ips[i + 1]
        mac      = server.network[0].macaddr
      }
    ]
  )

  agents = [
    for i, agent in proxmox_vm_qemu.agent_nodes :
    {
      hostname = agent.name
      ip       = local.agent_ips[i]
      mac      = agent.network[0].macaddr
      # user-data = terraform_data.agent_cloud_init_config[i].rendered
    }
  ]

  kubeconfig = sensitive(yamldecode(replace(data.remote_file.kubeconfig.content, "127.0.0.1", var.cluster_vip_address)))
}

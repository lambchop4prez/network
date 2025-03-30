data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.controlplane_ips[0]}:6443"
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets

  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
}

resource "talos_machine_configuration_apply" "controlplane" {
  count                       = length(var.controlplane_ips)
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = var.controlplane_ips[count.index]
  endpoint                    = var.controlplane_ips[count.index]
  config_patches = [
    yamlencode({
      cluster = {
        network = {
          dnsDomain = var.cluster_name
          cni = {
            name = "none"
          }
        }
        proxy = {
          disabled = true
        }
      }

      machine = {
        features = {
          kubePrism = {
            enabled = true
            port    = 7445
          }
        }
        network = {
          interfaces = [
            {
              deviceSelector = {
                hardwareAddr : "DE:AD:BE:EF:*"
              }
              vip = {
                ip = var.virtual_ip_address
              }
              addresses = [var.controlplane_ips[count.index]]
            }
          ]
        }
        install = {
          disk  = "/dev/sda"
          image = "factory.talos.dev/installer/${var.schematic}:${var.talos_version}"
        }
      }
    })
  ]
}

resource "talos_machine_bootstrap" "controlplane" {
  depends_on           = [talos_machine_configuration_apply.controlplane]
  node                 = var.controlplane_ips[0]
  client_configuration = talos_machine_secrets.this.client_configuration
}

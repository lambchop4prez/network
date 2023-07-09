# Servonet K3s cluster

This is a HA Kubernetes cluster running a server across 3 VMs. The intent is to allow agent nodes to join as needed.

## Features

- [ ] Server Init
- [ ] Highly Available Control plane
- [ ] Virtual agent nodes
- [ ] Bare-metal agent node provisioning (PXE boot?)

## CloudInit

`cloud-init status --long`
`cloud-init analyze show`

Right now, cloud-init doesn't seem to run the finalize step. This can be run with `cloud-init module --mode final`

## References

- https://github.com/Telmate/terraform-provider-proxmox
- https://github.com/aigisuk/terraform-digitalocean-ha-k3s

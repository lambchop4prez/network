# Servonet K3s cluster

This is a HA Kubernetes cluster running a server across 3 VMs. The intent is to allow agent nodes to join as needed.

## Features

- [ ] Server Init
- [ ] Highly Available Control plane
- [ ] Virtual agent nodes
- [ ] Bare-metal agent node provisioning (PXE boot?)

## Components

### K3s

## CloudInit

`cloud-init status --long`
`cloud-init analyze show`

Right now, cloud-init doesn't seem to run the finalize step. This can be run with `cloud-init modules --mode final`

- https://cloudinit.readthedocs.io/en/latest/reference/modules.html#

## References

- https://docs.k3s.io/
- https://github.com/Telmate/terraform-provider-proxmox
- https://github.com/aigisuk/terraform-digitalocean-ha-k3s
- https://github.com/onedr0p/flux-cluster-template/tree/main

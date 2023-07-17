# Servonet K3s cluster

This module currently provisions a single node k3s cluster, running on Alpine Linux with cloud-init to prepare the operating system. Once the VM is provisioned, a static IP mapping is created in OPNSense.

## Current limitations

The cloud-final modules aren't being run in cloud-init. This is because when the machine boots, the `cloud-final` service is in a "stopped" mode at boot. This configuration is used to setup the user, and most importantly to bootstrap k3s. In order to bootstrap the cluster, you need to run `rc-service cloud-final restart` for the modules to run. This could be provisioned over ssh, but for some reason ssh doesn't seem to be working either.

## Features

- [x] Server Init
- [x] Highly Available Control plane
- [ ] Virtual agent nodes
- [ ] Bare-metal agent node provisioning

## CloudInit

`cloud-init status --long`
`cloud-init analyze show`

~~Right now, cloud-init doesn't seem to run the finalize step. This can be run with `cloud-init modules --mode final`~~

- https://cloudinit.readthedocs.io/en/latest/reference/modules.html#
- https://gitlab.alpinelinux.org/alpine/aports/-/blob/master/community/cloud-init/README.Alpine

## Kubeconfig

The kubeconfig file is pulled from the first server node and modified to point to the kube_vip address. This file can be output from the terraform state with the following command.

`terraform output -raw kubeconfig > kubeconfig_file_path`

## References

- https://docs.k3s.io/
- https://github.com/Telmate/terraform-provider-proxmox
- https://github.com/aigisuk/terraform-digitalocean-ha-k3s
- https://github.com/onedr0p/flux-cluster-template/tree/main

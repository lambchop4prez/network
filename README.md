# Network

[![.github/workflows/ci.yaml](https://github.com/lambchop4prez/network/actions/workflows/ci.yaml/badge.svg)](https://github.com/lambchop4prez/network/actions/workflows/ci.yaml)

Infrastructure as code for my network.

## Cluster

Kubernetes workloads deployed using [FluxCD](https://fluxcd.io).

## Provisioning

### Playbooks

The following [Ansible](https://ansible.com) playbooks are defined for various purposes.

#### GPC

GPC is a single-node [Proxmox](https://proxmox.com) instance which acts as both a Hypervisor and NAS.

#### Cambot

Kodi-based media centers running on a pair of ODroid N2+'s. Automatically installs plugins, sets up Youtube API keys, and an NFS share to media storage.

### Terraform Modules

#### Servonet

Kubernetes cluster running on proxmox VM nodes. Bootstraps the cluster with Alpine VM Templates and cloud-init.

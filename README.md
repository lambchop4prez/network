# Network

Infrastructure as code for my network.

## Playbooks

The following Ansible playbooks are defined for various purposes.

### Workstations

This keeps my Macbook and Mac Mini synchronized in terms of installed applications and configuration.

To quickly run the playbook, run:

```sh
task playbook:workstation -- --limit 'workstation:<host>'
```

### GPC

GPC is a single-node proxmox instance which acts as both a Hypervisor and NAS.

### Cambot

Kodi-based media centers running on a pair of ODroid N2+'s. Automatically installs plugins, sets up Youtube API keys, and an NFS share to media storage.

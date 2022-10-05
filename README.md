# Network

Infrastructure as code for my network.

## Robot Roll Call

### Cambot

ODroid H2 running OSMC

### Gypsy

Intel Xeon LGA1155 running Proxmox

10Tb ZFS RaidZ storage array (5x3Tb)

### Tom Servo

6 Node HA Kubernetes Cluster

3x Rasbperry Pi 4 8Gb
1x Zotak zBox 8Gb
2x Virtual 

### Croooooooooow

Generic Intel(R) Celeron(R) CPU J1900 @ 1.99GHz board running pfsense

## Additional systems

### Workstations

Install python with homebrew
Install ansible with pip
No direnv yet, so export ansible.cfg
`export ANSIBLE_CONFIG=./ansible.cfg`
`ansible-galaxy install -r ./provision/ansible/requirements.yaml`

Run the playbook

`ansible-playbook ./provision/ansible/workstation.yaml --ask-become-pass`


### Terraform

**Gypsy** Intel Xeon LGA1155 running Proxmox


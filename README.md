# Home Network

Infrastructure as code for my network.

## Provisioning

### Ansible

#### Workstations

Install python with homebrew
Install ansible with pip
No direnv yet, so export ansible.cfg
`export ANSIBLE_CONFIG=./ansible.cfg`
`ansible-galaxy install -r ./provision/ansible/requirements.yaml`

Run the playbook

`ansible-playbook ./provision/ansible/workstation.yaml --ask-become-pass`


### Terraform

**Gypsy** Intel Xeon LGA1155 running Proxmox


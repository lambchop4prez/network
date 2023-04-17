#cloud-config

# This is the user-data configuration file for cloud-init. By default this sets
# up an initial user called "ubuntu" with password "ubuntu", which must be
# changed at first login. However, many additional actions can be initiated on
# first boot from this file. The cloud-init documentation has more details:
#
# https://cloudinit.readthedocs.io/
#
# Some additional examples are provided in comments below the default
# configuration.
hostname: ${hostname}
manage_etc_hosts: true
locale: en_US.UTF-8
timezone: America/Detroit

# Disable password authentication with the SSH daemon
ssh_pwauth: false

users:
- name: ${username}
  gecos: Tom Servo
  primary_group: robot
  groups: sudo
  passwd: ${passwd}
  sudo: "ALL=(ALL) NOPASSWD:ALL"
  ssh_import_id: gh:lambchop4prez
  shell: /bin/bash

## Update apt database and upgrade packages on first boot
package_update: true
package_upgrade: true

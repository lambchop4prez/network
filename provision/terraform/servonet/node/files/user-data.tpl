#cloud-config

hostname: ${hostname}.lan
manage_etc_hosts: true
locale: en_US.UTF-8
timezone: America/Detroit

ssh_pwauth: false

mounts:
  - ["cgroup", "/sys/fs/cgroup", "cgroup", "defaults", "0", "0"]

users:
  - name: ${username}
    gecos: Tom Servo
    groups: sudo, robot
    create_groups: true
    plain_text_passwd: ${password}
    sudo: "ALL=(ALL) NOPASSWD:ALL"
    # ssh_import_id: gh:lambchop4prez
    # shell: /bin/bash

apk_repos:
  preserve_repositories: true
  alpine_repo:
    base_url: http://dl-cdn.alpinelinux.org/alpine
    testing_enabled: true
    version: edge


packages:
  - bash
  - sudo
  - iptables
  - cni-plugins

write_files:
  - path: /etc/network/interfaces
    content: |
      auto lo
      iface lo inet loopback

      auto eth0
      iface eth0 inet dhcp
  - path: /etc/cgconfig.conf
    content: |
      mount {
        cpuacct = /cgroup/cpuacct;
        memory = /cgroup/memory;
        devices = /cgroup/devices;
        freezer = /cgroup/freezer;
        net_cls = /cgroup/net_cls;
        blkio = /cgroup/blkio;
        cpuset = /cgroup/cpuset;
        cpu = /cgroup/cpu;
      }

runcmd:
  - sed "/^default_kernel_opts=/ s/\"$/ cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory\"/" /etc/update-extlinux.conf > /etc/update-extlinux.conf
  - "update-extlinux"
power_state:
    mode: reboot

package_update: true
package_upgrade: true

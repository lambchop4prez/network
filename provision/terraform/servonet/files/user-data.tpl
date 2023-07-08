#cloud-config

hostname: ${hostname}.lan
manage_etc_hosts: true
locale: en_US.UTF-8
timezone: America/Detroit
keyboard:
  layout: us
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


write_files:
  # - path: /etc/network/interfaces
  #   content: |
  #     auto lo
  #     iface lo inet loopback

  #     auto eth0
  #     iface eth0 inet dhcp
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
  # - path: /usr/local/custom_scripts/prep-k3s.sh
  #   content: ${prep_k3s}
  #   encoding: gzip+b64
  #   permissions: "0655"

runcmd:
  - [sed, -i, "/^default_kernel_opts=/ s/\"$/ cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory\"/", /etc/update-extlinux.conf]
  - update-extlinux
  - [apk, add, iptables, sudo, vim]
  - [apk, add, --no-cache, cni-plugins, --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing]
  - [touch, /etc/cloud/cloud-init.disabled]



# power_state:
#   delay: now
#   mode: reboot
  # condition: test -f /var/tmp/reboot_me


package_update: true
package_upgrade: true

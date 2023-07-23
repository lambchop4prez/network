#cloud-config

hostname: ${hostname}.lan
manage_etc_hosts: true
locale: en_US.UTF-8
timezone: America/Detroit
keyboard:
  layout: us
ssh_pwauth: false
ssh:
  emit_keys_to_console: false
mounts:
  - ["cgroup", "/sys/fs/cgroup", "cgroup", "defaults", "0", "0"]

users:
  - name: ${username}
    gecos: Tom Servo
    groups: sudo, robot
    create_groups: true
    plain_text_passwd: ${password}
    sudo: "ALL=(ALL) NOPASSWD:ALL"
    ssh_authorized_keys:
      - ${ ssh_key }
    ssh_import_id:
      - gh:lambchop4prez

write_files:
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
  - path: /etc/rancher/k3s/config.yaml
    content: ${k3s_config}
    encoding: gzip+b64
    permissions: "0644"

runcmd:
  - [apk, add, iptables, sudo, vim, ca-certificates, curl, chrony]
  - [apk, add, --no-cache, cni-plugins, --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing]
  - [sed, -i, "/^default_kernel_opts=/ s/\"$/ cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory\"/", /etc/update-extlinux.conf]
  - update-extlinux
  - curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="${exec}" sh -
  - [touch, /etc/cloud/cloud-init.disabled]

package_update: true
package_upgrade: true

power_state:
  mode: reboot
  delay: now

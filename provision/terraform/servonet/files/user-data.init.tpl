#cloud-config

hostname: ${hostname}.lan
manage_etc_hosts: true
locale: en_US.UTF-8
timezone: America/Detroit
keyboard:
  layout: us
ssh_pwauth: false
ssh:
  ssh_quiet_keygen: false
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
  - path: /var/lib/rancher/k3s/server/manifests/pod-kube-vip.yaml
    content: ${pod_kube_vip}
    encoding: gzip+b64
    permissions: "0644"
  - path: /var/lib/rancher/k3s/server/manifests/calico-installation.yaml
    content: ${calico_installation}
    encoding: gzip+b64
    permissions: "0644"

runcmd:
  - [apk, add, iptables, sudo, vim, ca-certificates, curl, chrony]
  - [curl, https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml, --output, /var/lib/rancher/k3s/server/manifests/tigera-operator.yaml]
  - [curl, https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml, --output, /var/lib/rancher/k3s/server/manifests/custom-resources.yaml]
  - [apk, add, --no-cache, cni-plugins, --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing]
  - [sed, -i, "/^default_kernel_opts=/ s/\"$/ cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory\"/", /etc/update-extlinux.conf]
  - update-extlinux
  - curl -sfL https://get.k3s.io | sh -
  - [touch, /etc/cloud/cloud-init.disabled]

package_update: true
package_upgrade: true

power_state:
  mode: reboot
  delay: now

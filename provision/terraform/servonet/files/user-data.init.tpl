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
  - ["cgroup", "/sys/fs/cgroup", "cgroup2", "defaults", "0", "0"]
  - ["bpffs", "/sys/fs/bpf", "bpf", "defaults", "0", "0"]
  - ["none", "/run/cilium/cgroupv2", "cgroup2", "rw,relatime", "0", "0"]

bootcmd:
  - ["mount", "--make-shared", "/sys/fs/cgroup"]
  - ["mount", "--make-shared", "/sys/fs/bpf"]
  - ["mount", "--make-shared", "/run/cilium/cgroupv2"]

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
    content: ${ds_kube_vip}
    encoding: gzip+b64
    permissions: "0644"
  - path: /var/lib/rancher/k3s/server/manifests/custom-cilium-helmchart.yaml
    content: ${cilium_helmchart}
    encoding: gzip+b64
    permissions: "0644"
  - path: /var/lib/rancher/k3s/server/manifests/custom-cilium-ippool.yaml
    content: ${cilium_ippool}
    encoding: gzip+b64
    permissions: "0644"
  - path: /var/lib/rancher/k3s/server/manifests/custom-cilium-bgppeeringpolicy.yaml
    content: ${cilium_bgppeer}
    encoding: gzip+b64
    permissions: "0644"

runcmd:
  - echo 'rc_cgroup_mode="unified"' >> /etc/rc.conf
  - [apk, add, iptables, sudo, vim, ca-certificates, curl, chrony]
  - [curl, https://raw.githubusercontent.com/kube-vip/kube-vip/main/docs/manifests/rbac.yaml, --output, /var/lib/rancher/k3s/server/manifests/kube-vip-rbac.yaml]
  - [curl, https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.66.0/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml, --output, /var/lib/rancher/k3s/server/manifests/custom-prometheus-podmonitors.yaml]
  - [curl, https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.66.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml, --output, /var/lib/rancher/k3s/server/manifests/custom-prometheus-prometheusrules.yaml]
  - [curl, https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.66.0/example/prometheus-operator-crd/monitoring.coreos.com_scrapeconfigs.yaml, --output, /var/lib/rancher/k3s/server/manifests/custom-prometheus-scrapeconfigs.yaml]
  - [curl, https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.66.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml, --output, /var/lib/rancher/k3s/server/manifests/custom-prometheus-servicemonitors.yaml]
  - [apk, add, --no-cache, cni-plugins, --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing]
  - [sed, -i, "/^default_kernel_opts=/ s/\"$/ cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory\"/", /etc/update-extlinux.conf]
  - update-extlinux
  # - mount --make-shared /sys/fs/bpf
  # - mount --make-shared /run/cilium/cgroupv2/
  - curl -sfL https://get.k3s.io | sh -
  - [touch, /etc/cloud/cloud-init.disabled]

power_state:
  mode: reboot
  delay: now


package_update: true
package_upgrade: true

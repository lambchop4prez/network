---
# https://rancher.com/docs/k3s/latest/en/installation/install-options/server-config/

write-kubeconfig-mode: "0644"
tls-san:
  # kube-vip
  - "${kube_vip_address}"
node-label:
  - "foo=bar"
  - "something=amazing"
cluster-init: true
token: ${k3s_token}

# Disable Docker - this will use the default containerd CRI
docker: false
flannel-backend: "none" # This needs to be in quotes
disable:
  # Disable flannel - replaced with Cilium
  - flannel
  # Disable traefik - installed with Flux
  - traefik
  # Disable servicelb - replaced with metallb and install with Flux
  - servicelb
  # Disable metrics-server - installed with Flux
  - metrics-server
disable-network-policy: true
disable-cloud-controller: true
disable-servicelb: true
# Network CIDR to use for pod IPs
cluster-cidr: "${cluster_cidr}"
# Network CIDR to use for service IPs
service-cidr: "${service_cidr}"
kubelet-arg:
  # Enables the kubelet to gracefully evict pods during a node shutdown
  - "feature-gates=GracefulNodeShutdown=true"
  # Allow k8s services to contain TCP and UDP on the same port
  - "feature-gates=MixedProtocolLBService=true"
# Required to monitor kube-controller-manager with kube-prometheus-stack
kube-controller-manager-arg:
  - "bind-address=0.0.0.0"
# Required to monitor kube-proxy with kube-prometheus-stack
kube-proxy-arg:
  - "metrics-bind-address=0.0.0.0"
# Required to monitor kube-scheduler with kube-prometheus-stack
kube-scheduler-arg:
  - "bind-address=0.0.0.0"
# Required to monitor etcd with kube-prometheus-stack
etcd-expose-metrics: true
# Required for HAProxy health-checks
kube-apiserver-arg:
  # Allow k8s services to contain TCP and UDP on the same port
  - "feature-gates=MixedProtocolLBService=true"
  - "anonymous-auth=true"

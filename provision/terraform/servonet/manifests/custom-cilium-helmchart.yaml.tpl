---
# https://docs.k3s.io/helm
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: cilium
  namespace: kube-system
spec:
  repo: https://helm.cilium.io/
  chart: cilium
  # renovate: datasource=helm depName=cilium registryUrl=https://helm.cilium.io
  version: "1.14.0"
  targetNamespace: kube-system
  bootstrap: true
  valuesContent: |-

    autoDirectNodeRoutes: true
    bpf:
      masquerade: true
    bgp:
      enabled: false
    cluster:
      name: servonet
      id: 1
    containerRuntime:
      integration: containerd
      socketPath: /var/run/k3s/containerd/containerd.sock
    endpointRoutes:
      enabled: true
    hubble:
      enabled: false
    ipam:
      mode: kubernetes
    ipv4NativeRoutingCIDR: "${ cluster_cidr }"
    k8sServiceHost: "127.0.0.1"
    k8sServicePort: 6443
    kubeProxyReplacement: strict
    kubeProxyReplacementHealthzBindAddr: 0.0.0.0:10256
    # https://github.com/cilium/cilium/issues/26586
    l2announcements:
      enabled: true
      leaseDuration: 30s
      leaseRenewDeadline: 10s
      leaseRetryPeriod: 4s
    loadBalancer:
      algorithm: maglev
      mode: dsr
    localRedirectPolicy: true
    operator:
      rollOutPods: true
    rollOutCiliumPods: true
    securityContext:
      privileged: true
    tunnel: disabled
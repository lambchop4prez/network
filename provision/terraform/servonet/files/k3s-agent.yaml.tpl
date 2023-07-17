---
# https://docs.k3s.io/cli/server

server: https://${kube_vip_address}:6443
token: ${k3s_token}

kubelet-arg:
  # Enables the kubelet to gracefully evict pods during a node shutdown
  - "feature-gates=GracefulNodeShutdown=true"
  # Allow k8s services to contain TCP and UDP on the same port
  - "feature-gates=MixedProtocolLBService=true"

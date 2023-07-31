---
# https://docs.cilium.io/en/latest/network/l2-announcements
apiVersion: cilium.io/v2alpha1
kind: CiliumL2AnnouncementPolicy
metadata:
  name: policy
spec:
  loadBalancerIPs: true
  # NOTE: This might need to be set if you have more than one active NIC on your nodes
  interfaces:
   - ^eth[0-9]+
  nodeSelector:
    matchLabels:
      kubernetes.io/os: linux
---
apiVersion: cilium.io/v2alpha1
kind: CiliumLoadBalancerIPPool
metadata:
  name: pool
spec:
  cidrs:
    - cidr: "${ external_cidr }"

---
apiVersion: cilium.io/v2alpha1
kind: CiliumLoadBalancerIPPool
metadata:
  name: pool
spec:
  cidrs:
    - cidr: "${ external_cidr }"

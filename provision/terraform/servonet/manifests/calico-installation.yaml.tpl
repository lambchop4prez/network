---
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  registry: quay.io
  imagePath: calico
  calicoNetwork:
    # https://projectcalico.docs.tigera.io/networking/ip-autodetection
    nodeAddressAutodetectionV4:
      kubernetes: NodeInternalIP
    # Note: The ipPools section cannot be modified post-install.
    ipPools:
      - blockSize: 26
        cidr: "${ cluster_cidr }"
        encapsulation: "VXLANCrossSubnet"
        natOutgoing: Enabled
        nodeSelector: all()
  nodeMetricsPort: 9091
  typhaMetricsPort: 9093

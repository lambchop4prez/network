---
apiVersion: crd.projectcalico.org/v1
kind: BGPConfiguration
metadata:
  name: default
spec:
  asNumber: ${ bgp_node_asn }
  nodeToNodeMeshEnabled: true
  serviceClusterIPs:
    - cidr: "${ service_cidr }"
  serviceLoadBalancerIPs:
    - cidr: "${ external_cidr }"

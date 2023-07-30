---
apiVersion: crd.projectcalico.org/v1
kind: BGPPeer
metadata:
  name: global
spec:
  asNumber: ${ bgp_router_asn }
  peerIP: ${ bgp_router_address }

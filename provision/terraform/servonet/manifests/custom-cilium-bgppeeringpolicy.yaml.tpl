---
apiVersion: "cilium.io/v2alpha1"
kind: CiliumBGPPeeringPolicy
metadata:
 name: default
spec: # CiliumBGPPeeringPolicySpec
 nodeSelector:
   matchLabels:
     node-role.kubernetes.io/control-plane: "true"
 virtualRouters: # []CiliumBGPVirtualRouter
 - localASN: ${ bgp_node_asn }
   exportPodCIDR: true
   # Announce all services
   serviceSelector:
      matchExpressions:
         - {key: somekey, operator: NotIn, values: ['never-used-value']}
   neighbors: # []CiliumBGPNeighbor
    - peerAddress: '${ bgp_router_address }'
      peerASN: ${ bgp_router_asn }
      eBGPMultihopTTL: 10
      connectRetryTimeSeconds: 120
      holdTimeSeconds: 90
      keepAliveTimeSeconds: 30
      gracefulRestart:
        enabled: true
        restartTimeSeconds: 120

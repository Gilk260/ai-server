# Calico Installation CR (applied by K3s auto-deploy after operator is ready)
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  calicoNetwork:
    bgp: Disabled
    ipPools:
      - cidr: 10.42.0.0/16
        encapsulation: VXLAN
---
apiVersion: operator.tigera.io/v1
kind: APIServer
metadata:
  name: default
spec: {}

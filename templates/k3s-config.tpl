# K3s hardened server configuration
disable:
  - traefik
  - servicelb
flannel-backend: "none"
disable-network-policy: true
secrets-encryption: true
protect-kernel-defaults: true
tls-san:
  - "${server_ip}"
%{ if mgmt_ip != null ~}
  - "${mgmt_ip}"
%{ endif ~}
  - "${cluster_domain}"
kube-apiserver-arg:
  - "anonymous-auth=false"
  - "audit-log-path=/var/lib/rancher/k3s/server/logs/audit.log"
  - "audit-policy-file=/var/lib/rancher/k3s/server/audit.yaml"
  - "audit-log-maxage=30"
  - "audit-log-maxbackup=10"
  - "audit-log-maxsize=100"
  - "admission-control-config-file=/var/lib/rancher/k3s/server/psa.yaml"
kubelet-arg:
  - "streaming-connection-idle-timeout=5m"
  - "make-iptables-util-chains=true"

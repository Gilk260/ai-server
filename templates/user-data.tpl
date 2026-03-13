#cloud-config

hostname: ${hostname}
fqdn: ${hostname}.${cluster_domain}

ssh_pwauth: false
ssh_authorized_keys:
  - ${ssh_key}

users:
  - default
  - name: ubuntu
    groups: sudo
    sudo: 'ALL=(ALL) NOPASSWD:ALL'
    shell: /bin/bash
    lock_passwd: true
    ssh_authorized_keys:
      - ${ssh_key}

packages:
  - qemu-guest-agent
  - iptables
  - curl
  - jq
  - open-iscsi
  - nfs-common
%{ for pkg in packages ~}
  - ${pkg}
%{ endfor ~}

write_files:
  - path: /etc/modules-load.d/k3s.conf
    content: |
      br_netfilter
      overlay
      ip_tables
      iptable_filter
      iptable_nat

  - path: /etc/sysctl.d/k3s.conf
    content: |
      net.bridge.bridge-nf-call-iptables  = 1
      net.bridge.bridge-nf-call-ip6tables = 1
      net.ipv4.ip_forward                 = 1
      vm.panic_on_oom                     = 0
      vm.overcommit_memory                = 1
      kernel.panic                        = 10
      kernel.panic_on_oops                = 1

%{ if k3s_role == "server" ~}
  - path: /etc/rancher/k3s/config.yaml
    content: |
      ${indent(6, k3s_config)}

  - path: /var/lib/rancher/k3s/server/psa.yaml
    content: |
      ${indent(6, psa_config)}

  - path: /var/lib/rancher/k3s/server/audit.yaml
    content: |
      ${indent(6, audit_policy)}

  - path: /var/lib/rancher/k3s/server/manifests/calico.yaml
    content: |
      ${indent(6, calico_helmchart)}
%{ endif ~}

runcmd:
  - systemctl enable --now qemu-guest-agent
  - modprobe br_netfilter overlay ip_tables iptable_filter iptable_nat
  - sysctl --system
  - systemctl enable --now iscsid
  - bash -c 'until ping -c 1 -W 3 1.1.1.1 > /dev/null 2>&1; do echo "Waiting for network..."; sleep 5; done'
%{ if k3s_role == "server" ~}
  - mkdir -p /var/lib/rancher/k3s/server/logs
  - curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="${k3s_version}" sh -s - server
  - bash -c 'until /usr/local/bin/kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml get nodes 2>/dev/null; do sleep 3; done'
  - /usr/local/bin/kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.2/manifests/tigera-operator.yaml
%{ endif ~}
%{ if k3s_role == "agent" ~}
  - curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="${k3s_version}" K3S_URL="https://${k3s_server_ip}:6443" K3S_TOKEN="${k3s_token}" sh -s - agent
%{ endif ~}
%{ for cmd in runcmd ~}
  - ${cmd}
%{ endfor ~}

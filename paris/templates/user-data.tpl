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
  # Kernel modules for K3s
  - path: /etc/modules-load.d/k3s.conf
    content: |
      br_netfilter
      overlay
      ip_tables
      iptable_filter
      iptable_nat

  # Sysctl for K3s networking
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
  # K3s server config
  - path: /etc/rancher/k3s/config.yaml
    content: |
      ${indent(6, k3s_config)}

  # Pod Security Admission config
  - path: /var/lib/rancher/k3s/server/psa.yaml
    content: |
      ${indent(6, psa_config)}

  # Audit policy
  - path: /var/lib/rancher/k3s/server/audit.yaml
    content: |
      ${indent(6, audit_policy)}

  # Calico HelmChart (auto-deployed by K3s)
  - path: /var/lib/rancher/k3s/server/manifests/calico.yaml
    content: |
      ${indent(6, calico_helmchart)}
%{ endif ~}

runcmd:
  - systemctl enable --now qemu-guest-agent
  - modprobe br_netfilter overlay ip_tables iptable_filter iptable_nat
  - sysctl --system
  - systemctl enable --now iscsid
  # Wait for network to be fully ready (router may need time to learn VM MAC)
  - bash -c 'until ping -c 1 -W 3 1.1.1.1 > /dev/null 2>&1; do echo "Waiting for network..."; sleep 5; done'
%{ if k3s_role == "server" ~}
  # Create audit log directory
  - mkdir -p /var/lib/rancher/k3s/server/logs
  # Install K3s server
  - curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="${k3s_version}" sh -s - server
  # Wait for K3s API to be ready
  - bash -c 'until /usr/local/bin/kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml get nodes 2>/dev/null; do sleep 3; done'
  # Install Calico operator (has built-in tolerations for NotReady nodes, avoids HelmChart CRD chicken-and-egg)
  - /usr/local/bin/kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.2/manifests/tigera-operator.yaml
%{ endif ~}
%{ if k3s_role == "agent" ~}
  # Install K3s agent
  - curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="${k3s_version}" K3S_URL="https://${k3s_server_ip}:6443" K3S_TOKEN="${k3s_token}" sh -s - agent
%{ endif ~}
%{ for cmd in runcmd ~}
  - ${cmd}
%{ endfor ~}

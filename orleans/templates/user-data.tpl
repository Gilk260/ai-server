#cloud-config
hostname: ${hostname}

ssh_pwauth: true
ssh_authorized_keys:
  - ${ssh_key}

users:
  - default
  - name: ubuntu
    groups: sudo
    sudo: 'ALL=(ALL) NOPASSWD:ALL'
    lock_passwd: false

chpasswd:
  list: |
    ubuntu:qwerty
  expire: False

package_upgrade: true
packages:
  - qemu-guest-agent
  - iptables
  - curl
%{ for pkg in packages ~}
  - ${pkg}
%{ endfor ~}

write_files:
  - path: /etc/modules-load.d/k3s.conf
    content: |
      br_netfilter
      overlay
  - path: /etc/sysctl.d/k3s.conf
    content: |
      net.bridge.bridge-nf-call-ip6tables = 1
      net.bridge.bridge-nf-call-iptables = 1
      net.ipv4.ip_forward = 1

runcmd:
  - systemctl enable --now qemu-guest-agent

  - modprobe br_netfilter
  - modprobe overlay
  - sysctl --system

%{ for cmd in runcmd ~}
  - ${cmd}
%{ endfor ~}

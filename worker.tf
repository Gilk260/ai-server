locals {
  worker_address = "192.168.1.102"
  worker_vm_id   = 101
  worker_hostname = "worker"
}

resource "proxmox_virtual_environment_vm" "worker" {
  name = "worker"
  description = "Worker for AI's inference cluster"
  tags = ["k8s", "ai", "worker", "terraform"]
  node_name = data.proxmox_virtual_environment_node.server.node_name

  vm_id = local.worker_vm_id

  agent {
    enabled = true
  }

  cpu {
    cores = 4
    flags = ["+pcid"]
    type = "host"
  }

  memory {
    dedicated = 8192
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.latest_ubuntu_22_jammy_qcow2_img.id
    interface    = "scsi0"
    size         = 32
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${local.worker_address}/24"
        gateway = "192.168.1.1"
      }

      ipv6 {
        address = "dhcp"
      }
    }

    user_account {
      password = "qwerty"
      username = "toto"
    }
    user_data_file_id = proxmox_virtual_environment_file.worker_config.id
  }

  kvm_arguments = "-cpu 'host,+kvm_pv_unhalt,+kvm_pv_eoi,hv_vendor_id=NV43FIX,kvm=off'"
  machine = "q35"
  hostpci {
    device = "hostpci0"
    id = "0000:01:00"
    pcie = true
    rombar = true
    xvga = false
  }
}

resource "proxmox_virtual_environment_file" "worker_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name = data.proxmox_virtual_environment_node.server.node_name

  source_raw {
    data = <<-EOF
    #cloud-config
    hostname: ${local.worker_hostname}

    ssh_pwauth: true
    ssh_authorized_keys:
      - ${var.ssh_key}

    chpasswd:
      list: |
        - root:qwerty
        - ubuntu:qwerty
      expire: false

    users:
      - default
      - name: ubuntu
        groups: sudo
        sudo: 'ALL=(ALL) NOPASSWD:ALL'

    package_upgrade: true
    packages:
      - qemu-guest-agent
      - curl
      - apt-transport-https
      - ca-certificates
      - gnupg
      - lsb-release
      - containerd

    # Let iptables see bridged traffic
    # https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#letting-iptables-see-bridged-traffic
    write_files:
      - path: /etc/modules-load.d/k8s.conf
        content: |
          br_netfilter
      - path: /etc/sysctl.d/k8s.conf
        content: |
          net.bridge.bridge-nf-call-ip6tables = 1
          net.bridge.bridge-nf-call-iptables = 1
      - path: /etc/sysctl.d/k8s.conf
        content: |
          net.ipv4.ip_forward = 1
          net.ipv6.conf.all.forwarding = 1

    runcmd:
      # Requirements for K8s
      - swapoff -a
      - sed -i '/ swap / s/^/#/' /etc/fstab
      - mkdir -p /etc/containerd
      - containerd config default > /etc/containerd/config.toml
      - sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
      - systemctl restart containerd

      - systemctl restart sshd
      - sysctl --system
      - echo "About to run dmgw"
      - modprobe br_netfilter # Load br_netfilter module.

      # K8s
      - curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
      - echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
      - apt-get update
      - apt-get install -y kubelet kubeadm kubectl
      - apt-mark hold kubelet kubeadm kubectl

      # Qemu guest agent
      - systemctl enable --now kubelet
      - systemctl enable qemu-guest-agent
      - systemctl start qemu-guest-agent

    scripts-user:
      - /var/lib/cloud/instance/scripts/runcmd
    EOF

    file_name = "worker.cloud-config.yaml"
  }
}


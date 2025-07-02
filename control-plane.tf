locals {
  control_plane_address = var.cluster_address
  control_plane_address_range = "10.244.0.0/16" # Flannel
  control_plane_vm_id = 100
  control_plane_hostname = "control_plane"
}

resource "proxmox_virtual_environment_vm" "control_plane" {
  name = "control-plane"
  description = "Control plane for AI's inference cluster"
  tags = ["k8s", "ai", "control_plane", "terraform"]
  node_name = data.proxmox_virtual_environment_node.server.node_name

  vm_id = local.control_plane_vm_id

  agent {
    enabled = true
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 4096
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.latest_ubuntu_22_jammy_qcow2_img.id
    interface    = "scsi0"
    size         = 16
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${local.control_plane_address}/24"
        gateway = "192.168.1.1"
      }

      ipv6 {
        address = "dhcp"
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.control_plane_config.id
  }
}

resource "proxmox_virtual_environment_file" "control_plane_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name = data.proxmox_virtual_environment_node.server.node_name

  source_raw {
    data = <<-EOF
    #cloud-config
    hostname: ${local.control_plane_hostname}

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
      - swapoff -a
      - sed -i '/ swap / s/^/#/' /etc/fstab
      - mkdir -p /etc/containerd
      - containerd config default > /etc/containerd/config.toml
      - sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
      - systemctl restart containerd
      - systemctl restart sshd
      - sysctl --system
      - echo "ABout to run dmgw"
      - modprobe br_netfilter # Load br_netfilter module.
      - curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
      - echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
      - apt-get update
      - apt-get install -y kubelet kubeadm kubectl
      - apt-mark hold kubelet kubeadm kubectl
      - systemctl enable --now kubelet
      - systemctl enable qemu-guest-agent
      - systemctl start qemu-guest-agent
      - kubeadm init --pod-network-cidr ${local.control_plane_address_range} --apiserver-advertise-address ${local.control_plane_address}
      - KUBECONFIG=/etc/kubernetes/admin.conf kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml # Install Flannel

    scripts-user:
      - /var/lib/cloud/instance/scripts/runcmd
    EOF

    file_name = "control_plane.cloud-config.yaml"
  }
}

# resource "proxmox_virtual_environment_group" "control_plane" {
#   group_id = "control-plane"
# }
# 
# resource "proxmox_virtual_environment_hagroup" "control_plane" {
#   group = proxmox_virtual_environment_group.control_plane.group_id
# 
#   nodes = {
#     gilk = null
#   }
# 
#   restricted  = true
# }
# 
# resource "proxmox_virtual_environment_haresource" "control_plane" {
#   depends_on = [
#     proxmox_virtual_environment_hagroup.control_plane
#   ]
#   resource_id = "vm:100"
#   state       = "started"
#   group       = "control-plane"
# }

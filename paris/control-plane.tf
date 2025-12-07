locals {
  control_plane_address = var.control_plane_ip
  control_plane_vm_id = 109
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
        address = "${local.control_plane_address}/32"
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

    ssh_pwauth: false
    ssh_authorized_keys:
      - ${var.ssh_key}

    users:
      - default
      - name: ubuntu
        groups: sudo
        sudo: 'ALL=(ALL) NOPASSWD:ALL'

    package_upgrade: true
    packages:
      - qemu-guest-agent
      - python3
      - wireguard

    # Let iptables see bridged traffic
    # Required kernel settings for Kubernetes
    write_files:
      - path: /etc/modules-load.d/k8s.conf
        content: |
          br_netfilter
      - path: /etc/sysctl.d/k8s.conf
        content: |
          net.bridge.bridge-nf-call-ip6tables = 1
          net.bridge.bridge-nf-call-iptables = 1
          net.ipv4.ip_forward = 1
          net.ipv6.conf.all.forwarding = 1

    runcmd:
      - systemctl enable qemu-guest-agent
      - systemctl start qemu-guest-agent
      - modprobe br_netfilter
      - sysctl --system
    EOF

    file_name = "control_plane.cloud-config.yaml"
  }
}


locals {
  worker_address = var.worker_ip
  worker_vm_id   = 133
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
        address = "${local.worker_address}/32"
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

    file_name = "worker.cloud-config.yaml"
  }
}


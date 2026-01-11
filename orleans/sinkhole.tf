locals {
  sinkhole_address = var.sinkhole_ip
  sinkhole_vm_id = 1000
  sinkhole_hostname = "sinkhole"
}

resource "proxmox_virtual_environment_vm" "dns_sinkhole" {
  name        = local.sinkhole_hostname
  description = "DNS Sinkhole (Pi-hole/AdGuard)"
  tags        = ["dns", "sinkhole", "terraform"]
  node_name   = data.proxmox_virtual_environment_node.server.node_name
  vm_id       = local.sinkhole_vm_id

  agent {
    enabled = true
  }

  # DNS needs very little power
  cpu {
    cores = 1
    type  = "host"
  }

  memory {
    dedicated = 512
  }

  disk {
    datastore_id = "local-lvm"
    # Reusing your existing downloaded image resource
    file_id      = proxmox_virtual_environment_download_file.latest_ubuntu_22_jammy_qcow2_img.id
    interface    = "scsi0"
    size         = 8
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${local.sinkhole_address}/24"
        gateway = "192.168.1.1"
      }
      ipv6 {
        address = "dhcp"
      }
    }

    user_account {
      # Use a strong password or rely purely on SSH keys
      password = "changeme123" 
      username = "adminuser"
    }

    user_data_file_id = proxmox_virtual_environment_file.sinkhole_config.id
  }
}

resource "proxmox_virtual_environment_file" "sinkhole_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = data.proxmox_virtual_environment_node.server.node_name

  source_raw {
    data = <<-EOF
    #cloud-config
    hostname: ${local.sinkhole_hostname}

    ssh_pwauth: false
    ssh_authorized_keys:
      - ${var.ssh_key}

    users:
      - default
      - name: adminuser
        groups: sudo
        sudo: 'ALL=(ALL) NOPASSWD:ALL'
        shell: /bin/bash

    package_upgrade: true
    packages:
      - qemu-guest-agent
      - curl
      - unzip
      - tar

    runcmd:
      - systemctl enable qemu-guest-agent
      - systemctl start qemu-guest-agent
      # Optional: Install AdGuard Home automatically (Simpler than Pi-hole for automation)
      - curl -s -S -L https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sh -s -- -v
    EOF

    file_name = "sinkhole.cloud-config.yaml"
  }
}

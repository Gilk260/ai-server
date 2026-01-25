locals {
  router_vm_id    = 10001
  router_hostname = "router"
}

resource "proxmox_virtual_environment_network_linux_bridge" "k8s_network" {
  node_name = data.proxmox_virtual_environment_node.server.node_name
  name      = "vmbr1"
  comment   = "Private K8s Network managed by Terraform"
}

resource "proxmox_virtual_environment_vm" "router" {
  depends_on = [proxmox_virtual_environment_network_linux_bridge.k8s_network]

  name      = local.router_hostname
  node_name = data.proxmox_virtual_environment_node.server.node_name
  vm_id     = local.router_vm_id
  tags      = ["router", "terraform", "vlan"]

  agent {
    enabled = true
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 1024
  }

  disk {
    datastore_id = "local-lvm"
    # Reusing your existing downloaded image resource
    file_id   = proxmox_virtual_environment_download_file.latest_ubuntu_22_jammy_qcow2_img.id
    interface = "scsi0"
    size      = 8
  }

  # Network Interface 1: WAN (Internet Access)
  network_device {
    bridge = "vmbr0" # Connected to your SFR Box
  }

  # Network Interface 2: LAN (The New K8s Subnet)
  network_device {
    bridge = "vmbr1" # The Isolated Bridge
    # This interface will be the Gateway for everyone else
  }

  initialization {
    # WAN IP (DHCP from SFR Box is fine, or Static 192.168.1.254)
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    # LAN IP (This becomes the Gateway IP: 10.0.0.1)
    ip_config {
      ipv4 {
        address = "${var.router_gateway}/16"
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.router_cloud_config.id
  }
}

resource "proxmox_virtual_environment_file" "router_cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = data.proxmox_virtual_environment_node.server.node_name

  source_raw {
    data = <<-EOF
    #cloud-config
    hostname: ${local.router_hostname}

    ssh_pwauth: false
    ssh_authorized_keys:
      - ${var.ssh_key}

    packages:
      - qemu-guest-agent
      - iptables-persistent

    write_files:
      # Enable IP Forwarding permanently
      - path: /etc/sysctl.d/99-ip-forwarding.conf
        content: |
          net.ipv4.ip_forward=1
      # FORCE DNS: Override DHCP DNS settings
      # We edit resolved.conf to prioritize AdGuard (192.168.1.200)
      # Fallback to 1.1.1.1 if AdGuard dies
      - path: /etc/systemd/resolved.conf
        owner: root:root
        permissions: '0644'
        content: |
          [Resolve]
          DNS=192.168.1.200 1.1.1.1
          # 'Domains=~.' tells systemd to use this DNS for EVERYTHING
          Domains=~.

    runcmd:
      - systemctl enable --now qemu-guest-agent

      # Apply the DNS Override
      - systemctl restart systemd-resolved

      # Apply the forwarding rule immediately
      - sysctl -p /etc/sysctl.d/99-ip-forwarding.conf

      # Setup NAT (The "Masquerade")
      # Using 10.0.0.0/16 covers 10.0.x.x
      - iptables -t nat -A POSTROUTING -s 10.0.0.0/16 -o eth0 -j MASQUERADE

      # Save the rules so they survive reboot
      - iptables-save > /etc/iptables/rules.v4
    EOF

    file_name = "router.cloud-config.yaml"
  }
}

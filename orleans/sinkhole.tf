locals {
  sinkhole_address  = var.sinkhole_ip
  sinkhole_vm_id    = 1000
  sinkhole_hostname = "sinkhole"
}

resource "adguard_config" "main" {
  dhcp = {
    enabled   = true
    interface = "eth0"
    ipv4_settings = {
      gateway_ip     = "192.168.1.1"
      lease_duration = 86400
      range_start    = "192.168.1.2"
      range_end      = "192.168.1.253"
      subnet_mask    = "255.255.255.0"
    }
  }

  dns = {
    upstream_dns = [
      "https://dns.cloudflare.com/dns-query",
      "https://dns.quad9.net/dns-query",
    ]
    upstream_mode             = "parallel",
    use_private_ptr_resolvers = true
    local_ptr_upstreams = [
      "192.168.1.1"
    ]
  }

  querylog = {
    interval = 24
  }

  depends_on = [
    proxmox_virtual_environment_vm.dns_sinkhole
  ]
}

resource "adguard_list_filter" "hagezi_threat_intelligence_feeds" {
  name = "HaGeZi's Threat Intelligence Feeds"
  url  = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_44.txt"

  depends_on = [
    proxmox_virtual_environment_vm.dns_sinkhole
  ]
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

    write_files:
      - path: /tmp/AdGuardHome.yaml
        owner: root:root
        permissions: '0644'
        content: |
          http:
            address: 0.0.0.0:80
          users:
            - name: admin
              # This is "password" hashed.
              password: ${var.adguard_password_hash}

    runcmd:
      # port 53 conflict with AdGuardHome
      - systemctl disable --now systemd-resolved
      - rm -f /etc/resolv.conf
      - echo "nameserver 1.1.1.1" > /etc/resolv.conf

      - systemctl enable qemu-guest-agent
      - systemctl start qemu-guest-agent
      - curl -s -S -L https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sh -s -- -v -r

      - systemctl stop AdGuardHome
      - mv /tmp/AdGuardHome.yaml /opt/AdGuardHome/AdGuardHome.yaml
      - chmod 644 /opt/AdGuardHome/AdGuardHome.yaml
      - systemctl start AdGuardHome
    EOF

    file_name = "sinkhole.cloud-config.yaml"
  }
}

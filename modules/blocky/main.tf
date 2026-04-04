locals {
  prefix_length = split("/", var.network_subnet)[1]

  blocky_config_b64 = base64encode(yamlencode({
    ports = {
      dns  = 53
      http = 4000
    }
    upstreams = {
      groups = {
        default = ["1.1.1.1", "8.8.8.8"]
      }
    }
    customDNS = {
      mapping = {
        (var.cluster_domain) = var.k3s_server_ip
      }
    }
    blocking = {
      denylists = {
        ads = [
          "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
        ]
      }
      clientGroupsBlock = {
        default = ["ads"]
      }
    }
    caching = {
      minTime     = "5m"
      prefetching = true
    }
    prometheus = {
      enable = true
      path   = "/metrics"
    }
  }))
}

resource "proxmox_virtual_environment_container" "blocky" {
  description = "Blocky DNS ad-blocker"

  node_name = var.node_name
  vm_id     = var.blocky_ct.vmid
  tags      = ["terraform", "blocky", var.cluster_name]

  unprivileged = true

  features {
    nesting = true
  }

  started       = true
  start_on_boot = true

  startup {
    order      = 2
    up_delay   = 10
    down_delay = 10
  }

  cpu {
    cores = var.blocky_ct.cores
  }

  memory {
    dedicated = var.blocky_ct.memory
  }

  disk {
    datastore_id = var.vm_datastore_id
    size         = var.blocky_ct.disk
  }

  network_interface {
    name   = "eth0"
    bridge = var.lan_bridge
  }

  initialization {
    hostname = "blocky"

    ip_config {
      ipv4 {
        address = "${var.blocky_ct.ip}/${local.prefix_length}"
        gateway = var.gateway_ip
      }
    }

    dns {
      domain  = var.cluster_domain
      servers = ["1.1.1.1", "8.8.8.8"]
    }

    user_account {
      keys = [var.ssh_key]
    }
  }

  operating_system {
    template_file_id = var.lxc_template_file_id
    type             = "debian"
  }
}

resource "terraform_data" "blocky_install" {
  depends_on = [proxmox_virtual_environment_container.blocky]

  triggers_replace = [
    proxmox_virtual_environment_container.blocky.vm_id,
    sha256(local.blocky_config_b64),
  ]

  provisioner "local-exec" {
    command = <<-EOT
      ssh -o StrictHostKeyChecking=no root@${var.proxmox_ip} bash <<'REMOTE'
      set -e
      CT_ID=${var.blocky_ct.vmid}

      echo "Waiting for container networking..."
      sleep 5

      echo "Installing Blocky..."
      pct exec $CT_ID -- bash -c '
        set -e
        apt-get update && apt-get install -y curl

        BLOCKY_VERSION="v0.24"
        curl -sSL "https://github.com/0xERR0R/blocky/releases/download/$${BLOCKY_VERSION}/blocky_$${BLOCKY_VERSION}_Linux_x86_64.tar.gz" | tar -xz -C /usr/local/bin blocky
        chmod +x /usr/local/bin/blocky
      '

      echo "Writing Blocky config..."
      pct exec $CT_ID -- mkdir -p /etc/blocky
      echo '${local.blocky_config_b64}' | base64 -d > /tmp/blocky-config.yml
      pct push $CT_ID /tmp/blocky-config.yml /etc/blocky/config.yml
      rm -f /tmp/blocky-config.yml

      echo "Creating systemd service..."
      pct exec $CT_ID -- sh -c 'cat > /etc/systemd/system/blocky.service << EOF
[Unit]
Description=Blocky DNS
After=network.target

[Service]
ExecStart=/usr/local/bin/blocky --config /etc/blocky/config.yml
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF'

      pct exec $CT_ID -- systemctl daemon-reload
      pct exec $CT_ID -- systemctl enable --now blocky

      echo "Blocky installed and running."
      REMOTE
      EOT
  }
}

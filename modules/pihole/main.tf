locals {
  # Extract prefix length from network_subnet for IP config
  prefix_length = split("/", var.network_subnet)[1]
}

resource "proxmox_virtual_environment_container" "pihole" {
  description = "Pi-hole DNS sinkhole"

  node_name = var.node_name
  vm_id     = var.pihole_ct.vmid
  tags      = ["terraform", "pihole", var.cluster_name]

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
    cores = var.pihole_ct.cores
  }

  memory {
    dedicated = var.pihole_ct.memory
  }

  disk {
    datastore_id = var.vm_datastore_id
    size         = var.pihole_ct.disk
  }

  network_interface {
    name   = "eth0"
    bridge = var.lan_bridge
  }

  initialization {
    hostname = "pihole"

    ip_config {
      ipv4 {
        address = "${var.pihole_ct.ip}/${local.prefix_length}"
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

resource "terraform_data" "pihole_install" {
  depends_on = [proxmox_virtual_environment_container.pihole]

  triggers_replace = [
    proxmox_virtual_environment_container.pihole.vm_id
  ]

  provisioner "local-exec" {
    command = <<-EOT
      ssh -o StrictHostKeyChecking=no root@${var.proxmox_ip} bash <<'REMOTE'
      set -e
      CT_ID=${var.pihole_ct.vmid}

      echo "Waiting for container networking..."
      sleep 5

      pct exec $CT_ID -- bash -c 'apt-get update && apt-get install -y curl'

      pct exec $CT_ID -- mkdir -p /etc/pihole
      pct exec $CT_ID -- sh -c "printf 'PIHOLE_INTERFACE=eth0\nIPV4_ADDRESS=${var.pihole_ct.ip}/${local.prefix_length}\nPIHOLE_DNS_1=1.1.1.1\nPIHOLE_DNS_2=8.8.8.8\nQUERY_LOGGING=true\nINSTALL_WEB_SERVER=true\nINSTALL_WEB_INTERFACE=true\nLIGHTTPD_ENABLED=true\nCACHE_SIZE=10000\nBLOCKING_ENABLED=true\n' > /etc/pihole/setupVars.conf"

      pct exec $CT_ID -- bash -c 'curl -sSL https://install.pi-hole.net | bash /dev/stdin --unattended'

      echo "Pi-hole installed. Set password with: pct exec $CT_ID -- pihole -a -p <password>"
      REMOTE
      EOT
  }
}

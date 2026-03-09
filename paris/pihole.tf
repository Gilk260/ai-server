# Pi-hole DNS sinkhole (LXC container)
resource "proxmox_virtual_environment_container" "pihole" {
  description = "Pi-hole DNS sinkhole"

  node_name = data.proxmox_virtual_environment_node.server.node_name
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
    datastore_id = "local-lvm"
    size         = var.pihole_ct.disk
  }

  network_interface {
    name   = "eth0"
    bridge = "vmbr1"
  }

  initialization {
    hostname = "pihole"

    ip_config {
      ipv4 {
        address = "${var.pihole_ct.ip}/16"
        gateway = "10.1.0.1"
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
    template_file_id = proxmox_virtual_environment_download_file.debian_lxc.id
    type             = "debian"
  }

  depends_on = [proxmox_virtual_environment_network_linux_bridge.vmbr1]
}

# Install Pi-hole via Proxmox host (pct exec)
resource "null_resource" "pihole_install" {
  depends_on = [proxmox_virtual_environment_container.pihole]

  triggers = {
    ct_id = proxmox_virtual_environment_container.pihole.vm_id
  }

  provisioner "local-exec" {
    command = <<-EOT
      ssh -o StrictHostKeyChecking=no root@${local.proxmox_ip} bash <<'REMOTE'
      set -e
      CT_ID=${var.pihole_ct.vmid}

      echo "Waiting for container networking..."
      sleep 5

      # Install curl (not in minimal Debian template)
      pct exec $CT_ID -- bash -c 'apt-get update && apt-get install -y curl'

      # Write Pi-hole config for unattended install
      pct exec $CT_ID -- mkdir -p /etc/pihole
      pct exec $CT_ID -- sh -c "printf 'PIHOLE_INTERFACE=eth0\nIPV4_ADDRESS=${var.pihole_ct.ip}/16\nPIHOLE_DNS_1=1.1.1.1\nPIHOLE_DNS_2=8.8.8.8\nQUERY_LOGGING=true\nINSTALL_WEB_SERVER=true\nINSTALL_WEB_INTERFACE=true\nLIGHTTPD_ENABLED=true\nCACHE_SIZE=10000\nBLOCKING_ENABLED=true\n' > /etc/pihole/setupVars.conf"

      # Install Pi-hole
      pct exec $CT_ID -- bash -c 'curl -sSL https://install.pi-hole.net | bash /dev/stdin --unattended'

      echo "Pi-hole installed. Set password with: pct exec $CT_ID -- pihole -a -p <password>"
      REMOTE
      EOT
  }
}

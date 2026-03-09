# --- Cloud-init config files ---
resource "proxmox_virtual_environment_file" "cloud_config" {
  for_each = var.cloud_vms

  content_type = "snippets"
  datastore_id = "local"
  node_name    = data.proxmox_virtual_environment_node.server.node_name

  source_raw {
    data = templatefile("${path.module}/templates/user-data.tpl", {
      hostname       = each.key
      cluster_domain = var.cluster_domain
      ssh_key        = var.ssh_key
      packages       = each.value.packages
      runcmd         = each.value.runcmd
      k3s_role       = each.value.k3s_role
      k3s_version    = var.k3s_version
      k3s_server_ip  = local.k3s_server_ip
      k3s_token      = ""
      k3s_config = each.value.k3s_role == "server" ? templatefile("${path.module}/templates/k3s-config.tpl", {
        server_ip      = each.value.ip
        mgmt_ip        = each.value.mgmt_ip
        cluster_domain = var.cluster_domain
      }) : ""
      psa_config       = each.value.k3s_role == "server" ? file("${path.module}/templates/psa-config.tpl") : ""
      audit_policy     = each.value.k3s_role == "server" ? file("${path.module}/templates/audit-policy.tpl") : ""
      calico_helmchart = each.value.k3s_role == "server" ? file("${path.module}/templates/calico-helmchart.tpl") : ""
    })
    file_name = "${each.key}.cloud-config.yaml"
  }
}

# --- Cloud-init VMs ---
resource "proxmox_virtual_environment_vm" "cloud" {
  for_each = var.cloud_vms

  name      = each.key
  node_name = data.proxmox_virtual_environment_node.server.node_name
  vm_id     = each.value.vmid
  tags      = ["terraform", "k3s", var.cluster_name]

  on_boot = each.value.on_boot
  started = true

  machine = "q35"

  # Boot after OPNsense (order=1) and Pi-hole (order=2)
  startup {
    order      = 3
    up_delay   = 60
    down_delay = 60
  }

  cpu {
    cores = each.value.cores
    type  = "host"
  }

  memory {
    dedicated = each.value.memory
  }

  agent {
    enabled = true
  }

  # Primary NIC: private LAN (cluster traffic via OPNsense)
  network_device {
    bridge = "vmbr1"
  }

  # Management NIC: home LAN (direct laptop access, bypasses OPNsense)
  dynamic "network_device" {
    for_each = each.value.mgmt_ip != null ? [1] : []
    content {
      bridge = "vmbr0"
    }
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = local.image_map[each.value.os_key]
    interface    = "scsi0"
    size         = each.value.disk_size
    ssd          = true
    discard      = "on"
  }

  efi_disk {
    datastore_id = "local-lvm"
    type         = "4m"
  }

  initialization {
    # Primary IP on private network
    ip_config {
      ipv4 {
        address = "${each.value.ip}/16"
        gateway = "10.1.0.1" # OPNsense LAN
      }
    }
    # Management IP on home LAN (no gateway to avoid route conflict)
    dynamic "ip_config" {
      for_each = each.value.mgmt_ip != null ? [1] : []
      content {
        ipv4 {
          address = "${each.value.mgmt_ip}/24"
        }
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.cloud_config[each.key].id
  }

  lifecycle {
    ignore_changes = [
      disk[0].file_id,
    ]
  }

  depends_on = [proxmox_virtual_environment_network_linux_bridge.vmbr1]
}

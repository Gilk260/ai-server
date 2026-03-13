locals {
  prefix_length = split("/", var.network_subnet)[1]
}

# --- Cloud-init config files ---
resource "proxmox_virtual_environment_file" "cloud_config" {
  for_each = var.cloud_vms

  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.node_name

  source_raw {
    data = templatefile("${var.templates_path}/user-data.tpl", {
      hostname       = each.key
      cluster_domain = var.cluster_domain
      ssh_key        = var.ssh_key
      packages       = each.value.packages
      runcmd         = each.value.runcmd
      k3s_role       = each.value.k3s_role
      k3s_version    = var.k3s_version
      k3s_server_ip  = var.k3s_server_ip
      k3s_token      = ""
      k3s_config = each.value.k3s_role == "server" ? templatefile("${var.templates_path}/k3s-config.tpl", {
        server_ip      = each.value.ip
        mgmt_ip        = each.value.mgmt_ip
        cluster_domain = var.cluster_domain
      }) : ""
      psa_config       = each.value.k3s_role == "server" ? file("${var.templates_path}/psa-config.tpl") : ""
      audit_policy     = each.value.k3s_role == "server" ? file("${var.templates_path}/audit-policy.tpl") : ""
      calico_helmchart = each.value.k3s_role == "server" ? file("${var.templates_path}/calico-helmchart.tpl") : ""
    })
    file_name = "${each.key}.cloud-config.yaml"
  }
}

# --- Cloud-init VMs ---
resource "proxmox_virtual_environment_vm" "cloud" {
  for_each = var.cloud_vms

  name      = each.key
  node_name = var.node_name
  vm_id     = each.value.vmid
  tags      = ["terraform", "k3s", var.cluster_name]

  on_boot = each.value.on_boot
  started = true
  machine = "q35"

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

  # Primary NIC: private LAN
  network_device {
    bridge = var.lan_bridge
  }

  # Management NIC (optional)
  dynamic "network_device" {
    for_each = each.value.mgmt_ip != null ? [1] : []
    content {
      bridge = var.mgmt_bridge
    }
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = var.image_ids[each.value.os_key]
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
    ip_config {
      ipv4 {
        address = "${each.value.ip}/${local.prefix_length}"
        gateway = var.gateway_ip
      }
    }
    # Management IP (no gateway to avoid route conflict)
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
}

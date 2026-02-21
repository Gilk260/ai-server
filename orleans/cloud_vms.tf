# 1. Generate the Cloud-Init File per VM
resource "proxmox_virtual_environment_file" "cloud_config" {
  for_each = var.cloud_vms

  content_type = "snippets"
  datastore_id = "local"
  node_name    = data.proxmox_virtual_environment_node.server.node_name

  source_raw {
    data = templatefile("${path.module}/templates/user-data.tpl", {
      hostname = each.key
      ssh_key  = var.ssh_key
      packages = each.value.packages
      runcmd   = each.value.runcmd
      mgmt_ip  = each.value.mgmt_ip
    })

    file_name = "${each.key}.cloud-config.yaml"
  }
}

# 2. Create the VMs
resource "proxmox_virtual_environment_vm" "compute_cloud" {
  for_each = var.cloud_vms

  name      = each.key
  node_name = data.proxmox_virtual_environment_node.server.node_name
  vm_id     = each.value.vmid

  agent { enabled = true }

  cpu {
    cores = each.value.cores
    type  = "host"
  }

  memory {
    dedicated = each.value.memory
  }

  efi_disk {
    datastore_id = "local-lvm"
    file_format  = "raw"
    type         = "4m"
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = each.value.disk_size
    file_id      = local.image_map[each.value.os_key]
    ssd          = true
  }

  network_device {
    bridge = "vmbr1" # Servers always go to Private LAN
    model  = "virtio"
  }

  # Management NIC on home LAN (bypasses OPNsense for direct access)
  dynamic "network_device" {
    for_each = each.value.mgmt_ip != null ? [1] : []
    content {
      bridge = "vmbr0"
      model  = "virtio"
    }
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${each.value.ip}/16"
        gateway = "10.0.0.1" # OpnSense LAN IP
      }
    }
    # Management IP on home LAN
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

  on_boot = true

  # BOOT PRIORITY: LOW (Start after Router)
  startup {
    order      = 2
    up_delay   = 60 # Give K3s a minute to settle
    down_delay = 30
  }
}

resource "null_resource" "k3s_kubeconfig" {
  depends_on = [proxmox_virtual_environment_vm.compute_cloud]

  # Trigger this every time the VM ID changes (i.e., re-creation)
  triggers = {
    vmid = proxmox_virtual_environment_vm.compute_cloud["k3s-master"].vm_id
  }

  provisioner "local-exec" {
    command = <<EOT
      echo "Waiting for K3s to initialize..."
      sleep 30

      echo "Fetching kubeconfig..."
      ssh -o StrictHostKeyChecking=no ubuntu@${var.cloud_vms["k3s-master"].mgmt_ip} "sudo cat /etc/rancher/k3s/k3s.yaml" > k3s-config.yaml

      MGMT_IP="${coalesce(var.cloud_vms["k3s-master"].mgmt_ip, var.cloud_vms["k3s-master"].ip)}"

      echo "Patching kubeconfig server to $MGMT_IP..."
      sed -i "s/127.0.0.1/$MGMT_IP/g" k3s-config.yaml

      echo "Renaming context and cluster to ${var.cluster_name}..."
      export KUBECONFIG=$(pwd)/k3s-config.yaml
      kubectl config rename-context default ${var.cluster_name}
      kubectl config set clusters.default.name ${var.cluster_name} 2>/dev/null || true
      sed -i 's/: default$/: ${var.cluster_name}/g' k3s-config.yaml

      echo "Config saved to $(pwd)/k3s-config.yaml (context: ${var.cluster_name})"
    EOT
  }
}

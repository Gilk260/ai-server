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

  initialization {
    ip_config {
      ipv4 {
        address = "${each.value.ip}/24"
        gateway = "10.0.0.1" # OpnSense LAN IP
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
      echo "⏳ Waiting for K3s to initialize..."
      sleep 30  # Give K3s time to generate the file

      echo "📥 Fetching kubeconfig..."
      ssh -o StrictHostKeyChecking=no -J root@${var.virtual_environment_ip} ubuntu@${var.cloud_vms["k3s-master"].ip} "cat /home/ubuntu/k3s.yaml" > k3s-config.yaml

      echo "🔧 Patching kubeconfig IP..."
      sed -i 's/127.0.0.1/${var.cloud_vms["k3s-master"].ip}/g' k3s-config.yaml

      echo "✅ Config saved to $(pwd)/k3s-config.yaml"
      echo "👉 Run: export KUBECONFIG=$(pwd)/k3s-config.yaml"
    EOT
  }
}

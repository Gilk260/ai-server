locals {
  gaming_address = var.gaming_ip
  gaming_vm_id   = 133
  gaming_hostname = "win11-gaming"
}

resource "proxmox_virtual_environment_vm" "gaming" {
  name = local.gaming_hostname
  description = "Gaming VM"
  tags = ["k8s", "ai", "gaming", "terraform"]
  node_name = data.proxmox_virtual_environment_node.server.node_name

  vm_id = local.gaming_vm_id

  agent {
    enabled = true
  }

  cpu {
    type = "host"
    cores = 6
  }

  memory {
    dedicated = 16384
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.window_img.id
    interface    = "scsi0"
    size         = 200
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi1"
    size         = 1000
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  kvm_arguments = "-cpu 'host,+kvm_pv_unhalt,+kvm_pv_eoi,hv_vendor_id=NV43FIX,kvm=off'"

  machine = "q35"

  hostpci {
    device = "hostpci0"
    id = "0000:01:00"
    pcie = true
    rombar = true
    xvga = false
  }
}

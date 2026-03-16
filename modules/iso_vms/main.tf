resource "proxmox_virtual_environment_vm" "iso" {
  for_each = var.iso_vms

  name      = each.key
  node_name = var.node_name
  vm_id     = each.value.vmid
  tags      = ["terraform", "iso", var.cluster_name]

  on_boot = each.value.on_boot
  started = false
  machine = "q35"

  cpu {
    cores = each.value.cores
    type  = "host"
  }

  memory {
    dedicated = each.value.memory
  }

  disk {
    datastore_id = var.vm_datastore_id
    interface    = "scsi0"
    size         = each.value.disk_size
    file_format  = "raw"
  }

  cdrom {
    file_id = var.image_ids[each.value.os_key]
  }

  boot_order = ["scsi0", "ide3", "net0"]

  dynamic "network_device" {
    for_each = each.value.bridges
    content {
      bridge = network_device.value
    }
  }

  dynamic "hostpci" {
    for_each = each.value.passthrough ? [1] : []
    content {
      device = "hostpci0"
      id     = each.value.pci_id
      pcie   = true
      rombar = true
    }
  }

  operating_system {
    type = "other"
  }
}

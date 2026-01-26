resource "proxmox_virtual_environment_vm" "infra_iso" {
  for_each = var.iso_vms

  name      = each.key
  node_name = data.proxmox_virtual_environment_node.server.node_name
  vm_id     = each.value.vmid

  machine = "q35"

  bios = "seabios"

  cpu {
    cores = each.value.cores
    type  = "host"
  }

  memory {
    dedicated = each.value.memory
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = each.value.disk_size
    file_format  = "raw"
  }

  cdrom {
    file_id = local.image_map[each.value.os_key]
  }

  # Dynamic Network: Loops through the list of bridges (e.g. OpnSense gets 3)
  dynamic "network_device" {
    for_each = each.value.bridges
    content {
      bridge   = network_device.value
      model    = "virtio"
      firewall = false
    }
  }

  # Dynamic PCI Passthrough: Only for Radio AP
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
    type = "l26"
  }

  on_boot = true

  # BOOT PRIORITY: HIGH (Start first)
  startup {
    order      = 1
    up_delay   = 30 # Wait 30s after start before launching the next VM
    down_delay = 30
  }
}

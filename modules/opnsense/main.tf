resource "proxmox_virtual_environment_vm" "opnsense" {
  name      = "opnsense"
  node_name = var.node_name
  vm_id     = var.opnsense_vm.vmid
  tags      = ["terraform", "opnsense", var.cluster_name]

  on_boot = true
  machine = "q35"
  bios    = "seabios"

  startup {
    order      = 1
    up_delay   = 30
    down_delay = 30
  }

  cpu {
    cores = var.opnsense_vm.cores
    type  = "host"
  }

  memory {
    dedicated = var.opnsense_vm.memory
  }

  disk {
    datastore_id = var.vm_datastore_id
    interface    = "scsi0"
    size         = var.opnsense_vm.disk_size
    file_format  = "raw"
  }

  cdrom {
    file_id = var.opnsense_iso_file_id
  }

  boot_order = ["scsi0", "ide3", "net0"]

  # WAN: home LAN
  network_device {
    bridge   = "vmbr0"
    model    = "virtio"
    firewall = false
  }

  # LAN: private network
  network_device {
    bridge   = var.lan_bridge
    model    = "virtio"
    firewall = false
  }

  operating_system {
    type = "other"
  }
}

resource "wireguard_asymmetric_key" "vpn" {}

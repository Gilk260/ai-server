# OPNsense firewall/router VM (manual install via Proxmox console)
resource "proxmox_virtual_environment_vm" "opnsense" {
  name      = "opnsense"
  node_name = data.proxmox_virtual_environment_node.server.node_name
  vm_id     = var.opnsense_vm.vmid
  tags      = ["terraform", "opnsense", var.cluster_name]

  on_boot = true

  machine = "q35"
  bios    = "seabios"

  # Must boot before all other VMs (OPNsense provides routing)
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
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = var.opnsense_vm.disk_size
    file_format  = "raw"
  }

  cdrom {
    file_id = proxmox_virtual_environment_download_file.opnsense_iso.id
  }

  # Boot from disk first, then CDROM (ISO only needed for initial install)
  boot_order = ["scsi0", "ide3", "net0"]

  # WAN: home LAN (DHCP from router)
  network_device {
    bridge   = "vmbr0"
    model    = "virtio"
    firewall = false
  }

  # LAN: private network
  network_device {
    bridge   = "vmbr1"
    model    = "virtio"
    firewall = false
  }

  operating_system {
    type = "other" # FreeBSD
  }

  depends_on = [proxmox_virtual_environment_network_linux_bridge.vmbr1]
}

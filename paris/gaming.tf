locals {
  gaming_address  = var.gaming_ip
  gaming_vm_id    = 134
  gaming_hostname = "gaming-rig"
}

resource "proxmox_virtual_environment_vm" "gaming" {
  name        = local.gaming_hostname
  description = "Gaming VM"
  tags        = ["k8s", "ai", "gaming", "terraform"]
  node_name   = data.proxmox_virtual_environment_node.server.node_name
  vm_id       = local.gaming_vm_id

  bios = "ovmf"

  efi_disk {
    datastore_id = "local-lvm"
    file_format  = "raw"
    type         = "4m"
  }

  agent {
    enabled = true
  }

  cpu {
    type  = "host"
    cores = 4
  }

  memory {
    dedicated = 16384
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.latest_ubuntu_22_jammy_qcow2_img.id
    interface    = "scsi0"
    size         = 128
    # discard      = "on"
    # ssd          = true
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${local.gaming_address}/32"
        gateway = "192.168.1.1"
      }
      ipv6 {
        address = "dhcp"
      }
    }

    user_account {
      password = "qwerty"
      username = "Gilk" # Changed user to gamer
    }

    user_data_file_id = proxmox_virtual_environment_file.gaming_config.id
  }

  kvm_arguments = "-cpu 'host,+kvm_pv_unhalt,+kvm_pv_eoi,hv_vendor_id=NV43FIX,kvm=off'"
  machine       = "q35"

  # Video
  # hostpci {
  #   device = "hostpci0"
  #   id     = "0000:01:00.0" # Verify this is your GPU ID in Proxmox
  #   pcie   = true
  #   xvga   = false # Tries to make this the primary GPU

  #   rombar = false
  #   rom_file = "gtx970_dump.bin"
  # }

  # Audio
  # hostpci {
  #   device = "hostpci1"
  #   id     = "0000:01:00.1"
  #   pcie   = true
  #   rombar = true
  # }
}

resource "proxmox_virtual_environment_file" "gaming_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = data.proxmox_virtual_environment_node.server.node_name

  source_raw {
    data = <<-EOF
    #cloud-config
    hostname: ${local.gaming_hostname}

    # User config
    ssh_pwauth: true # Enabled for easier initial setup
    ssh_authorized_keys:
      - ${var.ssh_key}

    users:
      - default
      - name: Gilk
        groups: sudo, video, render # video/render groups crucial for GPU access
        shell: /bin/bash
        sudo: 'ALL=(ALL) NOPASSWD:ALL'

    package_upgrade: true

    # Install Desktop & Gaming deps
    # Warning: This makes the first boot take 5-10 mins
    packages:
      - qemu-guest-agent
      - ubuntu-desktop-minimal # War Thunder needs a GUI
      - mesa-utils
      - vulkan-tools
      - steam-installer # Easiest way to get 32-bit libs/deps even for non-steam games

    write_files:
      - path: /etc/modules-load.d/k8s.conf
        content: |
          br_netfilter
      - path: /etc/sysctl.d/k8s.conf
        content: |
          net.bridge.bridge-nf-call-ip6tables = 1
          net.bridge.bridge-nf-call-iptables = 1
          net.ipv4.ip_forward = 1
          net.ipv6.conf.all.forwarding = 1

    runcmd:
      - systemctl enable qemu-guest-agent
      - systemctl start qemu-guest-agent
      - modprobe br_netfilter
      - sysctl --system
      # Disable Wayland for now (Sunshine often happier on X11 for beginners)
      - sed -i 's/#WaylandEnable=false/WaylandEnable=false/' /etc/gdm3/custom.conf
      - systemctl set-default graphical.target
      - ubuntu-drivers autoinstall
      - reboot
    EOF

    file_name = "gaming.cloud-config.yaml"
  }
}

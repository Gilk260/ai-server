locals {
  gaming_address  = var.gaming_ip
  gaming_vm_id    = 134
  gaming_hostname = "gaming-rig"
}

# =============================================================================
# Windows 11 Gaming VM (cloned from Packer template)
# =============================================================================

resource "proxmox_virtual_environment_vm" "gaming" {
  name        = local.gaming_hostname
  description = "Windows 11 Gaming VM with GPU Passthrough"
  tags        = ["gaming", "windows", "gpu-passthrough", "terraform"]
  node_name   = data.proxmox_virtual_environment_node.server.node_name
  vm_id       = local.gaming_vm_id

  clone {
    vm_id = data.proxmox_virtual_environment_vm.win11_template.vm_id
    full  = true
  }

  bios    = "ovmf"
  machine = "q35"

  # EFI disk inherited from template, but we need to specify it
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
    dedicated = 12288
  }

  # Disks inherited from template (120GB system + 500GB games)

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  # GPU Passthrough - GTX 970 (Video + Audio in same IOMMU group)
  hostpci {
    device   = "hostpci0"
    id       = "0000:01:00"
    pcie     = true
    rombar   = true
  }

  # KVM args to prevent NVIDIA Code 43 error
  kvm_arguments = "-cpu 'host,+kvm_pv_unhalt,+kvm_pv_eoi,hv_vendor_id=NV43FIX,kvm=off'"

  # Disable emulated VGA when using GPU passthrough
  vga {
    type = "none"
  }

  # Windows doesn't use cloud-init, skip initialization block
  # Static IP should be configured in Windows after first boot
  # or via DHCP reservation on your router
}

data "proxmox_virtual_environment_vm" "win11_template" {
  node_name = data.proxmox_virtual_environment_node.server.node_name
  vm_id     = var.win11_template_vm_id
}

# =============================================================================
# COMMENTED OUT: Original Ubuntu Gaming VM
# =============================================================================

# resource "proxmox_virtual_environment_vm" "gaming_ubuntu" {
#   name        = local.gaming_hostname
#   description = "Gaming VM"
#   tags        = ["k8s", "ai", "gaming", "terraform"]
#   node_name   = data.proxmox_virtual_environment_node.server.node_name
#   vm_id       = local.gaming_vm_id
#
#   bios = "ovmf"
#
#   efi_disk {
#     datastore_id = "local-lvm"
#     file_format  = "raw"
#     type         = "4m"
#   }
#
#   agent {
#     enabled = true
#   }
#
#   cpu {
#     type  = "host"
#     cores = 4
#   }
#
#   memory {
#     dedicated = 12288
#   }
#
#   disk {
#     datastore_id = "local-lvm"
#     file_id      = proxmox_virtual_environment_download_file.latest_ubuntu_22_jammy_qcow2_img.id
#     interface    = "scsi0"
#     size         = 128
#   }
#
#   network_device {
#     bridge = "vmbr0"
#     model  = "virtio"
#   }
#
#   initialization {
#     ip_config {
#       ipv4 {
#         address = "${local.gaming_address}/24"
#         gateway = "192.168.1.1"
#       }
#       ipv6 {
#         address = "dhcp"
#       }
#     }
#
#     user_account {
#       password = "qwerty"
#       username = "Gilk"
#     }
#
#     user_data_file_id = proxmox_virtual_environment_file.gaming_config.id
#   }
#
#   kvm_arguments = "-cpu 'host,+kvm_pv_unhalt,+kvm_pv_eoi,hv_vendor_id=NV43FIX,kvm=off'"
#   machine       = "q35"
#
#   vga {
#     type = "none"
#   }
#
#   hostpci {
#     device   = "hostpci0"
#     id       = "0000:01:00"
#     pcie     = true
#     rombar   = true
#   }
# }

# resource "proxmox_virtual_environment_file" "gaming_config" {
#   content_type = "snippets"
#   datastore_id = "local"
#   node_name    = data.proxmox_virtual_environment_node.server.node_name
#
#   source_raw {
#     data = <<-EOF
#     #cloud-config
#     hostname: ${local.gaming_hostname}
#
#     ssh_pwauth: true
#     ssh_authorized_keys:
#       - ${var.ssh_key}
#
#     users:
#       - default
#       - name: Gilk
#         groups: sudo, video, render
#         shell: /bin/bash
#         sudo: 'ALL=(ALL) NOPASSWD:ALL'
#
#     package_upgrade: true
#
#     packages:
#       - qemu-guest-agent
#       - ubuntu-desktop-minimal
#       - mesa-utils
#       - vulkan-tools
#       - steam-installer
#
#     write_files:
#       - path: /etc/modules-load.d/k8s.conf
#         content: |
#           br_netfilter
#       - path: /etc/sysctl.d/k8s.conf
#         content: |
#           net.bridge.bridge-nf-call-ip6tables = 1
#           net.bridge.bridge-nf-call-iptables = 1
#           net.ipv4.ip_forward = 1
#           net.ipv6.conf.all.forwarding = 1
#
#     runcmd:
#       - systemctl enable qemu-guest-agent
#       - systemctl start qemu-guest-agent
#       - modprobe br_netfilter
#       - sysctl --system
#       - sed -i 's/#WaylandEnable=false/WaylandEnable=false/' /etc/gdm3/custom.conf
#       - systemctl set-default graphical.target
#       - ubuntu-drivers autoinstall
#       - reboot
#     EOF
#
#     file_name = "gaming.cloud-config.yaml"
#   }
# }

# resource "time_sleep" "wait_for_boot" {
#   depends_on = [proxmox_virtual_environment_vm.gaming]
#
#   create_duration = "180s"
# }

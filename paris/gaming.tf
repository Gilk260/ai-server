# Gaming VM — DEFERRED (needs Packer-built Win11 template, GPU passthrough fix)
# Uncomment and run `packer build` in windows11-packer/ first.
#
# data "proxmox_virtual_environment_vm" "win11_template" {
#   node_name = data.proxmox_virtual_environment_node.server.node_name
#   vm_id     = var.gaming_vm.template_vm_id
# }
#
# resource "proxmox_virtual_environment_vm" "gaming" {
#   name      = "gaming-rig"
#   node_name = data.proxmox_virtual_environment_node.server.node_name
#   vm_id     = var.gaming_vm.vmid
#   tags      = ["terraform", "gaming", "windows"]
#
#   on_boot = var.gaming_vm.on_boot
#   started = false
#
#   machine       = "q35"
#   bios          = "ovmf"
#   scsi_hardware = "virtio-scsi-single"
#
#   cpu {
#     cores = var.gaming_vm.cores
#     type  = "host"
#   }
#
#   memory {
#     dedicated = var.gaming_vm.memory
#   }
#
#   agent {
#     enabled = true
#   }
#
#   network_device {
#     bridge = "vmbr0"
#   }
#
#   hostpci {
#     device = "hostpci0"
#     id     = "0000:01:00"
#     pcie   = true
#     rombar = true
#   }
#
#   kvm_arguments = "-cpu 'host,+kvm_pv_unhalt,+kvm_pv_eoi,hv_vendor_id=NV43FIX,kvm=off'"
#
#   vga {
#     type = "none"
#   }
#
#   clone {
#     vm_id = data.proxmox_virtual_environment_vm.win11_template.vm_id
#     full  = true
#   }
#
#   efi_disk {
#     datastore_id = "local-lvm"
#     type         = "4m"
#   }
#
#   initialization {
#     ip_config {
#       ipv4 {
#         address = "${var.gaming_vm.ip}/24"
#         gateway = "192.168.1.1"
#       }
#     }
#   }
#
#   lifecycle {
#     ignore_changes = [
#       disk,
#       clone,
#     ]
#   }
# }

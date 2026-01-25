locals {
  worker_address  = var.worker_ip
  worker_vm_id    = 1001001
  worker_hostname = "worker"
}

# resource "wireguard_asymmetric_key" "worker" {
# }
# 
# resource "wireguard_preshared_key" "worker" {
# }

resource "proxmox_virtual_environment_vm" "worker" {
  name        = "worker"
  description = "Worker for AI's inference cluster"
  tags        = ["k8s", "ai", "worker", "terraform"]
  node_name   = data.proxmox_virtual_environment_node.server.node_name

  vm_id = local.worker_vm_id

  bios = "ovmf"

  agent {
    enabled = true
  }

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 8192
  }

  efi_disk {
    datastore_id = "local-lvm"
    file_format  = "raw"
    type         = "4m"
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.latest_ubuntu_22_jammy_qcow2_img.id
    interface    = "scsi0"
    size         = 32
  }

  network_device {
    bridge = "vmbr1"
    model  = "virtio"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${local.worker_address}/24"
        gateway = var.router_gateway
      }

      ipv6 {
        address = "dhcp"
      }
    }

    user_account {
      password = "qwerty"
      username = "toto"
    }
    user_data_file_id = proxmox_virtual_environment_file.worker_config.id
  }

  kvm_arguments = "-cpu host,kvm=off,hv_vendor_id=null"
  machine       = "q35"

  hostpci {
    device = "hostpci0"
    id     = "0000:01:00"
    pcie   = false
    xvga   = false
    rombar = true
    # rom_file = "gtx950m.bin"
  }
}

resource "proxmox_virtual_environment_file" "worker_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = data.proxmox_virtual_environment_node.server.node_name

  source_raw {
    data = <<-EOF
    #cloud-config
    hostname: ${local.worker_hostname}

    ssh_pwauth: false
    ssh_authorized_keys:
      - ${var.ssh_key}

    users:
      - default
      - name: ubuntu
        groups: sudo
        sudo: 'ALL=(ALL) NOPASSWD:ALL'

    package_upgrade: true
    packages:
      - qemu-guest-agent
      - python3
      - nvidia-driver-470
      - nvidia-utils-470
      - nvidia-headless-470
      - nvidia-headless-no-dkms-470

    # Let iptables see bridged traffic
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
      - path: /etc/modprobe.d/blacklist-nouveau.conf
        content: |
          blacklist nouveau
          options nouveau modeset=0
      - path: /etc/default/grub.d/99-passthrough.cfg
        content: |
          GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT nvidia-drm.modeset=0 pcie_aspm=off iommu=igfx_off"
      - path: /etc/modprobe.d/nvidia.conf
        content: |
          options nvidia NVreg_EnableMSI=0

    runcmd:
      - apt-mark hold nvidia-driver-470
      - update-grub
      - update-initramfs -u

      - systemctl enable qemu-guest-agent
      - systemctl start qemu-guest-agent
      - modprobe br_netfilter
      - sysctl --system
    EOF

    file_name = "worker.cloud-config.yaml"
  }
}

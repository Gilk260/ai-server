packer {
  required_version = "~> 1.14.0"
  required_plugins {
    windows-update = {
      version = "0.14.3"
      source = "github.com/rgl/windows-update"
    }
    proxmox = {
      version = "~> 1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "win_iso" {
  type    = string
  default = "local:iso/Win11.iso"
}

variable "virtio_iso" {
  type    = string
  default = "local:iso/virtio-win-0.1.285.iso"
}

variable "proxmox_url" {
  type    = string
  default = "https://192.168.1.3:8006/api2/json"
}

variable "proxmox_root_password" {
  type = string
  sensitive = true
}

source "proxmox-iso" "windows_11" {
  proxmox_url = var.proxmox_url
  insecure_skip_tls_verify = true
  username = "root@pam"
  password = var.proxmox_root_password
  node = "paris"

  qemu_agent = true

  bios = "ovmf"
  machine = "pc-q35-10.1"

  efi_config {
    efi_storage_pool = "local-lvm"
    pre_enrolled_keys = true
    efi_type = "4m"
  }

  # TPM 2.0 - required for Windows 11
  tpm_config {
    tpm_version = "v2.0"
    tpm_storage_pool = "local-lvm"
  }

  # Windows ISO on IDE2 (matching working VM)
  boot_iso {
    type     = "ide"
    index    = 2
    iso_file = var.win_iso
    unmount  = true
  }

  # VirtIO Drivers on IDE0 (matching working VM)
  additional_iso_files {
    iso_file = var.virtio_iso
    unmount  = false
    type     = "ide"
    index    = 0
  }

  # Unattend.xml and setup script on IDE1 - OEMDRV label is auto-searched by Windows
  additional_iso_files {
    cd_content = {
      "Autounattend.xml" = file("autounattend.xml")
      "setup-winrm.ps1"  = file("setup-winrm.ps1")
    }
    cd_label = "OEMDRV"
    iso_storage_pool = "local"
    unmount = true
    type    = "ide"
    index   = 1
  }

  template_name = "templ-win11-gaming"
  template_description = "Windows 11 Gaming - ${timestamp()}"
  vm_name = "win11-gaming-packer"
  memory = 8192
  cores = 4
  sockets = 1
  cpu_type = "x86-64-v2-AES"
  os = "win11"
  network_adapters {
    model = "e1000"
    bridge = "vmbr0"
  }

  disks {
    storage_pool = "local-lvm"
    type = "sata"
    disk_size = "128G"
    cache_mode = "writeback"
    format = "raw"
  }

  communicator   = "winrm"
  winrm_username = "Gilk"
  winrm_password = "1904"
  winrm_timeout  = "2h"
  winrm_port     = "5985"
  winrm_use_ssl  = false
  winrm_insecure = true
  winrm_use_ntlm = true

  boot_wait = "5s"
  boot_command = ["<enter>"]
}

build {
  name = "Proxmox Build"
  sources = ["source.proxmox-iso.windows_11"]

  # 1. Upload scripts folder
  provisioner "file" {
    source      = "scripts/"
    destination = "C:\\Windows\\Temp\\scripts"
  }

  # 2. Run Setup scripts
  provisioner "powershell" {
    inline = [
      "Set-ExecutionPolicy Bypass -Scope Process -Force",
      "C:\\Windows\\Temp\\scripts\\setup.ps1",
      "C:\\Windows\\Temp\\scripts\\install-nvidia.ps1",
      "C:\\Windows\\Temp\\scripts\\install-steam.ps1",
      "C:\\Windows\\Temp\\scripts\\install-sunshine.ps1",
      "C:\\Windows\\Temp\\scripts\\configure_game_disk.ps1",
      "C:\\Windows\\Temp\\scripts\\optimize-windows.ps1",
    ]
  }

  # 3. Sysprep and Shutdown
  provisioner "powershell" {
    inline = [
      "C:\\Windows\\Temp\\scripts\\sysprep.ps1"
    ]
  }
}

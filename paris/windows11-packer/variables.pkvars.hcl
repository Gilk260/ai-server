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
  default = "https://192.168.1.3:8006/"
}

variable "proxmox_root_password" {
  type = string
  sensitive = true
}

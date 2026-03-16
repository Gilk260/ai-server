variable "node_name" {
  type = string
}

variable "opnsense_vm" {
  type = object({
    vmid      = number
    cores     = number
    memory    = number
    disk_size = number
  })
}

variable "cluster_name" {
  type = string
}

variable "network_subnet" {
  type        = string
  description = "Private LAN CIDR (e.g., 10.0.0.0/16)"
}

# variable "wireguard_subnet" {
#   type = string
# }

variable "opnsense_iso_file_id" {
  type        = string
  description = "Proxmox file ID of the OPNsense ISO"
}

variable "lan_bridge" {
  type        = string
  description = "LAN bridge name (e.g., vmbr1)"
  default     = "vmbr1"
}

variable "wireguard_port" {
  type    = number
  default = 51820
}

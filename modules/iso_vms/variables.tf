variable "node_name" {
  type = string
}

variable "iso_vms" {
  type = map(object({
    vmid        = number
    cores       = number
    memory      = number
    disk_size   = number
    os_key      = string
    bridges     = list(string)
    passthrough = optional(bool, false)
    pci_id      = optional(string)
    on_boot     = optional(bool, false)
  }))
}

variable "cluster_name" {
  type = string
}

variable "image_ids" {
  type        = map(string)
  description = "Map of os_key => Proxmox file ID for ISO images"
}

variable "vm_datastore_id" {
  type    = string
  default = "local-lvm"
}

variable "node_name" {
  type = string
}

variable "pihole_ct" {
  type = object({
    vmid   = number
    cores  = number
    memory = number
    disk   = number
    ip     = string
  })
}

variable "gateway_ip" {
  type = string
}

variable "network_subnet" {
  type        = string
  description = "Private network CIDR (for IP address mask)"
}

variable "cluster_name" {
  type = string
}

variable "cluster_domain" {
  type = string
}

variable "ssh_key" {
  type      = string
  sensitive = true
}

variable "proxmox_ip" {
  type        = string
  description = "Proxmox host IP for SSH provisioner (pct exec)"
}

variable "lxc_template_file_id" {
  type        = string
  description = "Proxmox file ID of the Debian LXC template"
}

variable "lan_bridge" {
  type    = string
  default = "vmbr1"
}

variable "vm_datastore_id" {
  type    = string
  default = "local-lvm"
}

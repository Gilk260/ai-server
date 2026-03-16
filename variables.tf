# --- Cluster identity ---
variable "cluster_name" {
  type        = string
  description = "Cluster name (must match workspace name: dev or prod)"
}

variable "cluster_domain" {
  type        = string
  description = "Domain for cluster services (e.g., dev.g.recouvreux.fr)"
}

variable "proxmox_node_name" {
  type        = string
  description = "Proxmox node name"
}

variable "vm_datastore_id" {
  type    = string
  default = "local-lvm"
}

# --- Proxmox connection (sensitive) ---
variable "virtual_environment_endpoint" {
  type = string
}

variable "virtual_environment_username" {
  type = string
}

variable "virtual_environment_password" {
  type      = string
  sensitive = true
}

# --- SSH ---
variable "ssh_key" {
  type      = string
  sensitive = true
}

# --- Networking ---
variable "network_subnet" {
  type        = string
  description = "Private network CIDR for VM IPs (e.g., 10.0.0.0/16)"
}

variable "gateway_ip" {
  type        = string
  description = "OPNsense LAN gateway IP (e.g., 10.0.0.1)"
}




variable "bridges" {
  type = list(object({
    name    = string
    address = string
    comment = optional(string, "")
  }))
  description = "Proxmox network bridges to create"
}

# --- WireGuard ---
variable "wireguard_subnet" {
  type        = string
  description = "WireGuard VPN subnet (e.g., 10.10.10.0/24)"
}

# --- K3s ---
variable "k3s_version" {
  type = string
}

# --- Cloud-init VMs ---
variable "cloud_vms" {
  type = map(object({
    vmid      = number
    cores     = number
    memory    = number
    ip        = string
    mgmt_ip   = optional(string)
    disk_size = number
    os_key    = string
    k3s_role  = optional(string)
    on_boot   = optional(bool, true)
    packages  = optional(list(string), [])
    runcmd    = optional(list(string), [])
  }))
}

# --- ISO VMs (optional) ---
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
  }))
  default = {}
}

# --- OPNsense ---
variable "opnsense_vm" {
  type = object({
    vmid      = number
    cores     = number
    memory    = number
    disk_size = number
  })
}

# --- Pi-hole ---
variable "pihole_ct" {
  type = object({
    vmid   = number
    cores  = number
    memory = number
    disk   = number
    ip     = string
  })
}

# --- OPNsense provider credentials ---
variable "opnsense_endpoint" {
  type        = string
  description = "OPNsense API endpoint URL (e.g., https://10.0.0.1)"
}

variable "opnsense_api_key" {
  type      = string
  sensitive = true
}

variable "opnsense_api_secret" {
  type      = string
  sensitive = true
}

# --- Images ---
variable "images" {
  type = map(object({
    content_type            = string
    url                     = string
    file_name               = optional(string)
    datastore_id            = optional(string, "local")
    decompression_algorithm = optional(string)
    overwrite               = optional(bool, false)
  }))
  default     = {}
  description = "OS images, ISOs, and LXC templates to download"
}

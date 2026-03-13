variable "node_name" {
  type = string
}

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

variable "ssh_key" {
  type      = string
  sensitive = true
}

variable "gateway_ip" {
  type = string
}

variable "network_subnet" {
  type        = string
  description = "Private network CIDR (for IP address mask, e.g., 10.0.0.0/16)"
}

variable "k3s_version" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cluster_domain" {
  type = string
}

variable "templates_path" {
  type        = string
  description = "Absolute path to the templates/ directory"
}

variable "image_ids" {
  type        = map(string)
  description = "Map of os_key => Proxmox file ID for cloud images"
}

variable "lan_bridge" {
  type    = string
  default = "vmbr1"
}

variable "mgmt_bridge" {
  type        = string
  description = "Management NIC bridge (e.g., vmbr0)"
  default     = "vmbr0"
}

variable "k3s_server_ip" {
  type        = string
  description = "K3s server IP (for agent nodes to join)"
  default     = null
}

variable "k3s_mgmt_ip" {
  type        = string
  description = "K3s server management IP (for kubeconfig fetch)"
  default     = null
}

variable "kubeconfig_output_path" {
  type        = string
  description = "Absolute path where k3s-config.yaml will be written"
}

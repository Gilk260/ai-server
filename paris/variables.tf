# --- Sensitive (from terraform.tfvars) ---
variable "virtual_environment_username" {
  type      = string
  sensitive = true
}

variable "virtual_environment_password" {
  type      = string
  sensitive = true
}

variable "virtual_environment_endpoint" {
  type      = string
  sensitive = true
}

variable "ssh_key" {
  type      = string
  sensitive = true
}

# --- Infrastructure ---
variable "cluster_name" {
  type    = string
  default = "paris"
}

variable "cluster_domain" {
  type        = string
  description = "Domain for cluster services (e.g., paris.g.recouvreux.fr)"
}

variable "k3s_version" {
  type    = string
  default = "v1.31.4+k3s1"
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
    packages  = optional(list(string), [])
    runcmd    = optional(list(string), [])
    k3s_role  = optional(string, "")
    on_boot   = optional(bool, true)
  }))
  default = {
    "k3s" = {
      vmid      = 200
      cores     = 4
      memory    = 10240
      ip        = "10.1.10.1"
      mgmt_ip   = "192.168.1.10"
      disk_size = 64
      os_key    = "ubuntu-noble"
      k3s_role  = "server"
      on_boot   = true
      packages  = ["nfs-common", "open-iscsi", "jq"]
      runcmd    = []
    }
  }
}

variable "opnsense_vm" {
  type = object({
    vmid      = number
    cores     = number
    memory    = number
    disk_size = number
  })
  default = {
    vmid      = 101
    cores     = 2
    memory    = 2048
    disk_size = 16
  }
}

variable "pihole_ct" {
  type = object({
    vmid   = number
    cores  = number
    memory = number
    disk   = number
    ip     = string
  })
  default = {
    vmid   = 102
    cores  = 1
    memory = 512
    disk   = 4
    ip     = "10.1.0.2"
  }
}

variable "gaming_vm" {
  type = object({
    vmid           = number
    cores          = number
    memory         = number
    ip             = string
    on_boot        = bool
    template_vm_id = number
  })
  default = {
    vmid           = 201
    cores          = 4
    memory         = 12288
    ip             = "192.168.1.33"
    on_boot        = false
    template_vm_id = 100
  }
}

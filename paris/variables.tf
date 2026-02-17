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

variable "control_plane_ip" {
  type        = string
  default     = "192.168.1.9"
  description = "Control plane IP"
}

variable "gaming_ip" {
  type        = string
  default     = "192.168.1.33"
  description = "Gaming IP"
}

variable "worker_ip" {
  type        = string
  default     = "192.168.1.34"
  description = "Worker IP"
}


variable "claude_code_ip" {
  type        = string
  default     = "192.168.1.35"
  description = "Worker IP"
}

variable "win11_template_vm_id" {
  type        = number
  description = "VM ID of the Windows 11 gaming template created by Packer"
  # After running Packer, find the template VM ID in Proxmox and set this value
  # in your terraform.tfvars file
}

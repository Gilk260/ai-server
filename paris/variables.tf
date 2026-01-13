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


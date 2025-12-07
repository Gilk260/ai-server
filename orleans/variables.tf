variable "virtual_environment_username" {
  type = string
  sensitive = true
}

variable "virtual_environment_password" {
  type = string
  sensitive = true
}

variable "virtual_environment_endpoint" {
  type = string
  sensitive = true
}

variable "ssh_key" {
  type = string
  sensitive = true
}

variable "control_plane_ip" {
  type = string
  default = "192.168.1.8"
  description = "Control plane IP"
}

variable "worker_ip" {
  type = string
  default = "192.168.1.32"
  description = "Worker IP"
}

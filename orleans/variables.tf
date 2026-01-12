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
  default     = "10.0.10.1"
  description = "Control plane IP"
}

variable "control_plane_wg_ip" {
  type        = string
  default     = "10.0.0.8"
  description = "Control plane Wireguard IP"
}

variable "worker_ip" {
  type        = string
  default     = "10.0.100.1"
  description = "Worker IP"
}

variable "worker_wg_ip" {
  type        = string
  default     = "10.0.0.32"
  description = "Control plane Wireguard IP"
}

variable "sinkhole_ip" {
  type        = string
  default     = "192.168.1.200"
  description = "DNS IP"
}

variable "adguard_password" {
  type      = string
  sensitive = true
}

variable "adguard_password_hash" {
  type      = string
  sensitive = true
}

variable "router_gateway" {
  type        = string
  default     = "10.0.0.1"
  description = "Router Gateway"
}

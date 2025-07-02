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

variable "cluster_address" {
  type = string
  default = "192.168.1.101"
  description = "Cluster address"
}

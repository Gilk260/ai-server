variable "node_name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "virtual_environment_endpoint" {
  type      = string
  sensitive = true
}

variable "opnsense_api_key" {
  type      = string
  sensitive = true
}

variable "opnsense_api_secret" {
  type      = string
  sensitive = true
}

variable "victoria_metrics_target_ip" {
  type        = string
  description = "IP where VictoriaMetrics is reachable (usually K3s mgmt IP)"
  default     = null
}

variable "victoria_metrics_port" {
  type    = number
  default = 30428
}

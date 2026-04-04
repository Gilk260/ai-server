variable "cluster_name" {
  type = string
}

variable "cluster_domain" {
  type = string
}

variable "private_key_path" {
  type        = string
  description = "Path to ArgoCD GitHub App private key PEM file"
}

variable "helm_values_path" {
  type        = string
  description = "Path to ArgoCD Helm values YAML file"
}

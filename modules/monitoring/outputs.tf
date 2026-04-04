output "monitoring_namespace" {
  value = kubernetes_namespace_v1.monitoring.metadata[0].name
}

output "proxmox_exporter_token_id" {
  value = proxmox_virtual_environment_user_token.monitoring.id
}

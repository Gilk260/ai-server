resource "proxmox_virtual_environment_user" "monitoring" {
  comment = "Read-only monitoring user for proxmox-exporter"
  user_id = "monitoring@pve"

  acl {
    path      = "/"
    propagate = true
    role_id   = "PVEAuditor"
  }
}

resource "proxmox_virtual_environment_user_token" "monitoring" {
  comment               = "proxmox-exporter API token"
  token_name            = "exporter"
  user_id               = proxmox_virtual_environment_user.monitoring.user_id
  privileges_separation = false
}

resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = "monitoring"
  }

  lifecycle {
    ignore_changes = [metadata[0].labels, metadata[0].annotations]
  }
}

resource "kubernetes_secret_v1" "proxmox_exporter_credentials" {
  metadata {
    name      = "proxmox-exporter-credentials"
    namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
  }

  data = {
    PROXMOX_EXPORTER_PROXMOX_ENDPOINTS = var.virtual_environment_endpoint
    PROXMOX_EXPORTER_PROXMOX_TOKEN     = proxmox_virtual_environment_user_token.monitoring.value
    PROXMOX_EXPORTER_PROXMOX_TOKEN_ID  = proxmox_virtual_environment_user_token.monitoring.id
  }
}

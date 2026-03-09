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
  depends_on = [null_resource.k3s_kubeconfig]

  metadata {
    name = "monitoring"
    labels = {
      "pod-security.kubernetes.io/enforce" = "baseline"
      "pod-security.kubernetes.io/audit"   = "restricted"
      "pod-security.kubernetes.io/warn"    = "restricted"
    }
  }

  lifecycle {
    ignore_changes = [metadata[0].labels, metadata[0].annotations]
  }
}

resource "kubernetes_secret_v1" "proxmox_exporter_credentials" {
  depends_on = [kubernetes_namespace_v1.monitoring]

  metadata {
    name      = "proxmox-exporter-credentials"
    namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
  }

  data = {
    PROXMOX_EXPORTER_PROXMOX_ENDPOINTS = var.virtual_environment_endpoint
    PROXMOX_EXPORTER_PROXMOX_TOKEN     = split("=", proxmox_virtual_environment_user_token.monitoring.value)[1]
    PROXMOX_EXPORTER_PROXMOX_TOKEN_ID  = proxmox_virtual_environment_user_token.monitoring.id
  }
}

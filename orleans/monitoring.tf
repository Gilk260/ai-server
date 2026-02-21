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

resource "kubernetes_namespace_v1" "victoria-metrics" {
  metadata {
    name = "victoria-metrics"
  }

  lifecycle {
    ignore_changes = [metadata[0].labels, metadata[0].annotations]
  }
}

resource "kubernetes_secret_v1" "proxmox_exporter_credentials" {
  depends_on = [ kubernetes_namespace_v1.monitoring ]

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

resource "random_password" "default_password" {
  length  = 24
  special = true
}

resource "kubernetes_secret_v1" "grafana_admin_credentials" {
  depends_on = [kubernetes_namespace_v1.victoria-metrics]

  metadata {
    name      = "grafana-admin-credentials"
    namespace = kubernetes_namespace_v1.victoria-metrics.metadata[0].name
  }

  data = {
    admin-password = random_password.default_password.result
    admin-user     = "admin"
  }
}

resource "proxmox_virtual_environment_metrics_server" "victoria_metrics" {
  name                = "victoria-metrics"
  type                = "influxdb"
  server              = var.cloud_vms["k3s-master"].mgmt_ip
  port                = 30428
  influx_db_proto     = "http"
  influx_organization = "proxmox"
  influx_bucket       = "proxmox"
}

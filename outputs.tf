output "k3s_server_ip" {
  value = module.cloud_vms.k3s_server_ip
}

output "cloud_vm_ips" {
  value = module.cloud_vms.vm_ips
}

output "pihole_ip" {
  value = module.pihole.pihole_ip
}

output "monitoring_namespace" {
  value = module.monitoring.monitoring_namespace
}

output "argocd_namespace" {
  value = module.argocd.namespace
}

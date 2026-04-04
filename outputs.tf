output "k3s_server_ip" {
  value = module.cloud_vms.k3s_server_ip
}

output "cloud_vm_ips" {
  value = module.cloud_vms.vm_ips
}

output "blocky_ip" {
  value = module.blocky.blocky_ip
}

output "monitoring_namespace" {
  value = module.monitoring.monitoring_namespace
}

output "argocd_namespace" {
  value = module.argocd.namespace
}

output "wireguard_server_public_key" {
  value = module.opnsense.wireguard_server_public_key
}

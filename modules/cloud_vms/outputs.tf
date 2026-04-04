output "vm_ips" {
  value = { for k, v in var.cloud_vms : k => v.ip }
}

output "k3s_server_ip" {
  value = try([
    for name, vm in var.cloud_vms : vm.ip
    if vm.k3s_role == "server"
  ][0], null)
}

output "k3s_kubeconfig_ready" {
  value = terraform_data.k3s_kubeconfig.id
}

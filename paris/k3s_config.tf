resource "null_resource" "k3s_kubeconfig" {
  depends_on = [proxmox_virtual_environment_vm.cloud]

  triggers = {
    k3s_server_id = join(",", [
      for name, vm in proxmox_virtual_environment_vm.cloud :
      vm.id if var.cloud_vms[name].k3s_role == "server"
    ])
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Fetch kubeconfig via mgmt NIC (direct laptop access, bypasses OPNsense)
      ssh -o StrictHostKeyChecking=no ubuntu@${local.k3s_mgmt_ip} \
          'sudo cat /etc/rancher/k3s/k3s.yaml' \
        | sed "s|127.0.0.1|${local.k3s_mgmt_ip}|g" \
        | sed "s|default|${var.cluster_name}|g" \
        > ${path.module}/k3s-config.yaml

      echo "Kubeconfig saved to ${path.module}/k3s-config.yaml"
    EOT
  }
}

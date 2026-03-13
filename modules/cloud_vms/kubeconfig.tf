resource "terraform_data" "k3s_kubeconfig" {
  count = var.k3s_mgmt_ip != null ? 1 : 0

  depends_on = [proxmox_virtual_environment_vm.cloud]

  triggers_replace = [
    join(",", [
      for name, vm in proxmox_virtual_environment_vm.cloud :
      vm.id if var.cloud_vms[name].k3s_role == "server"
    ])
  ]

  provisioner "local-exec" {
    command = <<-EOT
      ssh -o StrictHostKeyChecking=no ubuntu@${var.k3s_mgmt_ip} \
          'sudo cat /etc/rancher/k3s/k3s.yaml' \
        | sed "s|127.0.0.1|${var.k3s_mgmt_ip}|g" \
        | sed "s|default|${var.cluster_name}|g" \
        > ${var.kubeconfig_output_path}

      echo "Kubeconfig saved to ${var.kubeconfig_output_path}"
    EOT
  }
}

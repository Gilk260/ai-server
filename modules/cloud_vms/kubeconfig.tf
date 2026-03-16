locals {
  k3s_fetch_ip   = coalesce(var.k3s_mgmt_ip, var.k3s_server_ip)
  k3s_ssh_prefix = var.k3s_mgmt_ip != null ? "" : "-J root@${var.proxmox_ip}"
}

resource "terraform_data" "k3s_kubeconfig" {
  depends_on = [proxmox_virtual_environment_vm.cloud]

  triggers_replace = [
    join(",", [
      for name, vm in proxmox_virtual_environment_vm.cloud :
      vm.id if var.cloud_vms[name].k3s_role == "server"
    ])
  ]

  provisioner "local-exec" {
    command = <<-EOT
      TMPFILE=$(mktemp)

      # Fetch kubeconfig from K3s server
      ssh -o StrictHostKeyChecking=no ${local.k3s_ssh_prefix} ubuntu@${local.k3s_fetch_ip} \
          'sudo cat /etc/rancher/k3s/k3s.yaml' \
        | sed "s|127.0.0.1|${local.k3s_fetch_ip}|g" \
        | sed "s|default|${var.cluster_name}|g" \
        > "$TMPFILE"

      # Merge into existing kubeconfig (or create if first cluster)
      if [ -f "${var.kubeconfig_output_path}" ]; then
        KUBECONFIG="${var.kubeconfig_output_path}:$TMPFILE" kubectl config view --flatten > "${var.kubeconfig_output_path}.merged"
        mv "${var.kubeconfig_output_path}.merged" "${var.kubeconfig_output_path}"
      else
        mv "$TMPFILE" "${var.kubeconfig_output_path}"
      fi

      rm -f "$TMPFILE"
      echo "Kubeconfig for ${var.cluster_name} merged into ${var.kubeconfig_output_path}"
    EOT
  }
}

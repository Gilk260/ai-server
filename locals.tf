locals {
  # Workspace safety: fail at plan time if workspace doesn't match cluster_name (side-effect only)
  # tflint-ignore: terraform_unused_declarations
  validate_workspace = (
    terraform.workspace == var.cluster_name
    ? true
    : tobool("ERROR: workspace '${terraform.workspace}' doesn't match cluster_name '${var.cluster_name}'")
  )

  # Extract Proxmox host IP from endpoint URL for SSH provisioners
  proxmox_ip = regex("https?://([^:/]+)", var.virtual_environment_endpoint)[0]

  # K3s server lookups
  k3s_server_ip = try([
    for name, vm in var.cloud_vms : vm.ip
    if vm.k3s_role == "server"
  ][0], null)

  k3s_mgmt_ip = try([
    for name, vm in var.cloud_vms : vm.mgmt_ip
    if vm.k3s_role == "server" && vm.mgmt_ip != null
  ][0], null)

  # Unique node names from VM definitions
  vm_nodes = distinct(concat(
    [for k, v in var.cloud_vms : v.node_name],
    [for k, v in var.iso_vms : v.node_name],
  ))

  # All nodes: infra + VM (may overlap, distinct handles it)
  all_nodes = distinct(concat([var.infra_node_name], local.vm_nodes))
}

locals {
  image_map = {
    "ubuntu-noble" = proxmox_virtual_environment_download_file.ubuntu_noble.id
  }

  # Extract Proxmox host IP from endpoint URL for SSH provisioners
  proxmox_ip = regex("https?://([^:/]+)", var.virtual_environment_endpoint)[0]

  k3s_server_ip = [
    for name, vm in var.cloud_vms : vm.ip
    if vm.k3s_role == "server"
  ][0]

  # Management IP for kubeconfig fetch (bypasses OPNsense, direct laptop access)
  k3s_mgmt_ip = [
    for name, vm in var.cloud_vms : vm.mgmt_ip
    if vm.k3s_role == "server" && vm.mgmt_ip != null
  ][0]
}

# --- Image ID map for modules ---
locals {
  image_ids = { for k, v in proxmox_virtual_environment_download_file.image : k => v.id }
}

# --- Network ---
module "network" {
  source = "./modules/network"

  node_name = data.proxmox_virtual_environment_node.server.node_name
  bridges   = var.bridges
}

# --- OPNsense ---
module "opnsense" {
  source = "./modules/opnsense"

  node_name        = data.proxmox_virtual_environment_node.server.node_name
  opnsense_vm      = var.opnsense_vm
  network_subnet   = var.network_subnet
  wireguard_subnet = var.wireguard_subnet
  cluster_name     = var.cluster_name

  opnsense_iso_file_id = local.image_ids["opnsense"]
  lan_bridge           = "vmbr1"
  vm_datastore_id      = var.vm_datastore_id

  depends_on = [module.network]
}

# --- Pi-hole ---
module "pihole" {
  source = "./modules/pihole"

  node_name            = data.proxmox_virtual_environment_node.server.node_name
  pihole_ct            = var.pihole_ct
  gateway_ip           = var.gateway_ip
  network_subnet       = var.network_subnet
  cluster_name         = var.cluster_name
  cluster_domain       = var.cluster_domain
  ssh_key              = var.ssh_key
  proxmox_ip           = local.proxmox_ip
  lxc_template_file_id = local.image_ids["debian-lxc"]
  lan_bridge           = "vmbr1"
  vm_datastore_id      = var.vm_datastore_id

  depends_on = [module.opnsense]
}

# --- Cloud-init VMs (K3s nodes) ---
module "cloud_vms" {
  source = "./modules/cloud_vms"

  node_name              = data.proxmox_virtual_environment_node.server.node_name
  cloud_vms              = var.cloud_vms
  ssh_key                = var.ssh_key
  gateway_ip             = var.gateway_ip
  network_subnet         = var.network_subnet
  k3s_version            = var.k3s_version
  cluster_name           = var.cluster_name
  cluster_domain         = var.cluster_domain
  templates_path         = "${path.module}/templates"
  image_ids              = local.image_ids
  k3s_server_ip          = local.k3s_server_ip
  k3s_mgmt_ip            = local.k3s_mgmt_ip
  proxmox_ip             = local.proxmox_ip
  kubeconfig_output_path = "${path.module}/k3s-config.yaml"
  vm_datastore_id        = var.vm_datastore_id

  depends_on = [module.opnsense]
}

# --- ISO VMs (manual install, optional) ---
module "iso_vms" {
  source = "./modules/iso_vms"

  node_name       = data.proxmox_virtual_environment_node.server.node_name
  iso_vms         = var.iso_vms
  cluster_name    = var.cluster_name
  image_ids       = local.image_ids
  vm_datastore_id = var.vm_datastore_id

  depends_on = [module.network]
}

# --- ArgoCD ---
module "argocd" {
  source = "./modules/argocd"

  cluster_name     = var.cluster_name
  cluster_domain   = var.cluster_domain
  private_key_path = "${path.module}/private_key/argocd-infra-gitops.pem"
  helm_values_path = "${path.module}/helm/argocd.yaml"

  depends_on = [module.cloud_vms]
}

# --- Monitoring ---
module "monitoring" {
  source = "./modules/monitoring"

  virtual_environment_endpoint = var.virtual_environment_endpoint
  opnsense_api_key             = var.opnsense_api_key
  opnsense_api_secret          = var.opnsense_api_secret
  victoria_metrics_target_ip   = local.k3s_mgmt_ip

  depends_on = [module.cloud_vms]
}

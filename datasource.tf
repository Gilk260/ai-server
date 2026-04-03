data "proxmox_virtual_environment_node" "infra" {
  node_name = var.infra_node_name
}

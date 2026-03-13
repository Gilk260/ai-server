resource "proxmox_virtual_environment_network_linux_bridge" "bridge" {
  for_each = { for b in var.bridges : b.name => b }

  name      = each.value.name
  node_name = var.node_name
  address   = each.value.address
  comment   = each.value.comment
}

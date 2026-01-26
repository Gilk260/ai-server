resource "proxmox_virtual_environment_network_linux_bridge" "vmbr1" {
  name      = "vmbr1"
  node_name = data.proxmox_virtual_environment_node.server.node_name
}

resource "proxmox_virtual_environment_network_linux_bridge" "vmbr2" {
  name      = "vmbr2"
  node_name = data.proxmox_virtual_environment_node.server.node_name
}

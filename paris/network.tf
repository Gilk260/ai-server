# Private network bridge for OPNsense LAN
resource "proxmox_virtual_environment_network_linux_bridge" "vmbr1" {
  name      = "vmbr1"
  node_name = data.proxmox_virtual_environment_node.server.node_name
  address   = "10.1.0.3/16"
  comment   = "Private LAN (OPNsense)"
}

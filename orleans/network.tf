# Lab private network
resource "proxmox_virtual_environment_network_linux_bridge" "vmbr1" {
  name      = "vmbr1"
  node_name = data.proxmox_virtual_environment_node.server.node_name
  address   = "10.0.0.2/24"
  comment   = "Private Lan"
}

# Wifi radio link
resource "proxmox_virtual_environment_network_linux_bridge" "vmbr2" {
  name      = "vmbr2"
  node_name = data.proxmox_virtual_environment_node.server.node_name
  comment   = "WiFi-Uplink"
}

output "bridge_names" {
  value = { for k, v in proxmox_virtual_environment_network_linux_bridge.bridge : k => v.name }
}

output "bridges" {
  value = proxmox_virtual_environment_network_linux_bridge.bridge
}

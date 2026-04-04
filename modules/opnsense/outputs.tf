output "wireguard_server_public_key" {
  value = wireguard_asymmetric_key.vpn.public_key
}

output "wireguard_server_port" {
  value = var.wireguard_port
}

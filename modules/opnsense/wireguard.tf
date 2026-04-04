locals {
  wg_server_ip = cidrhost(var.wireguard_subnet, 1)
  wg_client_ip = cidrhost(var.wireguard_subnet, 2)
}

resource "opnsense_wireguard_client" "laptop" {
  name       = "laptop"
  public_key = var.wireguard_client_public_key
  tunnel_address = [
    "${local.wg_client_ip}/32",
  ]
}

resource "opnsense_wireguard_server" "vpn" {
  name        = "${var.cluster_name}-vpn"
  public_key  = wireguard_asymmetric_key.vpn.public_key
  private_key = wireguard_asymmetric_key.vpn.private_key
  port        = var.wireguard_port

  tunnel_address = [
    "${local.wg_server_ip}/${split("/", var.wireguard_subnet)[1]}",
  ]

  peers = [
    opnsense_wireguard_client.laptop.id,
  ]
}

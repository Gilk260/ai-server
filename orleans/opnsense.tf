locals {
  vpn_network    = "10.10.10.0/24"
  lab_network    = "10.0.0.0/24"
  wireguard_port = 51820
}

resource "wireguard_asymmetric_key" "lab_vpn" {
}

resource "opnsense_wireguard_client" "laptop" {
  name           = "ManjaroLaptop"
  public_key     = chomp(file("./wireguard/personal_public.key"))
  tunnel_address = ["10.10.10.2/32"]
}

resource "opnsense_wireguard_server" "lab_vpn" {
  name        = "LabVPN"
  public_key  = wireguard_asymmetric_key.lab_vpn.public_key
  private_key = wireguard_asymmetric_key.lab_vpn.private_key

  # Optional
  port  = local.wireguard_port
  peers = [opnsense_wireguard_client.laptop.id]
}

resource "opnsense_firewall_filter" "allow_wireguard_wan" {
  description = "Allow WireGuard Connect"
  sequence    = 1 # Order matters!

  interface = {
    interface = ["wan"]
  }

  filter = {
    action    = "pass"
    direction = "in"
    protocol  = "UDP"

    # Optional
    ip_protocol = "inet" # IPv4
    destination = {
      port = tostring(local.wireguard_port)
    }
  }
}

resource "opnsense_firewall_filter" "allow_wireguard_lan" {
  description = "Allow VPN to Lab"
  sequence    = 2

  # Need to enable Wireguard through the GUI, then assign interface wg0 to opt1
  # something like that
  interface = {
    interface = ["opt1"]
  }

  filter = {
    action    = "pass"
    direction = "in"
    protocol  = "any" # Allow TCP/UDP/ICMP

    # Optional
    ip_protocol = "inet"
    source = {
      net = local.vpn_network
    }
    destination = {
      net = local.lab_network
    }
  }
}

resource "wireguard_asymmetric_key" "lab_vpn" {
}

resource "opnsense_wireguard_client" "laptop" {
  name             = "ManjaroLaptop"
  public_key           = var.personal_key
  tunnel_address   = ["10.10.10.2/32"]
}

resource "opnsense_wireguard_server" "lab_vpn" {
  name        = "LabVPN"
  # The keys must be generated manually or via "random_password" resource
  # Best practice: Use variables for sensitive keys
  public_key      = wireguard_asymmetric_key.lab_vpn.public_key
  private_key     = wireguard_asymmetric_key.lab_vpn.private_key

  # Optional
  port        = 51820
  peers       = [opnsense_wireguard_client.laptop.id] # Links the peer below
}

resource "opnsense_firewall_filter" "allow_wireguard_wan" {
  description = "Allow WireGuard Connect"
  enabled     = true
  sequence    = 1  # Order matters!

  # Schema: interface (Attributes) -> interface (Set of String)
  interface = {
    interface = ["wan"]
  }

  # Schema: filter (Attributes)
  filter = {
    action      = "pass"
    direction   = "in"
    protocol    = "UDP"
    ip_protocol = "inet" # IPv4

    # Schema: destination (Attributes) -> port (String)
    destination = {
      port = "51820"
    }
  }
}

resource "opnsense_firewall_filter" "allow_wireguard_lan" {
  description = "Allow VPN to Lab"
  enabled     = true
  sequence    = 2

  # Note: "wireguard" is the automatic group created by the plugin.
  # If this fails, try "opt1" or whatever interface ID OpnSense assigned.
  interface = {
    interface = ["opt1"]
  }

  filter = {
    action      = "pass"
    direction   = "in"
    protocol    = "any"  # Allow TCP/UDP/ICMP
    ip_protocol = "inet"

    # Schema: source (Attributes) -> net (String)
    source = {
      net = "10.10.10.0/24" # The VPN Network
    }

    # Schema: destination (Attributes) -> net (String)
    destination = {
      net = "10.0.0.0/24"   # The Lab Network
    }
  }
}

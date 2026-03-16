# --- Firewall Filter Rules ---

resource "opnsense_firewall_filter" "allow_wireguard_wan" {
  description = "Allow WireGuard Connect"
  sequence    = 1

  interface = {
    interface = ["wan"]
  }

  filter = {
    action      = "pass"
    direction   = "in"
    protocol    = "UDP"
    ip_protocol = "inet"
    destination = {
      port = tostring(var.wireguard_port)
    }
  }
}

resource "opnsense_firewall_filter" "allow_lan_dns" {
  description = "Allow LAN DNS"
  sequence    = 2

  interface = {
    interface = ["lan"]
  }

  filter = {
    action      = "pass"
    direction   = "in"
    protocol    = "UDP"
    ip_protocol = "inet"
    source = {
      net = var.network_subnet
    }
    destination = {
      port = "53"
    }
  }
}

resource "opnsense_firewall_filter" "allow_lan_https" {
  description = "Allow LAN HTTPS"
  sequence    = 3

  interface = {
    interface = ["lan"]
  }

  filter = {
    action      = "pass"
    direction   = "in"
    protocol    = "TCP"
    ip_protocol = "inet"
    source = {
      net = var.network_subnet
    }
    destination = {
      port = "443"
    }
  }
}

resource "opnsense_firewall_filter" "allow_lan_http" {
  description = "Allow LAN HTTP"
  sequence    = 4

  interface = {
    interface = ["lan"]
  }

  filter = {
    action      = "pass"
    direction   = "in"
    protocol    = "TCP"
    ip_protocol = "inet"
    source = {
      net = var.network_subnet
    }
    destination = {
      port = "80"
    }
  }
}

resource "opnsense_firewall_filter" "allow_vpn_to_lan" {
  description = "Allow VPN to LAN"
  sequence    = 5

  interface = {
    interface = ["opt1"]
  }

  filter = {
    action      = "pass"
    direction   = "in"
    protocol    = "any"
    ip_protocol = "inet"
    source = {
      net = var.wireguard_subnet
    }
    destination = {
      net = var.network_subnet
    }
  }
}

resource "opnsense_firewall_filter" "allow_wan_opnsense_api" {
  description = "Allow WAN to OPNsense API"
  sequence    = 6

  interface = {
    interface = ["wan"]
  }

  filter = {
    action      = "pass"
    direction   = "in"
    protocol    = "TCP"
    ip_protocol = "inet"
    source = {
      net = "192.168.1.0/24"
    }
    destination = {
      port = "443"
    }
  }
}

# --- NAT ---

resource "opnsense_firewall_nat" "lan_to_wan" {
  description = "NAT LAN to WAN"
  interface   = "wan"
  protocol    = "any"
  ip_protocol = "inet"
  sequence    = 1

  source = {
    net = var.network_subnet
  }

  target = {
    ip = "wanip"
  }
}

resource "opnsense_firewall_filter" "allow_lan_outbound" {
  description = "Allow all LAN outbound"
  sequence    = 10

  interface = {
    interface = ["lan"]
  }

  filter = {
    action      = "pass"
    direction   = "in"
    protocol    = "any"
    ip_protocol = "inet"
    source = {
      net = var.network_subnet
    }
  }
}

resource "opnsense_firewall_filter" "allow_wan_outbound" {
  description = "Allow NATted LAN traffic out WAN"
  sequence    = 20

  interface = {
    interface = ["wan"]
  }

  filter = {
    action      = "pass"
    direction   = "out"
    protocol    = "any"
    ip_protocol = "inet"
  }
}

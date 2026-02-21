locals {
  vpn_network    = "10.10.10.0/24"
  lab_network    = "10.0.0.0/16"
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

###############################################################################
#######                         FIREWALL FILTER                         #######
###############################################################################

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

resource "opnsense_firewall_filter" "allow_lab_to_pve" {
  description = "Allow Lab to Proxmox API"
  sequence    = 2

  interface = {
    interface = ["lan"]
  }

  filter = {
    action    = "pass"
    direction = "in"
    protocol  = "TCP"

    ip_protocol = "inet"
    source = {
      net = local.lab_network
    }
    destination = {
      net  = var.virtual_environment_ip
      port = "8006"
    }
  }
}

resource "opnsense_firewall_filter" "allow_wireguard_lan" {
  description = "Allow VPN to Lab"
  sequence    = 3

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

resource "opnsense_firewall_filter" "allow_lab_dns" {
  description = "Allow Lab DNS"
  sequence    = 4

  interface = {
    interface = ["lan"]
  }

  filter = {
    action    = "pass"
    direction = "in"
    protocol  = "UDP"

    ip_protocol = "inet"
    source = {
      net = local.lab_network
    }
    destination = {
      port = "53"
    }
  }
}

resource "opnsense_firewall_filter" "allow_lab_https" {
  description = "Allow Lab HTTPS"
  sequence    = 5

  interface = {
    interface = ["lan"]
  }

  filter = {
    action    = "pass"
    direction = "in"
    protocol  = "TCP"

    ip_protocol = "inet"
    source = {
      net = local.lab_network
    }
    destination = {
      port = "443"
    }
  }
}

resource "opnsense_firewall_filter" "allow_lab_http" {
  description = "Allow Lab HTTP"
  sequence    = 6

  interface = {
    interface = ["lan"]
  }

  filter = {
    action    = "pass"
    direction = "in"
    protocol  = "TCP"

    ip_protocol = "inet"
    source = {
      net = local.lab_network
    }
    destination = {
      port = "80"
    }
  }
}

# TODO: Restrict source to a static IP when available
resource "opnsense_firewall_filter" "allow_wan_opnsense_api" {
  description = "Allow WAN to OPNsense API"
  sequence    = 7

  interface = {
    interface = ["wan"]
  }

  filter = {
    action    = "pass"
    direction = "in"
    protocol  = "TCP"

    ip_protocol = "inet"
    source = {
      net = "192.168.1.0/24"
    }
    destination = {
      port = "443"
    }
  }
}

##########################################################################
#######                       FIREWALL NAT                         #######
##########################################################################

resource "opnsense_firewall_nat" "lab_to_wan" {
  description = "NAT Lab to WAN"
  interface   = "wan"
  protocol    = "any"
  ip_protocol = "inet"
  sequence    = 1

  source = {
    net = local.lab_network
  }

  target = {
    ip = "wanip"
  }
}

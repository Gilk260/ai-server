terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
    opnsense = {
      source = "browningluke/opnsense"
    }
    wireguard = {
      source = "OJFord/wireguard"
    }
  }
}

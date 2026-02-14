terraform {
  required_version = "~> 1.9"

  required_providers {
    adguard = {
      source  = "gmichels/adguard"
      version = "1.6.2"
    }
    helm = {
      source = "hashicorp/helm"
      version = "3.1.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.37.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.4"
    }
    opnsense = {
      source  = "browningluke/opnsense"
      version = "0.16.1"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.78.2"
    }
    wireguard = {
      source  = "ojford/wireguard"
      version = "0.4.0"
    }
  }
}

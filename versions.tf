terraform {
  required_version = ">= 1.11.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.98"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
    opnsense = {
      source  = "browningluke/opnsense"
      version = "~> 0.16"
    }
    wireguard = {
      source  = "OJFord/wireguard"
      version = "~> 0.4"
    }
  }
}

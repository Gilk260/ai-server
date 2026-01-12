terraform {
  required_version = "~> 1.9"

  required_providers {
    adguard = {
      source  = "gmichels/adguard"
      version = "1.6.2"
    }
    # helm = {
    #   source = "hashicorp/helm"
    #   version = "3.0.2"
    # }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.37.1"
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

provider "proxmox" {
  username = var.virtual_environment_username
  password = var.virtual_environment_password

  endpoint = var.virtual_environment_endpoint

  insecure = true

  ssh {
    agent = true
  }
}

provider "adguard" {
  host     = "${var.sinkhole_ip}:80"
  username = "admin"
  password = var.adguard_password
  scheme   = "http"
}

provider "kubernetes" {
  host        = "https://${var.control_plane_ip}:6443"
  config_path = "~/.kube/config"
}

provider "wireguard" {
}

# provider "helm" {
#   kubernetes = {
#     config_path = "~/.kube/config"
#   }
# }

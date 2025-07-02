terraform {
  required_version = "= 1.9.1"

  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "3.0.2"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.37.1"
    }
    proxmox = {
      source = "bpg/proxmox"
      version = "0.78.2"
    }
  }
}

provider "proxmox" {
  username  = var.virtual_environment_username
  password  = var.virtual_environment_password

  endpoint = var.virtual_environment_endpoint

  insecure = true

  ssh {
    agent = true
  }
}

provider "kubernetes" {
  host = "https://${var.cluster_address}:6443"
  config_path = "./admin.conf"
}

provider "helm" {
  kubernetes = {
    config_path = "./admin.conf"
  }
}

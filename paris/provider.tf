terraform {
  required_version = "~> 1.11.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.78.2"
    }

    time = {
      source = "hashicorp/time"
      version = "0.13.1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.37.1"
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

provider "helm" {
  kubernetes {
    config_path = "${path.module}/k3s-config.yaml"
  }
}

provider "kubernetes" {
  config_path = "${path.module}/k3s-config.yaml"
}

